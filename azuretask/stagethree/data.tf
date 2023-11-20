# data "azurerm_shared_image_version" "try" {
#   name                    = "0.0.2"
#   image_name              = "my-template"
#   gallery_name            = "my_gallery"
#   resource_group_name     = "my-f23-rg"
#   sort_versions_by_semver = true
# }

# data "azurerm_key_vault_certificate" "cert" {
#   name         = "mydavidcloudxyz"
#   key_vault_id = azurerm_key_vault.kv.id
# }


data "azurerm_client_config" "current" {
}

data "azurerm_image" "search" {
  name                = "my-image"
  resource_group_name = "my-f22-rg"
}

data "azurerm_public_ip" "example" {
  name                = "my-agw-ip"
  resource_group_name = "my-f22-rg"
}

data "azurerm_resource_group" "my-f23-rg" {
  name = "my-f22-rg"
}

data "azurerm_subnet" "third-subnet" {
  name                 = "third-subnet"
  virtual_network_name = "my-network"
  resource_group_name  = "my-f22-rg"
}

data "azurerm_network_security_group" "my-security" {
  name                = "acceptanceTestSecurityGroup1"
  resource_group_name = my-f22-rg
}

data "azurerm_application_gateway" "agw"
  name                = "my-agw"
  resource_group_name = "my-f22-rg"
}
# data "azurerm_key_vault" "kv" {
#   name                = "benmykv"
#   resource_group_name = "my-f23-rg"
# }
