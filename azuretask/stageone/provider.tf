terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.43.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }

    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "my-f23-rg"
    storage_account_name = "tfstatemy12"
    container_name       = "mytfgithub"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  #skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
  client_id       = "c9d0477d-c277-401a-9a23-fd3644ebc3e7"
  client_secret   = var.client_secret
  tenant_id       = "03024f44-e3ad-4b2c-b85b-d1a744b0b70f"
  subscription_id = "6ea6f9f7-0a28-45a1-b63d-c045d73026f2"
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

