variable "name" {
  description = "The full kebab-case name to shorten."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-z-]*$", var.name))
    error_message = "name must be kebab-case."
  }
}

variable "short_name" {
  description = "Explicit short name override. Used as-is when the name exceeds max_length."
  type        = string
  default     = null

  validation {
    condition     = var.short_name == null || can(regex("^[0-9a-z-]*$", var.short_name))
    error_message = "short_name must be kebab-case."
  }
}

variable "max_length" {
  description = "Maximum character length of the output (hyphens excluded)."
  type        = number
  default     = 8
}
