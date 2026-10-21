variable "local_image" {
  description = "Local image to push (name:tag format)"
  type        = string
}

variable "repository_name" {
  description = "ACR repository name (defaults to image name extracted from local_image)"
  type        = string
  default     = null
}
