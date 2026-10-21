variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "max_size_gb" {
  description = "Maximum database size in GB"
  type        = number
  default     = 32
}

variable "auto_pause_delay_in_minutes" {
  description = "Minutes of inactivity before auto-pause (use -1 to disable)"
  type        = number
  default     = 60
}

variable "min_capacity" {
  description = "Minimum vCore capacity (0.5 to 40)"
  type        = number
  default     = 0.5
}
