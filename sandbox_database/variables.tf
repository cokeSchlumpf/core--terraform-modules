variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "environment" {
  description = "Stage of the database; uat and prd protect it from being destroyed, see prevent_destroy"
  type        = string
  default     = "sandbox"
}

variable "sku_name" {
  description = "Fixed tier of the database, e.g. S0 (about 15 EUR a month). No serverless tiers: an app that polls keeps them from pausing, and they cost more than ten times as much."
  type        = string
  default     = "S0"

  validation {
    condition     = !startswith(var.sku_name, "GP_S_") && !startswith(var.sku_name, "HS_S_")
    error_message = "Serverless tiers aren't supported: an app that polls keeps them from pausing."
  }
}

variable "max_size_gb" {
  description = "Maximum database size in GB; S0 includes 250"
  type        = number
  default     = 250
}

variable "prevent_destroy" {
  description = "Refuse to destroy the database; by default only if environment is uat or prd"
  type        = bool
  default     = null
}
