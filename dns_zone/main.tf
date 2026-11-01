# The zone holds records other systems depend on (e.g. mail), so it can't be deleted through this module.
resource "azurerm_dns_zone" "zone" {
  name                = var.name
  resource_group_name = var.resource_group_name

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_dns_a_record" "records" {
  for_each = var.records.A

  name                = each.key
  zone_name           = azurerm_dns_zone.zone.name
  resource_group_name = var.resource_group_name
  ttl                 = var.ttl
  records             = each.value
}

resource "azurerm_dns_aaaa_record" "records" {
  for_each = var.records.AAAA

  name                = each.key
  zone_name           = azurerm_dns_zone.zone.name
  resource_group_name = var.resource_group_name
  ttl                 = var.ttl
  records             = each.value
}

resource "azurerm_dns_cname_record" "records" {
  for_each = var.records.CNAME

  name                = each.key
  zone_name           = azurerm_dns_zone.zone.name
  resource_group_name = var.resource_group_name
  ttl                 = var.ttl
  record              = each.value
}

resource "azurerm_dns_mx_record" "records" {
  for_each = var.records.MX

  name                = each.key
  zone_name           = azurerm_dns_zone.zone.name
  resource_group_name = var.resource_group_name
  ttl                 = var.ttl

  dynamic "record" {
    for_each = each.value

    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }
}

resource "azurerm_dns_txt_record" "records" {
  for_each = var.records.TXT

  name                = each.key
  zone_name           = azurerm_dns_zone.zone.name
  resource_group_name = var.resource_group_name
  ttl                 = var.ttl

  dynamic "record" {
    for_each = each.value

    content {
      value = record.value
    }
  }
}

resource "azurerm_dns_srv_record" "records" {
  for_each = var.records.SRV

  name                = each.key
  zone_name           = azurerm_dns_zone.zone.name
  resource_group_name = var.resource_group_name
  ttl                 = var.ttl

  dynamic "record" {
    for_each = each.value

    content {
      priority = record.value.priority
      weight   = record.value.weight
      port     = record.value.port
      target   = record.value.target
    }
  }
}

resource "azurerm_dns_ns_record" "delegations" {
  for_each = var.delegations

  name                = each.key
  zone_name           = azurerm_dns_zone.zone.name
  resource_group_name = var.resource_group_name
  ttl                 = var.ttl
  records             = each.value
}
