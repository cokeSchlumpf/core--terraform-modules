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
  value       = "${data.azurerm_container_registry.acr.login_server}/${local.image}"
}

output "timestamp_tag" {
  description = "Timestamp tag of deployed image (null when image_tag is set)"
  value       = var.image_tag == null ? module.push_image[0].timestamp_tag : null
}

output "storage_account_name" {
  description = "Name of the app files storage account (if storage = true)"
  value       = var.storage ? module.storage[0].account_name : null
}

output "storage_container_name" {
  description = "Name of the blob container for app file uploads (if storage = true)"
  value       = var.storage ? module.storage[0].container_name : null
}

output "custom_domains" {
  description = "Host names of the app"
  value       = var.custom_domains
}

output "dns_records" {
  description = "DNS records of the custom domains: host, type, name, value, the zone and whether the deployment manages them (false: set them by hand at the registrar)"
  value = flatten([
    for host, zone in local.custom_domains : [
      {
        host    = host
        type    = "CNAME"
        name    = host
        value   = azurerm_linux_web_app.app.default_hostname
        zone    = zone == null ? null : zone.zone
        managed = zone != null
      },
      {
        host    = host
        type    = "TXT"
        name    = "asuid.${host}"
        value   = azurerm_linux_web_app.app.custom_domain_verification_id
        zone    = zone == null ? null : zone.zone
        managed = zone != null
      },
    ]
  ])
}
