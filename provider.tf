provider "azurerm" {
  features {}
  subscription_id = "eb986b09-9743-4aa1-b10f-53da04d8708c"
}

terraform {
  backend "azurerm" {}
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "4.8.0"
    }
  }
}

provider "vault" {
  address = "http://vault-int.mydevops.shop:8200"
  token   = var.token
}
