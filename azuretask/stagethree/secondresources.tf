resource "azurerm_windows_virtual_machine_scale_set" "my-scale-set" {
  name                = "my-vmss"
  resource_group_name = azurerm_resource_group.my-f23-rg.name
  location            = azurerm_resource_group.my-f23-rg.location
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
    network_security_group_id = azurerm_network_security_group.my-security.id

    ip_configuration {
      name                                         = "internal"
      primary                                      = true
      subnet_id                                    = azurerm_subnet.third-subnet.id
      application_gateway_backend_address_pool_ids = azurerm_application_gateway.agw.backend_address_pool[*].id
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "autoscale"
  location            = azurerm_resource_group.my-f23-rg.location
  resource_group_name = azurerm_resource_group.my-f23-rg.name
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

# Random String Resource
resource "random_string" "myrandom" {
  length  = 6
  upper   = false
  special = false
  numeric = false
}

resource "random_string" "azurerm_traffic_manager_profile_dns_config" {
  length  = 10
  upper   = false
  numeric = false
  special = false
}

resource "azurerm_traffic_manager_profile" "my-traffic" {
  name                   = random_string.myrandom.result
  resource_group_name    = azurerm_resource_group.my-f23-rg.name
  traffic_routing_method = "Geographic"

  dns_config {
    relative_name = random_string.azurerm_traffic_manager_profile_dns_config.result
    ttl           = 100
  }

  # geographic_hierarchy {
  #   default_location = "World"
  # }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "eastus" {
  name               = "example-endpoint"
  profile_id         = azurerm_traffic_manager_profile.my-traffic.id
  target_resource_id = azurerm_public_ip.agw-ip.id
  weight             = 100
  geo_mappings       = ["GEO-NA", "GEO-AF"]
}
