output "app_url" {
  description = "HTTPS URL of deployed app"
  value       = "https://${azurerm_linux_web_app.app.default_hostname}"
}

output "app_name" {
  description = "Name of the deployed app"
  value       = azurerm_linux_web_app.app.name
}

output "acr_image" {
  description = "Full ACR image reference used"
  value       = module.push_image.acr_image_timestamped
}

output "timestamp_tag" {
  description = "Timestamp tag of deployed image"
  value       = module.push_image.timestamp_tag
}

output "storage_account_name" {
  description = "Name of the app files storage account (if storage = true)"
  value       = var.storage ? module.storage[0].account_name : null
}

output "storage_container_name" {
  description = "Name of the blob container for app file uploads (if storage = true)"
  value       = var.storage ? module.storage[0].container_name : null
}
