# Sandbox Image Module

Pushes a local container image to the sandbox Azure Container Registry (ACR) with multiple tags (source, timestamp, latest).

## Prerequisites

- [Podman](https://podman.io/) installed and configured
- Azure subscription access with permissions to the sandbox ACR
- Terraform Azure provider configured

## Usage

```hcl
module "push_to_acr" {
  source = "../sandbox_image"

  local_image     = "my-app:latest"
  repository_name = "my-app"  # Optional, defaults to image name
}
```

### With container_image module

```hcl
module "build" {
  source = "../container_image"

  docker_context_path = "${path.root}/../app"
  image_name          = "my-app"
}

module "push" {
  source = "../sandbox_image"

  local_image = module.build.local_image

  depends_on = [module.build]
}
```

## Features

- Automatically logs into the sandbox ACR using admin credentials
- Pushes images with three tags:
  - Original source tag
  - Timestamp tag (YYYYMMDD-hhmmss format)
  - `latest` tag
- Retrieves ACR configuration from sandbox properties

## Inputs

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `local_image` | string | Yes | - | Local image to push (name:tag format) |
| `repository_name` | string | No | `null` | ACR repository name (defaults to image name extracted from local_image) |

## Outputs

| Output | Description |
|--------|-------------|
| `acr_login_server` | ACR login server URL |
| `repository_name` | Repository name in ACR |
| `acr_image` | Full ACR reference with source tag |
| `acr_image_latest` | Full ACR reference with :latest tag |
| `acr_image_timestamped` | Full ACR reference with timestamp tag |
| `timestamp_tag` | The generated timestamp tag (YYYYMMDD-hhmmss) |
