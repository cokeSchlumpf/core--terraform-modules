# Get sandbox properties
module "sandbox_properties" {
  source = "../functions/sandbox_properties"
}

# Look up the Azure Container Registry for credentials
data "azurerm_container_registry" "acr" {
  name                = module.sandbox_properties.acr__name
  resource_group_name = module.sandbox_properties.rg_apps__name
}

# Look up existing App Service Plan
data "azurerm_service_plan" "sandbox" {
  name                = module.sandbox_properties.asp_app__name
  resource_group_name = module.sandbox_properties.rg_apps__name
}

# Look up Key Vault for secrets
data "azurerm_key_vault" "apps" {
  name                = module.sandbox_properties.kv_apps__name
  resource_group_name = module.sandbox_properties.rg_apps__name
}

# Conditional: Get SQL admin password from Key Vault
data "azurerm_key_vault_secret" "sql_admin_password" {
  count        = var.database ? 1 : 0
  name         = module.sandbox_properties.sql_admin_password_secret_name
  key_vault_id = data.azurerm_key_vault.apps.id
}

data "azurerm_key_vault_secret" "azure_openai_api_key" {
  name         = module.sandbox_properties.azure_openai_api_key_secret_name
  key_vault_id = data.azurerm_key_vault.apps.id
}

# Get Document Intelligence API key from Key Vault
data "azurerm_key_vault_secret" "di_api_key" {
  name         = module.sandbox_properties.di_api_key_secret_name
  key_vault_id = data.azurerm_key_vault.apps.id
}

# Conditional: Create database for this app
module "database" {
  count         = var.database ? 1 : 0
  source        = "../sandbox_database"
  database_name = var.app_name
}

# Conditional: Create storage account for this app
module "storage" {
  count      = var.storage ? 1 : 0
  source     = "../sandbox_storage"
  sa_name    = var.app_name
  short_name = var.short_name
}

locals {
  # Default docker_context_path to parent of deployment directory
  docker_context_path = var.docker_context_path != null ? var.docker_context_path : "${path.root}/.."

  # Database environment variables (only when database = true)
  database_app_settings = var.database ? {
    "APP__DATABASE__MSSQL__SERVER"   = module.database[0].server_fqdn
    "APP__DATABASE__MSSQL__DATABASE" = module.database[0].database_name
    "APP__DATABASE__MSSQL__USERNAME" = module.sandbox_properties.sql_admin_username
    "APP__DATABASE__MSSQL__PASSWORD" = data.azurerm_key_vault_secret.sql_admin_password[0].value
  } : {}

  # Storage environment variables (only when storage = true)
  storage_app_settings = var.storage ? {
    "APP__STORAGE__AZURE__ACCOUNT_NAME" = module.storage[0].account_name
    "APP__STORAGE__AZURE__ACCOUNT_KEY"  = module.storage[0].account_key
    "APP__STORAGE__AZURE__CONTAINER"    = module.storage[0].container_name
  } : {}
}

# Step 1: Build the image
module "build_image" {
  source              = "../container_image"
  image_name          = var.app_name
  docker_context_path = local.docker_context_path
  dockerfile_path     = var.dockerfile_path
  always_rebuild      = true
  git_token           = var.git_token
}

# Step 2: Push to ACR
module "push_image" {
  source      = "../sandbox_image"
  local_image = module.build_image.local_image

  depends_on = [module.build_image]
}

# Step 3: Deploy to App Service
resource "azurerm_linux_web_app" "app" {
  name                = var.app_name
  resource_group_name = module.sandbox_properties.rg_apps__name
  location            = data.azurerm_service_plan.sandbox.location
  service_plan_id     = data.azurerm_service_plan.sandbox.id

  depends_on = [module.push_image]

  site_config {
    always_on = true

    application_stack {
      docker_image_name        = "${module.push_image.repository_name}:${module.push_image.timestamp_tag}"
      docker_registry_url      = "https://${module.push_image.acr_login_server}"
      docker_registry_username = data.azurerm_container_registry.acr.admin_username
      docker_registry_password = data.azurerm_container_registry.acr.admin_password
    }
  }

  app_settings = merge(
    {
      "WEBSITES_PORT"                       = tostring(var.websites_port)
      "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
      "DOCKER_ENABLE_CI"                    = "true"
      "WEBSITES_CONTAINER_START_TIME_LIMIT" = "600"
      "APP__ENVIRONMENT"                    = "sandbox"
      "APP__MODELS__AZURE_OPENAI__API_KEY"  = data.azurerm_key_vault_secret.azure_openai_api_key.value
      "APP__MODELS__AZURE_OPENAI__ENDPOINT" = module.sandbox_properties.azure_openai__endpoint
      "APP__OCR__AZURE__API_KEY"            = data.azurerm_key_vault_secret.di_api_key.value
      "APP__OCR__AZURE__ENDPOINT"           = module.sandbox_properties.di__endpoint
    },
    local.database_app_settings,
    local.storage_app_settings,
    var.app_settings
  )

  https_only = true

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }
}
