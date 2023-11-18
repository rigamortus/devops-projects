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

terraform {
  cloud {
    organization = "rigamortus"

    workspaces {
      name = "githubwork"
    }
    token = "uTCXvRtV0AMaWw.atlasv1.qcEuoSman6WMS9zuDeiPwckqhm3LitYwFCXwBG3jxdhtdSXR6gLZQXK3ittEkIzFSXo"
  }
}

provider "azurerm" {
  #skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

