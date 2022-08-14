resource "azurerm_public_ip" "vm-web-server-pub" {
  for_each            = var.colors
  name                = "vm-web-server-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

locals {
  ip_configuration_default_name = "default"
}
resource "azurerm_network_interface" "vm-web-server" {
  for_each            = var.colors
  name                = "vm-web-server-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name                          = local.ip_configuration_default_name
    subnet_id                     = azurerm_subnet.vms.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-web-server-pub[each.key].id
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "main-pool-vm-web-server" {
  for_each                = var.colors
  network_interface_id    = azurerm_network_interface.vm-web-server[each.key].id
  ip_configuration_name   = local.ip_configuration_default_name
  backend_address_pool_id = tolist(azurerm_application_gateway.main.backend_address_pool)[index(tolist(var.colors), each.key)].id
}

resource "azurerm_linux_virtual_machine" "vm-web-server" {
  for_each            = var.colors
  name                = "vm-web-server-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"
  admin_username      = "ubuntu"
  network_interface_ids = [
    azurerm_network_interface.vm-web-server[each.key].id,
  ]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = azurerm_public_ip.vm-web-server-pub[each.key].ip_address
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    inline = [
      "until [ -f /var/lib/cloud/instance/boot-finished ]; do sleep 2; done",
      "mkdir -p /tmp/etc/nginx/conf.d/",
    ]
  }
  provisioner "file" {
    content     = templatefile("${path.module}/vm.web-server/etc/nginx/nginx.conf.tmpl.txt", {})
    destination = "/tmp/etc/nginx/nginx.conf"
  }
  provisioner "file" {
    content = templatefile("${path.module}/vm.web-server/etc/nginx/conf.d/_.example.com.conf.tmpl.txt", {
      color = each.key
    })
    destination = "/tmp/etc/nginx/conf.d/_.example.com.conf"
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'apt::install-recommends \"false\";' | sudo tee /etc/apt/apt.conf.d/no-install-recommends",
      "sudo apt-get -qq update",
      "sudo apt-get install -qq --assume-yes nginx",
      "sudo mv /tmp/etc/nginx/nginx.conf /etc/nginx/nginx.conf",
      "sudo mv /tmp/etc/nginx/conf.d/*.conf /etc/nginx/conf.d/",
      "sudo chown -R www-data:www-data /etc/nginx/",
      "sudo systemctl enable nginx",
      "sudo systemctl restart nginx",
    ]
  }
}
