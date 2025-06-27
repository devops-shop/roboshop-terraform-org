module "resource-group" {
  for_each = var.rg_name
  source   = "./modules/resource-group"
  name     = "${each.key}-${var.env}"
  location = each.value["location"]
}

module "databases" {
  for_each                   = var.databases
  source                     = "./modules/vm"
  ip_configuration_subnet_id = var.ip_configuration_subnet_id
  name                       = each.key
  rg_name                    = module.resource-group[each.value["rgname"]].name
  rg_location                = module.resource-group[each.value["rgname"]].location
  storage_image_reference_id = var.storage_image_reference_id
  zone_name                  = var.zone_name
  network_security_group_id  = var.network_security_group_id
  dns_record_rg_name         = var.dns_record_rg_name
  token                      = var.token
  type                       = "db"
}


# module "applications" {
#   depends_on                 = [ module.databases ]
#   for_each                   = var.applications
#   source                     = "./modules/vm"
#   ip_configuration_subnet_id = var.ip_configuration_subnet_id
#   name                       = each.key
#   rg_name                    = module.resource-group[each.value["rgname"]].name
#   rg_location                = module.resource-group[each.value["rgname"]].location
#   storage_image_reference_id = var.storage_image_reference_id
#   zone_name                  = var.zone_name
#   network_security_group_id  = var.network_security_group_id
#   dns_record_rg_name         = var.dns_record_rg_name
#   token                      = var.token
#   type                       = "app"
# }

module "aks" {
  for_each          = var.aks
  source            = "./modules/aks"
  name              = each.key
  rg_name           = module.resource-group[each.value["rgname"]].name
  rg_location       = module.resource-group[each.value["rgname"]].location
  env               = var.env
  token             = var.token
  default_node_pool = each.value["default_node_pool"]
  app_node_pool     = each.value["app_node_pool"]
  vnet_subnet_id    = var.ip_configuration_subnet_id
}