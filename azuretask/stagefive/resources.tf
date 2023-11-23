resource "azurerm_image" "myimage" {
  name                      = "my-image"
  location                  = "East US 2"
  resource_group_name       = "my-f22-rg"
}

resource "azurerm_shared_image_version" "example" {
  name                = "0.0.1"
  gallery_name        = "my_gallery"
  image_name          = "my-template"
  resource_group_name = "my-f22-rg"
  location            = "East US 2"

  target_region {
    name                   = "East US 2"
    regional_replica_count = 2
    storage_account_type   = "Standard_LRS"
  }
}
