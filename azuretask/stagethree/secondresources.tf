resource "azurerm_virtual_network" "nor-network" {
  name                = "nor-network"
  resource_group_name = data.azurerm_resource_group.my-f23-rg.name
  location            = "Norway East"
  address_space       = var.norvirtualnet
}

resource "azurerm_subnet" "nor-subnet" {
  name                 = "nor-subnet"
  resource_group_name  = data.azurerm_resource_group.my-f23-rg.name
  virtual_network_name = azurerm_virtual_network.nor-network.name
  address_prefixes     = var.norsubnetcidr
}

resource "azurerm_subnet" "nor-sec-subnet" {
  name                 = "nor-sec-subnet"
  resource_group_name  = data.azurerm_resource_group.my-f23-rg.name
  virtual_network_name = azurerm_virtual_network.nor-network.name
  address_prefixes     = var.norsecsubnetcidr
  # nat_gateway_id       = azurerm_nat_gateway.mynat.id
}

resource "azurerm_network_interface" "nic" {
  #count               = 2
  #name                = "nic-${count.index+1}"
  name                = "nic-1"
  location            = "Norway East"
  resource_group_name = data.azurerm_resource_group.my-f23-rg.name

  ip_configuration {
    name                          = "nic-ipconfig-1"
    subnet_id                     = azurerm_subnet.nor-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.noragw-ip.id
  }
}

resource "azurerm_network_interface" "secnic" {
  #count               = 2
  #name                = "nic-${count.index+1}"
  name                = "nic-2"
  location            = "Norway East"
  resource_group_name = data.azurerm_resource_group.my-f23-rg.name

  ip_configuration {
    name                          = "nic-ipconfig-2"
    subnet_id                     = azurerm_subnet.nor-sec-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc" {
  #count                   = 2
  network_interface_id    = azurerm_network_interface.secnic.id
  ip_configuration_name   = "nic-ipconfig-2"
  backend_address_pool_id = one(azurerm_application_gateway.noragw.backend_address_pool).id
}

resource "azurerm_windows_virtual_machine" "vm" {
  count               = 2
  name                = "myVM${count.index+1}"
  resource_group_name = data.azurerm_resource_group.my-f23-rg.name
  location            = "Norway East"
  size                = "Standard_DS1_v2"
  admin_username      = "azureadmin"
  admin_password      = var.vmpass
  source_image_id     = data.azurerm_image.search.id

  network_interface_ids = [
    azurerm_network_interface.secnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

}

resource "azurerm_network_security_group" "nor-security" {
  name                = "NorTestSecurityGroup1"
  location            = "Norway East"
  resource_group_name = data.azurerm_resource_group.my-f23-rg.name

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
    name                       = "httpsaccess"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
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

resource "azurerm_subnet_network_security_group_association" "norsubnet" {
  subnet_id                 = azurerm_subnet.nor-sec-subnet.id
  network_security_group_id = azurerm_network_security_group.nor-security.id
}

resource "azurerm_subnet_network_security_group_association" "norsecsubnet" {
  subnet_id                 = azurerm_subnet.nor-subnet.id
  network_security_group_id = azurerm_network_security_group.nor-security.id
}

resource "azurerm_public_ip" "noragw-ip" {
  name                = "nor-agw-ip"
  location            = "Norway East"
  resource_group_name = data.azurerm_resource_group.my-f23-rg.name
  allocation_method   = "Static"
  domain_name_label   = "myproject"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "noragw" {
  name                = "nor-agw"
  resource_group_name = data.azurerm_resource_group.my-f23-rg.name
  location            = "Norway East"

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  # Assign the managed identity to the application gateway
  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.identity.id]
  }

  gateway_ip_configuration {
    name      = "nor-gateway-ip-configuration"
    subnet_id = azurerm_subnet.nor-subnet.id
  }

  frontend_port {
    name = "nor-frontend-port"
    port = 80
  }

  frontend_port {
    name = "nor-httpsfrontend-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "nor-frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.noragw-ip.id
  }
  # Reference the Key Vault and the certificate ID
  # ssl_certificate {
  #   name     = "my-ssl-certificate"
  #   #key_vault_secret_id = azurerm_key_vault_certificate.cert.secret_id
  #   key_vault_secret_id = azurerm_key_vault.kv.id
  # }

  http_listener {
    name                           = "nor-http-listener"
    frontend_ip_configuration_name = "nor-frontend-ip-configuration"
    frontend_port_name             = "nor-frontend-port"
    protocol                       = "Http"
    #ssl_certificate_name           = "my-ssl-certificate"
  }

  http_listener {
    name                           = "nor-https-listener"
    frontend_ip_configuration_name = "nor-frontend-ip-configuration"
    frontend_port_name             = "nor-httpsfrontend-port"
    protocol                       = "Https"
    ssl_certificate_name           = data.azurerm_key_vault_certificate.certificate.name
  }

  backend_address_pool {
    name = "nor-backend-address-pool"
  }

  backend_http_settings {
    name                  = "nor-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    probe_name            = "norprobe"
  }

  probe {
    name                = "norprobe"
    host                = "127.0.0.1"
    interval            = 300
    timeout             = 300
    protocol            = "Http"
    path                = "/"
    unhealthy_threshold = 3
  }

  request_routing_rule {
    name                        = "nor-http-https-routing-rule"
    priority                    = 1
    rule_type                   = "Basic"
    http_listener_name          = "nor-http-listener"
    redirect_configuration_name = "norredirect"
  }

  request_routing_rule {
    name                       = "nor-http-https-routing-rule"
    priority                   = 2
    rule_type                  = "Basic"
    http_listener_name         = "nor-https-listener"
    backend_address_pool_name  = "nor-backend-address-pool"
    backend_http_settings_name = "nor-backend-http-settings"
  }

  redirect_configuration {
    name                 = "norredirect"
    redirect_type        = "Permanent"
    target_listener_name = "nor-https-listener"
    include_path         = true
    include_query_string = true
  }
  ssl_certificate {
    name                = "mydavidcloudxyz"
    key_vault_secret_id = data.azurerm_key_vault_certificate.certificate.secret_id
  }

  # Use the ignore_changes argument to prevent Terraform from overwriting any manual changes
  lifecycle {
    ignore_changes = [
      ssl_certificate,
    ]
  }
}

data "azurerm_traffic_manager_profile" "my-traffic" {
  name                = "mytraffictest"
  resource_group_name = data.azurerm_resource_group.my-f23-rg.name
}

resource "azurerm_traffic_manager_azure_endpoint" "nor" {
  name               = "eu-endpoint"
  profile_id         = data.azurerm_traffic_manager_profile.my-traffic.id
  target_resource_id = azurerm_public_ip.noragw-ip.id
  weight             = 100
  geo_mappings       = ["GEO-EU", "GEO-AF", "GEO-AS"]
}

resource "azurerm_windows_virtual_machine_scale_set" "my-scale-set" {
  name                = "my-vmss"
  resource_group_name = data.azurerm_resource_group.my-f23-rg.name
  location            = data.azurerm_resource_group.my-f23-rg.location
  sku                 = "Standard_DS1_v2"
  # generation          = 2
  instances           = 2
  admin_username      = "azureuser"
  admin_password      = var.vmpass
  secure_boot_enabled = false
  #source_image_id     = #"/subscriptions/6ea6f9f7-0a28-45a1-b63d-c045d73026f2/resourceGroups/my-f23-rg/providers/Microsoft.Compute/galleries/my_gallery/images/my-template/versions/0.0.2"
  source_image_id = data.azurerm_image.search.id


  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                      = "my-net-profile"
    primary                   = true
    network_security_group_id = data.azurerm_network_security_group.my-security.id

    ip_configuration {
      name                                         = "internal"
      primary                                      = true
      subnet_id                                    = data.azurerm_subnet.third-subnet.id
      application_gateway_backend_address_pool_ids = data.azurerm_application_gateway.agw.backend_address_pool[*].id
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "autoscale"
  location            = data.azurerm_resource_group.my-f23-rg.location
  resource_group_name = data.azurerm_resource_group.my-f23-rg.name
  target_resource_id  = azurerm_windows_virtual_machine_scale_set.my-scale-set.id
  enabled             = true
  profile {
    name = "autoscale"
    capacity {
      default = 2
      minimum = 1
      maximum = 10
    }
  }
}
