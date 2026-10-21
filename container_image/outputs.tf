output "image_name" {
  description = "The image name"
  value       = var.image_name
}

output "image_tag" {
  description = "The image tag"
  value       = var.image_tag
}

output "local_image" {
  description = "Full local image reference (name:tag)"
  value       = local.local_image
}
