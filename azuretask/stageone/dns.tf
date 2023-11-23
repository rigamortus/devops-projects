resource "azurerm_application_gateway" "agw" {
  name                = "my-agw"
  resource_group_name = azurerm_resource_group.my-f23-rg.name
  location            = azurerm_resource_group.my-f23-rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  # Assign the managed identity to the application gateway
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.my-subnet.id
  }

  frontend_port {
    name = "my-frontend-port"
    port = 80
  }

  frontend_port {
    name = "my-httpsfrontend-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "my-frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.agw-ip.id
  }
  # Reference the Key Vault and the certificate ID
  # ssl_certificate {
  #   name     = "my-ssl-certificate"
  #   #key_vault_secret_id = azurerm_key_vault_certificate.cert.secret_id
  #   key_vault_secret_id = azurerm_key_vault.kv.id
  # }

  http_listener {
    name                           = "my-http-listener"
    frontend_ip_configuration_name = "my-frontend-ip-configuration"
    frontend_port_name             = "my-frontend-port"
    protocol                       = "Http"
    #ssl_certificate_name           = "my-ssl-certificate"
  }

  http_listener {
    name                           = "my-https-listener"
    frontend_ip_configuration_name = "my-frontend-ip-configuration"
    frontend_port_name             = "my-httpsfrontend-port"
    protocol                       = "Https"
    ssl_certificate_name           = azurerm_key_vault_certificate.certificate.name
  }

  backend_address_pool {
    name = "my-backend-address-pool"
  }

  backend_http_settings {
    name                  = "my-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    probe_name            = "myprobe"
  }

  probe {
    name                = "myprobe"
    host                = "127.0.0.1"
    interval            = 300
    timeout             = 300
    protocol            = "Http"
    path                = "/"
    unhealthy_threshold = 3
  }

  request_routing_rule {
    name                        = "my-http-https-routing-rule"
    priority                    = 1
    rule_type                   = "Basic"
    http_listener_name          = "my-http-listener"
    redirect_configuration_name = "myredirect"
  }

  request_routing_rule {
    name                       = "my-https-routing-rule"
    priority                   = 2
    rule_type                  = "Basic"
    http_listener_name         = "my-https-listener"
    backend_address_pool_name  = "my-backend-address-pool"
    backend_http_settings_name = "my-backend-http-settings"
  }

  redirect_configuration {
    name                 = "myredirect"
    redirect_type        = "Permanent"
    target_listener_name = "my-https-listener"
    include_path         = true
    include_query_string = true
  }
  ssl_certificate {
    name                = "mydavidcloudxyz"
    key_vault_secret_id = azurerm_key_vault_certificate.certificate.secret_id
  }

  # Use the ignore_changes argument to prevent Terraform from overwriting any manual changes
  lifecycle {
    ignore_changes = [
      ssl_certificate,
    ]
  }
}



# resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "example" {
#   count = 2
#   network_interface_id    = element(azurerm_virtual_machine_scale_set.my-scale-set.network_interface_ids, count.index)
#   ip_configuration_name   = "my-ip-configuration"
#   backend_address_pool_id = azurerm_application_gateway.agw.backend_address_pool[0].id
# }
resource "azurerm_user_assigned_identity" "identity" {
  name                = "example-identity"
  resource_group_name = azurerm_resource_group.my-f23-rg.name
  location            = azurerm_resource_group.my-f23-rg.location
}

#Create a Key Vault and import the SSL certificates
resource "azurerm_key_vault" "kv" {
  name                        = "secwondnewmykv"
  resource_group_name         = azurerm_resource_group.my-f23-rg.name
  location                    = azurerm_resource_group.my-f23-rg.location
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  # soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  enabled_for_template_deployment = true

  # Grant the managed identity access to the Key Vault
  # access_policy {
  #   tenant_id = data.azurerm_client_config.current.tenant_id
  #   object_id = data.azurerm_client_config.current.object_id

  #   certificate_permissions = [
  #     "Create",
  #     "Delete",
  #     "DeleteIssuers",
  #     "Get",
  #     "GetIssuers",
  #     "Import",
  #     "List",
  #     "ListIssuers",
  #     "ManageContacts",
  #     "ManageIssuers",
  #     "Purge",
  #     "SetIssuers",
  #     "Update",
  #   ]

  #   key_permissions = [
  #     "Backup",
  #     "Create",
  #     "Decrypt",
  #     "Delete",
  #     "Encrypt",
  #     "Get",
  #     "Import",
  #     "List",
  #     "Purge",
  #     "Recover",
  #     "Restore",
  #     "Sign",
  #     "UnwrapKey",
  #     "Update",
  #     "Verify",
  #     "WrapKey",
  #   ]

  #   secret_permissions = [
  #     "Backup",
  #     "Delete",
  #     "Get",
  #     "List",
  #     "Purge",
  #     "Recover",
  #     "Restore",
  #     "Set",
  #   ]
  #}
}

# resource "azurerm_key_vault_secret" "password" {
#   name         = "my-password"
#   value        = acme_certificate.cert.certificate_p12_password
#   key_vault_id = azurerm_key_vault.kv.id
# }

resource "azurerm_key_vault_access_policy" "key_vault_default_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  lifecycle {
    create_before_destroy = false
  }
  certificate_permissions = [
    "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
  ]
  key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey"
  ]
  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]
  storage_permissions = [
    "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
  ]

}

resource "azurerm_key_vault_access_policy" "identity_key_vault_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.identity.principal_id
  secret_permissions = [
    "Get", "List", "Recover"
  ]
}

resource "azurerm_dns_zone" "my-public-dns" {
  name                = "mydavidcloud.xyz"
  resource_group_name = azurerm_resource_group.my-f23-rg.name
}

resource "azurerm_dns_cname_record" "example" {
  name                = "test"
  zone_name           = azurerm_dns_zone.my-public-dns.name
  resource_group_name = azurerm_resource_group.my-f23-rg.name
  ttl                 = 300
  record              = "${random_string.azurerm_traffic_manager_profile_dns_config.result}.trafficmanager.net"
}

# resource "azurerm_key_vault_secret" "my-ssl" {
#   name         = "my-secret"
#   value        = filebase64("./mydavidcloud.pfx")
#   key_vault_id = data.azurerm_key_vault.kv.id
#   # depends_on = [
#   #   azurerm_key_vault.kv.access_policy
#   # ]
# }

#Request a certificate from the ACME server
# resource "acme_certificate" "cert" {
#   account_key_pem           = acme_registration.reg.account_key_pem
#   common_name               = "mydavidcloud.xyz"
#   certificate_p12_password  = random_password.cert.result

#   # Use Azure DNS as the DNS challenge provider
#   dns_challenge {
#     provider = "azure"
#     config = {
#       AZURE_SUBSCRIPTION_ID  = data.azurerm_client_config.current.subscription_id
#       AZURE_TENANT_ID        = data.azurerm_client_config.current.tenant_id
#       AZURE_RESOURCE_GROUP   = azurerm_resource_group.my-f23-rg.name
#       AZURE_ZONE_NAME        = "mydavidcloud.xyz"
#       AZURE_CLIENT_SECRET    = "fvG8Q~eMUrIb8D34ogjAHVxN1TfC2rTYOF4MUdru"
#       AZURE_CLIENT_ID        = "ffaa898a-89c1-4cb4-909e-8b71813e143f"
#       AZURE_ENVIRONMENT      = "public"
#     }
#   }
#   depends_on = [azurerm_dns_cname_record.example]
# }

resource "azurerm_key_vault_certificate" "certificate" {
  name         = "mydavidcloudxyz"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_access_policy.key_vault_default_policy]

  certificate {
    contents = filebase64("../stagethree/davidcloud.pfx")
    password = var.vmpass
  }

  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
    lifetime_action {
      action {
        action_type = "EmailContacts"
      }
      trigger {
        days_before_expiry = 10
      }
    }
  }
}
#   certificate {
#     contents = acme_certificate.cert.certificate_p12
#     password = acme_certificate.cert.certificate_p12_password
#   }

#   certificate_policy {
#     issuer_parameters {
#       name = "Unknown"
#     }

#     key_properties {
#       exportable = true
#       key_size   = 2048
#       key_type   = "RSA"
#       reuse_key  = false
#     }

#     secret_properties {
#       content_type = "application/x-pkcs12"
#     }
#   }
# }
