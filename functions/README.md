# Terraform Functions

This directory contains utility modules that act as "functions" - lightweight modules that compute values without creating resources. They provide consistent naming, location mapping, and environment configuration across the platform.

## Overview

| Function | Purpose |
|----------|---------|
| `resource_location` | Converts Azure location names to short/long format |
| `resource_name` | Generates standardized resource names following Azure CAF conventions |
| `sandbox_properties` | Provides sandbox environment configuration (auto-generated) |

---

## resource_location

Converts Azure location names to standardized short and long formats. Accepts both display names (e.g., "West Europe") and API names (e.g., "westeurope").

### Usage

```hcl
module "location" {
  source   = "git::https://github.com/cokeSchlumpf/core--terraform-modules.git//functions/resource_location?ref=versions/1"
  location = "Switzerland North"
}

# Use in resource names
resource "azurerm_resource_group" "example" {
  name     = "rg-myapp-${module.location.shortname}"  # rg-myapp-chn
  location = module.location.longname                  # switzerlandnorth
}
```

### Inputs

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `location` | string | No | `"West Europe"` | Azure location name (display or API format) |

### Outputs

| Output | Description |
|--------|-------------|
| `shortname` | 3-letter abbreviation (e.g., `chn`, `weu`, `neu`) |
| `longname` | API-compatible name (e.g., `switzerlandnorth`, `westeurope`) |

### Supported Locations

| Display Name | Short | Long |
|--------------|-------|------|
| Germany North | `gno` | `germanynorth` |
| Germany West Central | `gwc` | `germanywestcentral` |
| North Europe | `neu` | `northeurope` |
| Switzerland North | `chn` | `switzerlandnorth` |
| Switzerland West | `chw` | `switzerlandwest` |
| West Europe | `weu` | `westeurope` |
| Global | `glo` | `global` |

---

## resource_name

Generates standardized resource names following [Azure Cloud Adoption Framework naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).

### Naming Pattern

```
{organization}--{environment}--{location}--{resource_type}--{name}[--{index}]
```

Example: `wcs--dev--chn--rg--myapp` or `wcs--prd--weu--sa--data--01`

### Usage

```hcl
module "rg_name" {
  source = "git::https://github.com/cokeSchlumpf/core--terraform-modules.git//functions/resource_name?ref=versions/1"

  organization  = "wcs"
  environment   = "dev"
  location      = "Switzerland North"
  resource_type = "ResourceGroup"
  name          = "myapp"
}

resource "azurerm_resource_group" "main" {
  name     = module.rg_name.name  # wcs--dev--chn--rg--myapp
  location = "switzerlandnorth"
}
```

### With Index (for multiple instances)

```hcl
module "sa_name" {
  source = "git::https://github.com/cokeSchlumpf/core--terraform-modules.git//functions/resource_name?ref=versions/1"

  organization  = "wcs"
  environment   = "prd"
  location      = "West Europe"
  resource_type = "StorageAccount"
  name          = "data"
  index         = 1
}

# Output: wcsprdweusadata01 (no dashes for storage accounts)
```

### Inputs

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `organization` | string | No | `"wcs"` | Organization shortname |
| `environment` | string | Yes | - | Environment: `dev`, `sit`, `uat`, `prd`, `sbx`, `mgm` |
| `location` | string | Yes | - | Azure location name |
| `resource_type` | string | Yes | - | Resource type (see supported types below) |
| `name` | string | Yes | - | Workload name (kebab-case) |
| `index` | number | No | `0` | Optional index (appended if > 0) |

### Outputs

| Output | Description |
|--------|-------------|
| `name` | Generated resource name |

### Supported Resource Types

| Type | Abbreviation |
|------|--------------|
| `Application` | `app` |
| `ApplicationInsights` | `appi` |
| `AppServicePlan` | `asp` |
| `ContainerApp` | `ca` |
| `ContainerAppEnvironment` | `cae` |
| `CosmosMongoAccount` | `cosmon` |
| `DataLake` | `dls` |
| `DevCenter` | `dc` |
| `EventGridTopic` | `evgt` |
| `EventHub` | `evh` |
| `EventHubNamespace` | `evhns` |
| `KeyVault` | `kv` |
| `LogAnalyticsWorkspace` | `log` |
| `ManagedIdentity` | `id` |
| `NetworkWatcher` | `nw` |
| `PrivateEndpoint` | `pep` |
| `RoleAssignment` | `ra` |
| `ResourceGroup` | `rg` |
| `StorageAccount` | `sa` |
| `Subnet` | `snet` |
| `Synapse` | `syn` |
| `VirtualMachineScaleSet` | `vmss` |
| `VirtualNetwork` | `vnet` |
| `VirtualNetworkPeering` | `peer` |

### Special Naming Rules

- **StorageAccount**: Dashes removed (Azure requirement for storage account names)
- **Application**: Uses simplified format `{environment}-{name}[-{index}]`

---

## sandbox_properties

Provides pre-configured values for the sandbox environment infrastructure. This file is **auto-generated** by `10--sandbox/main.tf` and should not be edited manually.

### Usage

```hcl
module "sandbox" {
  source = "git::https://github.com/cokeSchlumpf/core--terraform-modules.git//functions/sandbox_properties?ref=versions/1"
}

data "azurerm_container_registry" "acr" {
  name                = module.sandbox.acr__name
  resource_group_name = module.sandbox.rg_apps__name
}
```

### Outputs

| Output | Description |
|--------|-------------|
| `subscription_id` | Sandbox subscription ID |
| `location` | Sandbox Azure region |
| `rg_apps__name` | Resource group containing ACR and App Service Plan |
| `asp_app__name` | App Service Plan name |
| `acr__name` | Azure Container Registry name |
| `tfstate` | Terraform state storage configuration (object) |
| `tfstate_storage_account_id` | Storage account resource ID for Terraform state |
| `tfstate_container_name` | Blob container name for Terraform state |

### Note

This module has no inputs - it simply exposes the sandbox environment's infrastructure configuration for use by other modules (like `sandbox_image` and `sandbox_app`).
