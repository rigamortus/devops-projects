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

# data "azurerm_key_vault" "kv" {
#   name                = "benmykv"
#   resource_group_name = "my-f23-rg"
# }