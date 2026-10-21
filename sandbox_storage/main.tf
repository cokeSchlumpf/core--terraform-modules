module "sandbox_properties" {
  source = "../functions/sandbox_properties"
}

module "sa_name" {
  source        = "../functions/resource_name"
  name          = var.sa_name
  short_name    = var.short_name
  environment   = "sbx"
  location      = module.sandbox_properties.location
  resource_type = "StorageAccount"
}

data "azurerm_key_vault" "apps" {
  name                = module.sandbox_properties.kv_apps__name
  resource_group_name = module.sandbox_properties.rg_apps__name
}

resource "azurerm_storage_account" "app_data" {
  name                     = module.sa_name.name
  resource_group_name      = module.sandbox_properties.rg_apps__name
  location                 = module.sandbox_properties.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "app_data" {
  name                  = "appdata"
  storage_account_id    = azurerm_storage_account.app_data.id
  container_access_type = "private"
}

resource "azurerm_key_vault_secret" "storage_account_key" {
  name         = "${var.sa_name}-storage-key"
  value        = azurerm_storage_account.app_data.primary_access_key
  key_vault_id = data.azurerm_key_vault.apps.id
}
