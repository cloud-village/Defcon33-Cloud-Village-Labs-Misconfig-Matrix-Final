# Top 50 Azure Misconfigurations - Lab Deployment
# This intentionally misconfigures resources for training purposes.

provider "azurerm" {
  features {}  # Empty features block
  subscription_id = "6f44395b-b9f9-450c-a20f-f354280c58bd"
  tenant_id       = "8c2eeb66-1269-4b9f-925a-292cc315aa0f"
}

resource "azurerm_resource_group" "lab" {
  name     = "misconfig-lab-rg"
  location = "West US"
}

resource "random_id" "rand" {
  byte_length = 4
}

# Existing 8 misconfigurations remain unchanged

# 9. Storage account with unrestricted default network rule
resource "azurerm_storage_account" "unrestricted_default_network" {
  name                     = "defaultnetopen${random_id.rand.hex}"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Allow" # Misconfiguration
    bypass                     = ["AzureServices"]
    ip_rules                   = []
  }
}

# 10. PostgreSQL server allowing all Azure services
resource "azurerm_postgresql_flexible_server" "pg_allow_azure" {
  name                   = "pgflexmisconfig"
  location               = azurerm_resource_group.lab.location
  resource_group_name    = azurerm_resource_group.lab.name
  sku_name               = "B_Standard_B1ms" # Fixed SKU name
  version                = "13"
  administrator_login    = "psqladmin"
  administrator_password = "P@ssword123!"

  storage_mb             = 32768
  zone                   = "1"

  delegated_subnet_id    = null
  private_dns_zone_id    = null

  public_network_access_enabled = true
}


# 12. Azure SQL with auditing disabled
resource "azurerm_mssql_server_extended_auditing_policy" "audit_disabled" {
  server_id                               = azurerm_mssql_server.sql_open.id
  storage_endpoint                        = "https://${azurerm_storage_account.public_blob.name}.blob.core.windows.net/"
  storage_account_access_key              = azurerm_storage_account.public_blob.primary_access_key
  retention_in_days                       = 0
  enabled                                = false
}

# 13. Azure Key Vault without logging
resource "azurerm_key_vault" "no_logging" {
  name                        = "kvnologs${random_id.rand.hex}"
  location                    = azurerm_resource_group.lab.location
  resource_group_name         = azurerm_resource_group.lab.name
  tenant_id                   = "8c2eeb66-1269-4b9f-925a-292cc315aa0f"
  sku_name                    = "standard"
  soft_delete_retention_days  = 7 # Fixed configuration
  purge_protection_enabled    = false
}

# 14. App Service with TLS < 1.2
resource "azurerm_linux_web_app" "tls_weak" {
  name                = "weak-tls-app"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  service_plan_id     = azurerm_service_plan.web_plan.id

  site_config {
    minimum_tls_version = "1.0"
  }

  https_only = false
}

# 15. Cosmos DB without private endpoint
resource "azurerm_cosmosdb_account" "no_private_endpoint" {
  name                = "cosmosnopvt${random_id.rand.hex}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Eventual"
  }

  geo_location {
    location          = azurerm_resource_group.lab.location
    failover_priority = 0
  }
}

# Misconfiguration 16. Azure App Service with HTTP2 disabled
resource "azurerm_linux_web_app" "no_http2" {
  name                = "nohttp2app"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  service_plan_id     = azurerm_service_plan.web_plan.id

  site_config {
    http2_enabled = false
  }

  https_only = false
}

# Misconfiguration 17. SQL Server with low TLS version
resource "azurerm_mssql_server" "low_tls_sql" {
  name                         = "lowtlssqlserver"
  resource_group_name          = azurerm_resource_group.lab.name
  location                     = azurerm_resource_group.lab.location
  version                      = "12.0"
  minimum_tls_version          = "1.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd123!"
}

# Misconfiguration 18. Disabled Network Watcher
resource "azurerm_network_watcher" "disabled" {
  name                = "disablednw"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = { enabled = "false" }
}

# Misconfiguration 19. VM without endpoint protection
resource "azurerm_virtual_machine" "no_antivirus" {
  name                  = "vmnoav"
  location              = azurerm_resource_group.lab.location
  resource_group_name   = azurerm_resource_group.lab.name
  network_interface_ids = []
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = "vmnoav"
    admin_username = "azureuser"
    admin_password = "VmP@ssword123"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# Misconfiguration 20. Key Vault without access policies
resource "azurerm_key_vault" "no_policies" {
  name                       = "kvnopolicy${random_id.rand.hex}"
  location                    = azurerm_resource_group.lab.location
  resource_group_name         = azurerm_resource_group.lab.name
  tenant_id                   = "00000000-0000-0000-0000-000000000000"
  sku_name                    = "standard"
  soft_delete_retention_days  = 7  # Replace soft_delete_enabled
  purge_protection_enabled    = false
}

# Misconfiguration 21. App Insights not configured
resource "azurerm_application_insights" "missing_config" {
  name                = "missingappinsights${random_id.rand.hex}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  application_type    = "web"
  retention_in_days   = 30
  disable_ip_masking  = true
}

# Misconfiguration 22. Diagnostic settings not capturing categories
resource "azurerm_monitor_diagnostic_setting" "bad_categories" {
  name               = "nocats"
  target_resource_id = azurerm_linux_web_app.no_http2.id
  storage_account_id = azurerm_storage_account.public_blob.id

  enabled_metric {
    category = "AllMetrics"
  }
}

# Misconfiguration 23. Defender for DNS not enabled (simulated)

# Misconfiguration 24. Azure Policy assignment logging not configured
resource "azurerm_monitor_activity_log_alert" "no_policy_logging" {
  name                = "nopolicyevents"
  resource_group_name = azurerm_resource_group.lab.name
  scopes              = [azurerm_resource_group.lab.id]
  location            = azurerm_resource_group.lab.location

  criteria {
    category = "Policy"
    operation_name = "Microsoft.Authorization/policyAssignments/write"
  }
}

# Misconfiguration 25. SQL server firewall rule allows all IPs
resource "azurerm_mssql_firewall_rule" "allow_all_sql" {
  name             = "AllowAll2"
  server_id        = azurerm_mssql_server.low_tls_sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

# Misconfiguration 26. Missing alert for NSG changes
resource "azurerm_monitor_activity_log_alert" "no_nsg_alert" {
  name                = "nonsgalert"
  resource_group_name = azurerm_resource_group.lab.name
  scopes              = [azurerm_resource_group.lab.id]
  location            = azurerm_resource_group.lab.location

  criteria {
    category        = "Administrative"
    operation_name  = "Microsoft.Network/networkSecurityGroups/delete"
  }
}

# Misconfiguration 27. No audit log for SQL firewall rule deletes
resource "azurerm_monitor_activity_log_alert" "no_sql_fr_del" {
  name                = "nosqlfrdel"
  resource_group_name = azurerm_resource_group.lab.name
  scopes              = [azurerm_resource_group.lab.id]
  location            = azurerm_resource_group.lab.location

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Sql/servers/firewallRules/delete"
  }
}

# Misconfiguration 28. Defender for Storage not configured (simulated)


# Misconfiguration 29. PostgreSQL without SSL enforced
resource "azurerm_postgresql_flexible_server_configuration" "pg_nossl" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.pg_allow_azure.id
  value     = "off"
}

# Misconfiguration 30. App with HTTP only (no HTTPS redirect)
resource "azurerm_linux_web_app" "http_only" {
  name                = "httponlywebapp"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  service_plan_id     = azurerm_service_plan.web_plan.id
  https_only         = false

  site_config {
    always_on = false  # Add required site_config block
  }
}

# Add missing Service Plan resource
resource "azurerm_service_plan" "web_plan" {
  name                = "misconfig-service-plan"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  os_type            = "Linux"
  sku_name           = "B1"
}

# Add missing Storage Account
resource "azurerm_storage_account" "public_blob" {
  name                     = "publicblob${random_id.rand.hex}"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Replace allow_blob_public_access with public_network_access_enabled
  public_network_access_enabled = true
  
  blob_properties {
    # Configure container public access
    container_delete_retention_policy {
      days = 7
    }
  }
}

# Add missing SQL Server
resource "azurerm_mssql_server" "sql_open" {
  name                         = "sqlopen${random_id.rand.hex}"
  resource_group_name          = azurerm_resource_group.lab.name
  location                     = azurerm_resource_group.lab.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd123!"
}



# Add missing web app
resource "azurerm_linux_web_app" "insecure_webapp" {
  name                = "insecure-webapp-${random_id.rand.hex}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  service_plan_id     = azurerm_service_plan.web_plan.id

  site_config {}
}



# Add missing SQL Firewall rule
resource "azurerm_mssql_firewall_rule" "open_sql" {
  name             = "AllowAll"
  server_id        = azurerm_mssql_server.sql_open.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}


output "sql_firewall" {
  value = azurerm_mssql_firewall_rule.open_sql.id
}

output "storage_blob_url" {
  value = "https://${azurerm_storage_account.public_blob.name}.blob.core.windows.net/"
}

output "webapp_url" {
  value = azurerm_linux_web_app.insecure_webapp.default_hostname
}
