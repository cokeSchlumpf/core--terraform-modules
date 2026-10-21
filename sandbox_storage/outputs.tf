output "account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.app_data.name
}

output "container_name" {
  description = "Name of the blob container for app file uploads"
  value       = azurerm_storage_container.app_data.name
}

output "account_key_secret_name" {
  description = "Name of the Key Vault secret containing the storage account primary access key"
  value       = azurerm_key_vault_secret.storage_account_key.name
}

output "account_key" {
  description = "Primary access key of the storage account"
  value       = azurerm_storage_account.app_data.primary_access_key
  sensitive   = true
}
