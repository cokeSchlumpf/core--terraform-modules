# Sandbox App Module

Orchestrates building a container image, pushing it to ACR, and deploying it as an Azure App Service container app in the sandbox environment.

## Prerequisites

- [Podman](https://podman.io/) installed and configured
- Azure subscription access with permissions to the sandbox resources
- Terraform Azure provider configured
- Existing sandbox infrastructure (App Service Plan, ACR, Resource Group)

## Usage

```hcl
module "my_app" {
  source = "git::https://github.com/cokeSchlumpf/core--terraform-modules.git//sandbox_app?ref=versions/1"

  app_name            = "my-streamlit-app"
  docker_context_path = "${path.root}/../app"

  app_settings = {
    "MY_CONFIG_VALUE" = "production"
  }

  websites_port = 8501
}

output "app_url" {
  value = module.my_app.app_url
}
```

### Minimal usage (from deployment/ directory)

```hcl
module "my_app" {
  source = "git::https://github.com/cokeSchlumpf/core--terraform-modules.git//sandbox_app?ref=versions/1"

  app_name = "my-app"
}
```

When `docker_context_path` is not specified, it defaults to the parent directory of the Terraform root (assumes a `deployment/` subdirectory structure).

## Features

- **Full deployment pipeline**: Build, push, and deploy in a single module
- **Automatic image tagging**: Uses timestamp tags for each deployment
- **Container logging**: HTTP logs enabled with 7-day retention
- **HTTPS only**: Enforces secure connections
- **Configurable app settings**: Merge custom settings with sensible defaults

## Architecture

This module composes two other modules:

1. **container_image**: Builds the Docker image locally using Podman
2. **sandbox_image**: Pushes the image to the sandbox ACR with multiple tags

Then deploys the timestamped image to Azure App Service.

## Inputs

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `app_name` | string | Yes | - | App name (also used as image name) |
| `docker_context_path` | string | No | `null` | Path to directory containing Dockerfile (defaults to parent of deployment/) |
| `dockerfile_path` | string | No | `"Dockerfile"` | Dockerfile path relative to context |
| `app_settings` | map(string) | No | `{}` | Additional app settings |
| `websites_port` | number | No | `8501` | Container port to expose |
| `git_token` | string | No | `""` | Git token for private repository access during build (sensitive) |
| `database` | bool | No | `false` | Create a serverless SQL database and inject `APP__DATABASE__MSSQL__*` settings |
| `storage` | bool | No | `false` | Create a storage account and inject `APP__STORAGE__AZURE__*` settings |
| `short_name` | string | No | `null` | Storage account name override when `app_name` is too long |

## Outputs

| Output | Description |
|--------|-------------|
| `app_url` | HTTPS URL of deployed app |
| `app_name` | Name of the deployed app |
| `acr_image` | Full ACR image reference used |
| `timestamp_tag` | Timestamp tag of deployed image |

## Default App Settings

The following app settings are automatically configured:

| Setting | Value | Description |
|---------|-------|-------------|
| `WEBSITES_PORT` | `<websites_port>` | Container port |
| `WEBSITES_ENABLE_APP_SERVICE_STORAGE` | `false` | Disable persistent storage |
| `DOCKER_ENABLE_CI` | `true` | Enable container CI |
| `WEBSITES_CONTAINER_START_TIME_LIMIT` | `600` | 10-minute startup timeout |
| `APP__ENVIRONMENT` | `sandbox` | Environment identifier |
| `APP__MODELS__AZURE_OPENAI__API_KEY` / `__ENDPOINT` | from Key Vault / sandbox | Azure OpenAI access |
| `APP__OCR__AZURE__API_KEY` / `__ENDPOINT` | from Key Vault / sandbox | Document Intelligence access |
