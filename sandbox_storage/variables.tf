variable "sa_name" {
  description = "Name of the storage account"
  type        = string
}

variable "short_name" {
  description = "Explicit short name override when sa_name would exceed Azure's 24-character limit. Auto-derived when null."
  type        = string
  default     = null

  validation {
    condition     = var.short_name == null || can(regex("^[0-9a-z-]*$", var.short_name))
    error_message = "short_name must be kebab-case."
  }
}

