data "azurerm_client_config" "current" {
}

data "azurerm_shared_image_version" "example" {
  name                = "0.0.1"
  image_name          = "my-template"
  gallery_name        = "my_gallery"
  resource_group_name = "my-f22-rg"
  sort_versions_by_semver = true
}

data "azurerm_image" "myimage" {
  name                = "my-image"
  resource_group_name = "my-f22-rg"
}


