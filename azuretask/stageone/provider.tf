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
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

