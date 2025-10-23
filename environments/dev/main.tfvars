env                        = "dev"
ip_configuration_subnet_id = "/subscriptions/eb986b09-9743-4aa1-b10f-53da04d8708c/resourceGroups/my-first-rg/providers/Microsoft.Network/virtualNetworks/test-network/subnets/default"
zone_name                  = "mydevops.shop"
dns_record_rg_name         = "my-first-rg"
storage_image_reference_id = "/subscriptions/eb986b09-9743-4aa1-b10f-53da04d8708c/resourceGroups/my-first-rg/providers/Microsoft.Compute/images/local-devops-practice"
network_security_group_id  = "/subscriptions/eb986b09-9743-4aa1-b10f-53da04d8708c/resourceGroups/my-first-rg/providers/Microsoft.Network/networkSecurityGroups/my-first-nsg"
tools_vnet_resource_id     = "/subscriptions/eb986b09-9743-4aa1-b10f-53da04d8708c/resourceGroups/my-first-rg/providers/Microsoft.Network/virtualNetworks/test-network"
databases = {
  mongodb = {
    rgname = "ukwest"
    vnet_prefix   = "main"
    subnet        = "main"
    vm_size       = "Standard_B2s"
    port          = 27017
  }
  # rabbitmq = {
  #   rgname = "ukwest"
  # }
  # mysql = {
  #   rgname = "ukwest"
  # }
  # redis = {
  #   rgname = "ukwest"
  # }
}
applications = {
  catalogue = {
    rgname = "ukwest"
  }
  user = {
    rgname = "ukwest"
  }
  cart = {
    rgname = "ukwest"
  }
  payment = {
    rgname = "ukwest"
  }
  shipping = {
    rgname = "ukwest"
  }
  frontend = {
    rgname = "ukwest"
  }
}
rg_name = {
  ukwest = {
    location = "UK West"
  }
}


aks = {
  main-dev = {
    rgname = "ukwest"
    default_node_pool = {
      nodes   = 1
      vm_size = "standard_d3_v2"
    }
    app_node_pool = {
      one = {
        max_count            = 10
        min_count            = 2
        vm_size              = "standard_d3_v2"
        auto_scaling_enabled = true
        node_labels = {
          "project/name" = "roboshop"
        }
      }
    }
  }
}

vnets = {
  main-dev = {
    rgname        = "ukwest"
    address_space = ["10.50.0.0/24"]
    subnets = {
      main = {
        address_prefixes = ["10.50.0.0/24"]
      }
    }
  }
}

bastion_nodes = ["10.0.0.101", "10.0.0.11"]