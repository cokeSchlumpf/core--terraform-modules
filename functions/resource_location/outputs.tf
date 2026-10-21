output "shortname" {
  value       = local.locations[var.location]
  description = "The short abbreviation for the location to be used in resource names."
}

output "longname" {
  value       = local.locations_long[var.location]
  description = "The long name for the location, some resources require this name as location value."
}