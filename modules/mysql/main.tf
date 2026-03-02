resource "azurerm_private_dns_zone" "main" {
  name                = "roboshop.mysql.mydevops.shop"
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "mydevops.shop"
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.rg_name
}

resource "azurerm_mysql_flexible_server" "main" {
  name                   = "${var.name}-${var.env}"
  resource_group_name    = var.rg_name
  location               = var.rg_location
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  backup_retention_days  = 7
  delegated_subnet_id    = var.vnet_subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.main.id
  sku_name               = "GP_Standard_D2ds_v4"
}




