provider "azurerm" {
  features {}
  subscription_id = "eb986b09-9743-4aa1-b10f-53da04d8708c"
}

terraform {
  backend "azurerm" {}
}

provider "vault" {
  address = "http://vault-int.mydevops.shop:8200"
  token   = var.token
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

# Kubernetes provider
provider "kubernetes" {
  config_path = "~/.kube/config"  # Path to your kubeconfig
}

# Helm provider
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
