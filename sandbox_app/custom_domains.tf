# Custom domains: per host name the DNS records (in a zone of the sandbox, else set by hand at the registrar), the
# hostname binding and an App Service Managed Certificate, which Azure renews by itself.

locals {
  dns_zones = module.sandbox_properties.dns_zones

  # Host name → the deepest zone of the sandbox it lies in (null: its records are set by hand)
  custom_domain_zone_candidates = {
    for host in var.custom_domains : host => [for zone in keys(local.dns_zones) : zone if endswith(host, ".${zone}")]
  }

  custom_domain_zones = {
    for host, zones in local.custom_domain_zone_candidates : host => (
      length(zones) == 0 ? null : [for zone in zones : zone if length(zone) == max([for z in zones : length(z)]...)][0]
    )
  }

  custom_domains = {
    for host, zone in local.custom_domain_zones : host => zone == null ? null : { zone = zone, resource_group = local.dns_zones[zone] }
  }

  # Host names whose records the deployment creates, with their name relative to the zone
  managed_custom_domains = {
    for host, zone in local.custom_domains : host => merge(zone, { name = trimsuffix(host, ".${zone.zone}") }) if zone != null
  }

  public_url = length(var.custom_domains) > 0 ? "https://${var.custom_domains[0]}" : "https://${var.app_name}.azurewebsites.net"
}

resource "azurerm_dns_cname_record" "custom_domains" {
  for_each = local.managed_custom_domains

  name                = each.value.name
  zone_name           = each.value.zone
  resource_group_name = each.value.resource_group
  ttl                 = 3600
  record              = azurerm_linux_web_app.app.default_hostname
}

# Proves to App Service that the host name belongs to this subscription (and prevents subdomain takeover)
resource "azurerm_dns_txt_record" "custom_domains" {
  for_each = local.managed_custom_domains

  name                = "asuid.${each.value.name}"
  zone_name           = each.value.zone
  resource_group_name = each.value.resource_group
  ttl                 = 3600

  record {
    value = azurerm_linux_web_app.app.custom_domain_verification_id
  }
}

resource "azurerm_app_service_custom_hostname_binding" "custom_domains" {
  for_each = toset(var.custom_domains)

  hostname            = each.key
  app_service_name    = azurerm_linux_web_app.app.name
  resource_group_name = azurerm_linux_web_app.app.resource_group_name

  depends_on = [azurerm_dns_cname_record.custom_domains, azurerm_dns_txt_record.custom_domains]

  lifecycle {
    # Set by azurerm_app_service_certificate_binding
    ignore_changes = [ssl_state, thumbprint]

    precondition {
      condition     = !contains(keys(local.dns_zones), each.key)
      error_message = "${each.key} is a zone itself; custom domains must be subdomains, e.g. <name>.${each.key}."
    }
  }
}

resource "azurerm_app_service_managed_certificate" "custom_domains" {
  for_each = toset(var.custom_domains)

  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.custom_domains[each.key].id
}

resource "azurerm_app_service_certificate_binding" "custom_domains" {
  for_each = toset(var.custom_domains)

  hostname_binding_id = azurerm_app_service_custom_hostname_binding.custom_domains[each.key].id
  certificate_id      = azurerm_app_service_managed_certificate.custom_domains[each.key].id
  ssl_state           = "SniEnabled"
}
