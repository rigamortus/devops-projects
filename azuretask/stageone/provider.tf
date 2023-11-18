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
}

provider "azurerm" {
  #skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
  client_id       = "${{ secrets.CLIENT_ID }}"
  client_secret   = "${{ secrets.CLIENT_SECRET }}"
  tenant_id       = "${{ secrets.TENANT_ID }}"
  subscription_id = "${{ secrets.SUBSCRIPTION_ID }}"
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

