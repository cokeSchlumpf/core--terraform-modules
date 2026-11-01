# Sandbox App Module

Orchestrates building a container image, pushing it to ACR, and deploying it as an Azure App Service container app in the sandbox environment. With `image_tag`, it deploys an image already pushed to the ACR (e.g. by a GitHub workflow) instead of building one.

## Prerequisites

- [Podman](https://podman.io/) installed and configured (only without `image_tag`)
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

### Deploying a pushed image (from a workflow)

```hcl
variable "image_tag" {
  type    = string
  default = null
}

module "my_app" {
  source = "git::https://github.com/cokeSchlumpf/core--terraform-modules.git//sandbox_app?ref=versions/1"

  app_name          = "my-app"
  image_tag         = var.image_tag # e.g. "1.2.0", pushed as <acr>/my-app:1.2.0
  environment       = "uat"
  health_check_path = "/health"
  websites_port     = 8000
}
```

`tofu apply -var image_tag=1.2.0` deploys that image without building it; without `image_tag` (a laptop), the module builds and pushes as before.

### Custom domains

```hcl
module "my_app" {
  source = "git::https://github.com/cokeSchlumpf/core--terraform-modules.git//sandbox_app?ref=versions/1"

  app_name       = "my-app"
  custom_domains = ["my-app.sbx.casesight.io"]
}
```

Each host name gets a hostname binding and an App Service Managed Certificate, bound with SNI; Azure renews the certificate by itself as long as the DNS records stay in place and the app is publicly reachable. Only subdomains: a host name that is a zone itself is rejected at plan.

- **Below a zone of the sandbox** (`dns_zones` of `sandbox_properties`, e.g. `sbx.casesight.io`): the module creates `CNAME <host> → <default host name>` and `TXT asuid.<host> = <custom_domain_verification_id>` in that zone (the deepest matching zone wins).
- **Any other host name** (e.g. a subdomain of a domain that stays at Strato): set both records at the registrar first, as listed by the output `dns_records`; until they resolve, the apply fails at the hostname binding.

The first host name is the public URL of the app (`APP__PUBLIC_URL`); `app_url` stays the `azurewebsites.net` URL. The skill `configure-custom-domain` of `core-agent-skills` walks through it.

## Features

- **Full deployment pipeline**: Build, push, and deploy in a single module
- **Automatic image tagging**: Uses timestamp tags for each deployment built here
- **Pushed images**: Deploys `<app_name>:<image_tag>` from the ACR without building
- **Container logging**: HTTP logs enabled with 7-day retention
- **HTTPS only**: Enforces secure connections
- **Custom domains**: DNS records, hostname bindings and managed certificates, renewed by Azure
- **Configurable app settings**: Merge custom settings with sensible defaults

## Architecture

This module composes two other modules:

1. **container_image**: Builds the Docker image locally using Podman
2. **sandbox_image**: Pushes the image to the sandbox ACR with multiple tags

Then deploys the timestamped image to Azure App Service. With `image_tag`, neither runs; the module deploys `<app_name>:<image_tag>` from the ACR.

## Inputs

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `app_name` | string | Yes | - | App name (also used as image name) |
| `image_tag` | string | No | `null` | Tag of an image already in the ACR as `<app_name>:<image_tag>`; when `null`, the image is built and pushed with Podman |
| `environment` | string | No | `"sandbox"` | Stage of the app, set as `APP__ENVIRONMENT` |
| `health_check_path` | string | No | `null` | Path App Service checks for health (e.g. `/health`); unhealthy instances are replaced after 10 minutes |
| `docker_context_path` | string | No | `null` | Path to directory containing Dockerfile (defaults to parent of deployment/) |
| `dockerfile_path` | string | No | `"Dockerfile"` | Dockerfile path relative to context |
| `app_settings` | map(string) | No | `{}` | Additional app settings |
| `websites_port` | number | No | `8501` | Container port to expose |
| `git_token` | string | No | `""` | Git token for private repository access during build (sensitive) |
| `database` | bool | No | `false` | Create a serverless SQL database and inject `APP__DATABASE__MSSQL__*` settings |
| `storage` | bool | No | `false` | Create a storage account and inject `APP__STORAGE__AZURE__*` settings |
| `short_name` | string | No | `null` | Storage account name override when `app_name` is too long |
| `custom_domains` | list(string) | No | `[]` | Host names of the app, each with a managed certificate; the first one is its public URL |

## Outputs

| Output | Description |
|--------|-------------|
| `app_url` | HTTPS URL of deployed app |
| `app_name` | Name of the deployed app |
| `acr_image` | Full ACR image reference used |
| `timestamp_tag` | Timestamp tag of deployed image (`null` with `image_tag`) |
| `custom_domains` | Host names of the app |
| `dns_records` | DNS records of the custom domains (`host`, `type`, `name`, `value`, `zone`, `managed`; `managed = false`: set by hand at the registrar) |

## Default App Settings

The following app settings are automatically configured:

| Setting | Value | Description |
|---------|-------|-------------|
| `WEBSITES_PORT` | `<websites_port>` | Container port |
| `WEBSITES_ENABLE_APP_SERVICE_STORAGE` | `false` | Disable persistent storage |
| `DOCKER_ENABLE_CI` | `true` | Enable container CI |
| `WEBSITES_CONTAINER_START_TIME_LIMIT` | `600` | 10-minute startup timeout |
| `APP__ENVIRONMENT` | `<environment>` | Environment identifier |
| `APP__PUBLIC_URL` | `https://<first custom domain>` or `https://<app_name>.azurewebsites.net` | Public URL of the app (`commons` `AppSettings.public_url`) |
| `APP__MODELS__AZURE_OPENAI__API_KEY` / `__ENDPOINT` | from Key Vault / sandbox | Azure OpenAI access |
| `APP__OCR__AZURE__API_KEY` / `__ENDPOINT` | from Key Vault / sandbox | Document Intelligence access |
