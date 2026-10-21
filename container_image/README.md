# Container Image Module

Builds container images locally using Podman with support for build arguments, platform targeting, and Git version injection.

## Prerequisites

- [Podman](https://podman.io/) installed and configured
- Git (for automatic version injection)

## Usage

```hcl
module "my_image" {
  source = "../container_image"

  docker_context_path = "${path.root}/../app"
  image_name          = "my-app"
  image_tag           = "v1.0.0"

  build_args = {
    NODE_ENV = "production"
  }
}
```

## Features

- Automatically injects `APP__VERSION` build arg with Git branch and commit info
- Supports custom build arguments
- Configurable target platform (default: `linux/amd64`)
- Smart rebuild triggers based on Dockerfile changes, build args, and platform
- Optional `git_token` for accessing private repositories during build

## Inputs

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `docker_context_path` | string | Yes | - | Path to directory containing Dockerfile |
| `image_name` | string | Yes | - | Image name (without registry/tag) |
| `image_tag` | string | No | `"latest"` | Tag for the image |
| `build_args` | map(string) | No | `{}` | Build arguments to pass to podman build |
| `platform` | string | No | `"linux/amd64"` | Target platform for the image |
| `dockerfile_path` | string | No | `"Dockerfile"` | Dockerfile path relative to context |
| `always_rebuild` | bool | No | `false` | Force rebuild on every apply |
| `git_token` | string | No | `""` | Git token for private repository access during build (sensitive) |

## Outputs

| Output | Description |
|--------|-------------|
| `image_name` | The image name |
| `image_tag` | The image tag |
| `local_image` | Full local image reference (name:tag) |
