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


