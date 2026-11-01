# DNS Zone Module

An Azure DNS zone with its records and the delegations of its child zones. Used by the environment configurations (`10--sandbox` in `core--platform`) for domains delegated from their registrar (e.g. Strato) and for the child zone of each environment, in which `sandbox_app` creates the records of the apps.

The zone can't be deleted through the module (`prevent_destroy`): it holds records other systems depend on, e.g. mail. Records of apps are not declared here; `sandbox_app` creates them in the child zone.

## Usage

```hcl
module "dns_example" {
  source = "git::https://github.com/cokeSchlumpf/core--terraform-modules.git//dns_zone?ref=versions/1"

  name                = "example.org"
  resource_group_name = azurerm_resource_group.dns.name

  records = {
    MX    = { "@" = [{ preference = 5, exchange = "mx.example.net" }] }
    TXT   = { "_dmarc" = ["v=DMARC1;p=reject;"] }
    CNAME = { "www" = "example.org" }
  }

  # Child zone, e.g. of an environment
  delegations = { "sbx" = module.dns_sbx_example.name_servers }
}

module "dns_sbx_example" {
  source = "git::https://github.com/cokeSchlumpf/core--terraform-modules.git//dns_zone?ref=versions/1"

  name                = "sbx.example.org"
  resource_group_name = azurerm_resource_group.dns.name
}
```

After the first apply, set the `name_servers` of the top zone at the registrar. Before that, compare its records with those the registrar serves (`dig @<azure name server> <type> <name>` against `dig @1.1.1.1 <type> <name>`), so nothing stops working when the name servers are switched.

## Inputs

| Name | Description | Default |
| --- | --- | --- |
| `name` | Name of the zone | |
| `resource_group_name` | Resource group of the zone | |
| `records` | Records by type (`A`, `AAAA`, `CNAME`, `MX`, `TXT`, `SRV`), each a map from the relative name (`@` for the zone itself) to its values | `{}` |
| `delegations` | Child zones: relative name → name servers | `{}` |
| `ttl` | TTL of all records in seconds | `3600` |
| `tags` | Tags of the zone | `{}` |

## Outputs

| Name | Description |
| --- | --- |
| `id` | Resource ID of the zone |
| `name` | Name of the zone |
| `resource_group_name` | Resource group of the zone |
| `name_servers` | Name servers of the zone |
