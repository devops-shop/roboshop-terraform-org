resource "azurerm_kubernetes_cluster" "main" {
  name                = var.name
  location            = var.rg_location
  resource_group_name = var.rg_name
  dns_prefix          = "roboshop"

  default_node_pool {
    name           = "default"
    node_count     = var.default_node_pool["nodes"]
    vm_size        = var.default_node_pool["vm_size"]
    vnet_subnet_id = var.vnet_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  aci_connector_linux {
    subnet_name = var.vnet_subnet_id
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.100.0.0/24"
    dns_service_ip = "10.100.0.10"
  }

  lifecycle {
    ignore_changes = [
      default_node_pool
    ]
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each                    = var.app_node_pool
  name                        = each.key
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.main.id
  vm_size                     = each.value["vm_size"]
  node_count                  = each.value["min_count"]
  min_count                   = each.value["min_count"]
  max_count                   = each.value["max_count"]
  auto_scaling_enabled        = each.value["auto_scaling_enabled"]
  node_labels                 = each.value["node_labels"]
  temporary_name_for_rotation = "${each.key}temp"
  vnet_subnet_id              = var.vnet_subnet_id
}

output "aks" {
  value = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "aks-to-acr" {
  scope                = data.azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

resource "null_resource" "kubeconfig" {
  depends_on = [
    azurerm_kubernetes_cluster.main
  ]

  triggers = {
    time = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az aks get-credentials --name ${var.name} --resource-group ${var.rg_name} --overwrite-existing
EOF
  }
}

resource "helm_release" "external-secrets" {
  depends_on = [
    null_resource.kubeconfig
  ]

  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "devops"
  version          = "0.9.13"
  create_namespace = true

  values = [<<EOF
installCRDs: true
EOF
  ]
}

resource "null_resource" "external-secrets-secret-store" {
  depends_on = [
    helm_release.external-secrets
  ]

  provisioner "local-exec" {
    command = <<TF
kubectl apply -f - <<KUBE
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: roboshop-${var.env}
spec:
  provider:
    vault:
      server: "http://vault-int.mydevops.shop:8200"
      path: "roboshop-${var.env}"
      version: "v2"
      auth:
        tokenSecretRef:
          name: "vault-token"
          key: "token"
          namespace: devops
---
apiVersion: v1
kind: Secret
metadata:
  name: vault-token
  namespace: devops
data:
  token: ${base64encode(var.token)}
KUBE
TF
  }
}