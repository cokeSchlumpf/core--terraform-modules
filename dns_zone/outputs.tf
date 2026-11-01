output "id" {
  description = "Resource ID of the zone"
  value       = azurerm_dns_zone.zone.id
}

output "name" {
  description = "Name of the zone"
  value       = azurerm_dns_zone.zone.name
}

output "resource_group_name" {
  description = "Resource group of the zone"
  value       = azurerm_dns_zone.zone.resource_group_name
}

output "name_servers" {
  description = "Name servers of the zone, to set at the registrar or in the parent zone"
  value       = tolist(azurerm_dns_zone.zone.name_servers)
}
