resource "azurerm_public_ip" "publicip" {
  name                = var.name
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "privateip" {
  name                = var.name
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = var.name
    subnet_id                     = var.ip_configuration_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg-attach" {
  network_interface_id      = azurerm_network_interface.privateip.id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_virtual_machine" "vm" {
  name                          = var.name
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  network_interface_ids         = [azurerm_network_interface.privateip.id]
  vm_size                       = "Standard_B2s"
  delete_os_disk_on_termination = true

  storage_image_reference {
    id = var.storage_image_reference_id
  }

  storage_os_disk {
    name              = "${var.name}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.name
    admin_username = data.vault_generic_secret.ssh.data["username"]
    admin_password = data.vault_generic_secret.ssh.data["password"]
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "null_resource" "ansible" {
  depends_on = [
    azurerm_virtual_machine.vm
  ]
  connection {
    type     = "ssh"
    user     = data.vault_generic_secret.ssh.data["username"]
    password = data.vault_generic_secret.ssh.data["password"]
    host     = azurerm_network_interface.privateip.private_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf install python3.12 python3.12-pip -y",
      "sudo pip3.12 install ansible hvac",
      "ansible-pull -i localhost, -U https://github.com/raghudevopsb84/roboshop-ansible roboshop.yml -e role_name=${local.role_name} -e app_name=${var.name} -e env=dev -e token=${var.token}"
    ]
  }
}


resource "azurerm_dns_a_record" "dns_record" {
  name                = "${var.name}-dev"
  zone_name           = var.zone_name
  resource_group_name = var.dns_record_rg_name
  ttl                 = 3
  records             = [azurerm_network_interface.privateip.private_ip_address]
}


