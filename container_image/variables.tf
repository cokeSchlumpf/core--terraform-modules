variable "docker_context_path" {
  description = "Path to directory containing Dockerfile"
  type        = string
}

variable "image_name" {
  description = "Image name (without registry/tag)"
  type        = string
}

variable "image_tag" {
  description = "Tag for the image"
  type        = string
  default     = "latest"
}

variable "build_args" {
  description = "Build arguments to pass to podman build"
  type        = map(string)
  default     = {}
}

variable "platform" {
  description = "Target platform for the image"
  type        = string
  default     = "linux/amd64"
}

variable "dockerfile_path" {
  description = "Dockerfile path relative to context"
  type        = string
  default     = "Dockerfile"
}

variable "always_rebuild" {
  description = "Force rebuild on every apply"
  type        = bool
  default     = false
}

variable "git_token" {
  description = "Git token for private repository access during build"
  type        = string
  sensitive   = true
  default     = ""
}
