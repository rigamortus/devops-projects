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
