variable "app_name" {
  description = "App name (also used as image name)"
  type        = string
}

variable "image_tag" {
  description = "Tag of an image already pushed to the ACR as <app_name>:<image_tag>; when null, the image is built and pushed with Podman"
  type        = string
  default     = null
}

variable "environment" {
  description = "Stage of the app, set as APP__ENVIRONMENT"
  type        = string
  default     = "sandbox"
}

variable "health_check_path" {
  description = "Path App Service checks for the health of the app, e.g. /health; no health check when null"
  type        = string
  default     = null
}

variable "docker_context_path" {
  description = "Path to directory containing Dockerfile (default: parent of deployment/)"
  type        = string
  default     = null
}

variable "dockerfile_path" {
  description = "Dockerfile path relative to context"
  type        = string
  default     = "Dockerfile"
}

variable "app_settings" {
  description = "Additional app settings"
  type        = map(string)
  default     = {}
}

variable "websites_port" {
  description = "Container port to expose"
  type        = number
  default     = 8501
}

variable "git_token" {
  description = "Git token for private repository access during build"
  type        = string
  sensitive   = true
  default     = ""
}

variable "database" {
  description = "Create a database for this app and inject connection environment variables"
  type        = bool
  default     = false
}

variable "storage" {
  description = "Create a storage account for this app and inject connection environment variables"
  type        = bool
  default     = false
}

variable "short_name" {
  description = "Short name override for the storage account name segment when app_name would exceed Azure's 24-character limit. Auto-derived from app_name when null."
  type        = string
  default     = null
}
