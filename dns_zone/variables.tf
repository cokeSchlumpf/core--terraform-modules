variable "name" {
  description = "Name of the DNS zone, e.g. casesight.io or sbx.casesight.io"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group of the zone"
  type        = string
}

variable "records" {
  description = <<EOT
    Records of the zone by type, each a map from the relative name ("@" for the zone itself) to its values:
    A and AAAA a list of addresses, CNAME one host name, MX a list of {preference, exchange}, TXT a list of strings,
    SRV a list of {priority, weight, port, target}.
  EOT
  type = object({
    A     = optional(map(list(string)), {})
    AAAA  = optional(map(list(string)), {})
    CNAME = optional(map(string), {})
    MX    = optional(map(list(object({ preference = number, exchange = string }))), {})
    TXT   = optional(map(list(string)), {})
    SRV   = optional(map(list(object({ priority = number, weight = number, port = number, target = string }))), {})
  })
  default = {}

  validation {
    condition     = !contains(keys(var.records.CNAME), "@")
    error_message = "The zone itself (\"@\") can't have a CNAME record."
  }
}

variable "delegations" {
  description = "Child zones delegated by NS records: relative name (e.g. \"sbx\") → name servers of the child zone"
  type        = map(list(string))
  default     = {}
}

variable "ttl" {
  description = "TTL of all records in seconds"
  type        = number
  default     = 3600
}

variable "tags" {
  description = "Tags of the zone"
  type        = map(string)
  default     = {}
}
