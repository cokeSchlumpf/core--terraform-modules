# Get sandbox properties for ACR configuration
module "sandbox_properties" {
  source = "../functions/sandbox_properties"
}

# Look up the Azure Container Registry
data "azurerm_container_registry" "acr" {
  name                = module.sandbox_properties.acr__name
  resource_group_name = module.sandbox_properties.rg_apps__name
}

locals {
  # Generate timestamp tag (YYYYMMDD-hhmmss format)
  timestamp_tag = formatdate("YYYYMMDD-hhmmss", timestamp())

  # Parse the local image to extract name and tag
  image_parts = split(":", var.local_image)
  source_name = local.image_parts[0]
  source_tag  = length(local.image_parts) > 1 ? local.image_parts[1] : "latest"

  # Determine repository name
  repository_name = var.repository_name != null ? var.repository_name : local.source_name

  # ACR login server
  acr_login_server = data.azurerm_container_registry.acr.login_server

  # Tags to push: source tag, timestamp tag, and latest
  tags_to_push = distinct([local.source_tag, local.timestamp_tag, "latest"])

  # Build ACR image references
  acr_image             = "${local.acr_login_server}/${local.repository_name}:${local.source_tag}"
  acr_image_latest      = "${local.acr_login_server}/${local.repository_name}:latest"
  acr_image_timestamped = "${local.acr_login_server}/${local.repository_name}:${local.timestamp_tag}"

  # Generate tag and push commands
  tag_commands = [
    for tag in local.tags_to_push :
    "podman tag ${var.local_image} ${local.acr_login_server}/${local.repository_name}:${tag}"
  ]

  push_commands = [
    for tag in local.tags_to_push :
    "podman push ${local.acr_login_server}/${local.repository_name}:${tag}"
  ]
}

resource "null_resource" "push_image" {
  triggers = {
    # Always trigger due to timestamp
    timestamp   = local.timestamp_tag
    local_image = var.local_image
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Login to ACR
      podman login ${local.acr_login_server} \
        --username ${data.azurerm_container_registry.acr.admin_username} \
        --password "${data.azurerm_container_registry.acr.admin_password}"

      # Tag images for ACR
      ${join("\n      ", local.tag_commands)}

      # Push images to ACR
      ${join("\n      ", local.push_commands)}

      # Logout from ACR
      podman logout ${local.acr_login_server}
    EOT
  }
}
