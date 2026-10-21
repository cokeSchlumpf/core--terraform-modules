locals {
  # Build the additional build args string for podman (user-provided)
  build_args_list = [for k, v in var.build_args : "--build-arg=${k}=${v}"]
  build_args_str  = join(" ", local.build_args_list)

  # Full local image reference
  local_image = "${var.image_name}:${var.image_tag}"

  # Dockerfile path within the context
  dockerfile_full_path = "${var.docker_context_path}/${var.dockerfile_path}"
}

resource "null_resource" "build_image" {
  triggers = {
    # Rebuild when Dockerfile changes
    dockerfile_hash = filesha256(local.dockerfile_full_path)
    # Rebuild when image name or tag changes
    image_name = var.image_name
    image_tag  = var.image_tag
    # Rebuild when build args change
    build_args = jsonencode(var.build_args)
    # Rebuild when platform changes
    platform = var.platform
    # Optional: force rebuild on every apply
    always_rebuild = var.always_rebuild ? timestamp() : "static"
  }

  provisioner "local-exec" {
    working_dir = var.docker_context_path
    command     = <<-EOT
      # Capture Git info for version string
      GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
      GIT_COMMIT=$(git rev-parse --short HEAD)
      APP_VERSION="$GIT_BRANCH ($GIT_COMMIT)"

      # Build image with platform, git info, and additional build args
      podman build \
        --platform ${var.platform} \
        -f ${var.dockerfile_path} \
        -t ${local.local_image} \
        --build-arg GIT_TOKEN=${var.git_token} \
        --build-arg APP__VERSION="$APP_VERSION" \
        ${local.build_args_str} \
        .
    EOT
  }
}
