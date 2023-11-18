resource "azurerm_resource_group" "my-f23-rg" {
  name     = "my-f23-rg"
  location = var.location
}

resource "azurerm_virtual_network" "my-network" {
  name                = "my-network"
  resource_group_name = azurerm_resource_group.my-f23-rg.name
  location            = azurerm_resource_group.my-f23-rg.location
  address_space       = var.virtualnet
}

resource "azurerm_subnet" "my-subnet" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.my-f23-rg.name
  virtual_network_name = azurerm_virtual_network.my-network.name
  address_prefixes     = var.mysubnetcidr
}

resource "azurerm_subnet" "my-sec-subnet" {
  name                 = "my-sec-subnet"
  resource_group_name  = azurerm_resource_group.my-f23-rg.name
  virtual_network_name = azurerm_virtual_network.my-network.name
  address_prefixes     = var.mysecsubnetcidr
  # nat_gateway_id       = azurerm_nat_gateway.mynat.id
}

resource "azurerm_subnet" "third-subnet" {
  name                 = "third-subnet"
  resource_group_name  = azurerm_resource_group.my-f23-rg.name
  virtual_network_name = azurerm_virtual_network.my-network.name
  address_prefixes     = 
  # nat_gateway_id       = azurerm_nat_gateway.mynat.id
}

resource "azurerm_public_ip" "nat-ip" {
  name                = "my-nat-ip"
  location            = azurerm_resource_group.my-f23-rg.location
  resource_group_name = azurerm_resource_group.my-f23-rg.name
  allocation_method   = "Static"
  domain_name_label   = "mytryproject"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "agw-ip" {
  name                = "my-agw-ip"
  location            = azurerm_resource_group.my-f23-rg.location
  resource_group_name = azurerm_resource_group.my-f23-rg.name
  allocation_method   = "Static"
  domain_name_label   = "myproject"
  sku                 = "Standard"
}

# resource "azurerm_public_ip" "vm-ip" {
#   name                = "my-ip"
#   location            = azurerm_resource_group.my-f23-rg.location
#   resource_group_name = azurerm_resource_group.my-f23-rg.name
#   allocation_method   = "Dynamic"
#   domain_name_label   = "vmproject"
#   sku                 = "Basic"
# }

resource "azurerm_network_interface" "my-vmssnic" {
  name                = "my-vmssnic"
  location            = azurerm_resource_group.my-f23-rg.location
  resource_group_name = azurerm_resource_group.my-f23-rg.name

  ip_configuration {
    name                          = "my-ipc"
    subnet_id                     = azurerm_subnet.third-subnet.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    #public_ip_address_id          = azurerm_public_ip.pub-ip.id
  }
}

resource "azurerm_network_interface" "my-vmnic" {
  name                = "my-vmnic"
  location            = azurerm_resource_group.my-f23-rg.location
  resource_group_name = azurerm_resource_group.my-f23-rg.name

  ip_configuration {
    name                          = "my-ipc"
    subnet_id                     = azurerm_subnet.my-sec-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-ip.id
  }
}

resource "azurerm_nat_gateway" "mynat" {
  name                = "my-natgw"
  location            = azurerm_resource_group.my-f23-rg.location
  resource_group_name = azurerm_resource_group.my-f23-rg.name
  sku_name            = "Standard"
  # public_ip_address_id = [azurerm_public_ip.pub-ip.id]
}

resource "azurerm_nat_gateway_public_ip_association" "mynatass" {
  nat_gateway_id       = azurerm_nat_gateway.mynat.id
  public_ip_address_id = azurerm_public_ip.nat-ip.id
}

resource "azurerm_network_security_group" "my-security" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.my-f23-rg.location
  resource_group_name = azurerm_resource_group.my-f23-rg.name

  security_rule {
    name                       = "httpaccess"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "test"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "mytest"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet" {
  subnet_id                 = azurerm_subnet.third-subnet.id
  network_security_group_id = azurerm_network_security_group.my-security.id
}

resource "azurerm_subnet_network_security_group_association" "agsubnet" {
  subnet_id                 = azurerm_subnet.my-subnet.id
  network_security_group_id = azurerm_network_security_group.my-security.id
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my-vmnic.id
  network_security_group_id = azurerm_network_security_group.my-security.id
}

resource "azurerm_network_interface_security_group_association" "tryexample" {
  network_interface_id      = azurerm_network_interface.my-vmssnic.id
  network_security_group_id = azurerm_network_security_group.my-security.id
}

resource "azurerm_windows_virtual_machine" "my-vm" {
  name                  = "example-vm"
  resource_group_name   = azurerm_resource_group.my-f23-rg.name
  location              = azurerm_resource_group.my-f23-rg.location
  size                  = "Standard_DS1_v2"
  admin_username        = "azureuser"
  admin_password        = var.vmpass
  network_interface_ids = [azurerm_network_interface.my-vmnic.id]

  provision_vm_agent = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# locals {
#   script_content = file("${path.module}/webserver.ps1")
# }


resource "azurerm_virtual_machine_extension" "my-powershell" {
  name                 = "runpowershellscript"
  virtual_machine_id   = azurerm_windows_virtual_machine.my-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -encodedCommand ${textencodebase64(file("~/devops-projects/azuretask/webserver.ps1"), "UTF-16LE")}"
  }
  SETTINGS
  depends_on         = [azurerm_windows_virtual_machine.my-vm]
}

# resource "null_resource" "deallocate" {
#   provisioner "local-exec" {
#     command = <<EOT
#     az vm deallocate \
#        --resource-group my-f23-rg \
#        --name example-vm
#     EOT   
#   }

#   # depends_on = [azurerm_virtual_machine_extension.my-powershell]
# }

# resource "null_resource" "generalize" {
#   provisioner "local-exec" {
#     command = <<EOT
#     az vm generalize \
#        --resource-group my-f23-rg \
#        --name example-vm
#     EOT   
#   }
#   depends_on = [null_resource.deallocate]
# }



# resource "azurerm_image" "my-image" {
#   name                      = "my-image"
#   resource_group_name       = azurerm_resource_group.my-f23-rg.name
#   location                  = azurerm_resource_group.my-f23-rg.location
#   #source_virtual_machine_id = azurerm_windows_virtual_machine.my-vm.id
#   depends_on                = [resource.null_resource.generalize]
# }

resource "azurerm_shared_image_gallery" "my-gallery" {
  name                = "my_gallery"
  resource_group_name = azurerm_resource_group.my-f23-rg.name
  location            = azurerm_resource_group.my-f23-rg.location
  description         = "Shared Image Gallery for Norway and US East 2"
}

resource "azurerm_shared_image" "my-shared-gallery" {
  name                = "my-template"
  gallery_name        = azurerm_shared_image_gallery.my-gallery.name
  resource_group_name = azurerm_shared_image_gallery.my-gallery.resource_group_name
  location            = azurerm_shared_image_gallery.my-gallery.location
  description         = "Image Definition in Shared Image Gallery"
  os_type             = "Windows"

  identifier {
    publisher = "David_Akalugo"
    offer     = "OfferName"
    sku       = "MySku"
  }
}

# resource "azurerm_shared_image_version" "example" {
#   name                = "0.0.1"
#   gallery_name        = azurerm_shared_image.my-shared-gallery.gallery_name
#   image_name          = azurerm_shared_image.my-shared-gallery.name
#   resource_group_name = azurerm_shared_image.my-shared-gallery.resource_group_name
#   location            = azurerm_shared_image.my-shared-gallery.location
#   managed_image_id    = azurerm_image.my-image.id

#   target_region {
#     name                   = azurerm_shared_image.my-shared-gallery.location
#     regional_replica_count = 2
#     storage_account_type   = "Standard_LRS"
#   }
# }

# resource "azurerm_shared_image_version" "try" {
#   name                = "0.0.2"
#   gallery_name        = azurerm_shared_image.my-shared-gallery.gallery_name
#   image_name          = azurerm_shared_image.my-shared-gallery.name
#   resource_group_name = azurerm_shared_image.my-shared-gallery.resource_group_name
#   location            = azurerm_shared_image.my-shared-gallery.location
#   managed_image_id    = azurerm_image.my-image.id

#   target_region {
#     name                   = azurerm_shared_image.my-shared-gallery.location
#     regional_replica_count = 2
#     storage_account_type   = "Standard_LRS"
#   }
# }

# resource "null_resource" "deletevm" {
#   provisioner "local-exec" {
#     command = <<EOT
#     az vm delete --resource-group my-f23-rg --name example-vm --yes --no-wait
#     EOT
#   }
#   depends_on = [azurerm_shared_image_version.example]
# }


# resource "azurerm_lb" "my-lb" {
#   name                = "my-lb"
#   location            = azurerm_resource_group.my-f23-rg.location
#   resource_group_name = azurerm_resource_group.my-f23-rg.name

#   frontend_ip_configuration {
#     name                 = "PublicIPAddress"
#     public_ip_address_id = azurerm_public_ip.my-pub-ip.id
#   }
# }

# resource "azurerm_lb_rule" "lbrule" {
#   loadbalancer_id                = azurerm_lb.my-lb.id
#   name                           = "HTTPLBRule"
#   protocol                       = "Tcp"
#   frontend_port                  = 80
#   backend_port                   = 80
#   frontend_ip_configuration_name = "PublicIPAddress"
#   backend_address_pool_ids       = [azurerm_lb_backend_address_pool.back-pool.id] #["${azurerm_windows_virtual_machine_scale_set.my-scale-set.instances[0].id}", "${azurerm_windows_virtual_machine_scale_set.my-scale-set.instances[1].id}"]
# }

# resource "azurerm_lb_probe" "example" {
#   loadbalancer_id = azurerm_lb.my-lb.id
#   name            = "http-probe"
#   protocol        = "Http"
#   request_path    = "/"
#   port            = 80
# }

# resource "azurerm_lb_backend_address_pool" "back-pool" {
#   loadbalancer_id = azurerm_lb.my-lb.id
#   name            = "my-backend-pool"
# }

# resource "azurerm_subnet_backend_address_pool_association" "example" {
#   subnet_id               = azurerm_subnet.my-subnet.id
#   backend_address_pool_id = azurerm_lb_backend_address_pool.back-pool.id
# }

# openssl pkcs12 -export -out mydavidcloud.pfx -inkey mydavidcloudxyz.pem -in /etc/letsencrypt/live/mydavidcloud.xyz/cert.pem -certfile /etc/letsencrypt/live/mydavidcloud.xyz/chain.pem
#     EOT

# openssl pkcs12 -export -out mydavidcloudxyz.pfx -inkey mydavidcloud.pem -in mydavidcloudxyz.pem
# openssl pkcs12 -export -out mydavidcloud.pfx -inkey app01.key -in app01.crt

905e6623-5068-48e8-b5f5-94cd255e9253 client id
9ju8Q~buDH8lolcK6WdZ2OcRwDSU29kBJ1mQlaS0 secret
5b163a40-c860-4c31-b672-acc81df6d77a secret id