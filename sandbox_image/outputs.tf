output "acr_login_server" {
  description = "ACR login server URL"
  value       = local.acr_login_server
}

output "repository_name" {
  description = "Repository name in ACR"
  value       = local.repository_name
}

output "acr_image" {
  description = "Full ACR reference with source tag"
  value       = local.acr_image
}

output "acr_image_latest" {
  description = "Full ACR reference with :latest tag"
  value       = local.acr_image_latest
}

output "acr_image_timestamped" {
  description = "Full ACR reference with timestamp tag"
  value       = local.acr_image_timestamped
}

output "timestamp_tag" {
  description = "The generated timestamp tag"
  value       = local.timestamp_tag
}
