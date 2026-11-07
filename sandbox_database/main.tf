module "sandbox_properties" {
  source = "../functions/sandbox_properties"
}

locals {
  # Protected in the stages that hold data worth keeping, unless the caller says otherwise.
  prevent_destroy = var.prevent_destroy != null ? var.prevent_destroy : contains(["uat", "prd"], lower(var.environment))
}

module "database_name" {
  source        = "../functions/resource_name"
  name          = var.database_name
  environment   = "sbx"
  location      = module.sandbox_properties.location
  resource_type = "SqlDatabase"
}

data "azurerm_mssql_server" "sandbox" {
  name                = module.sandbox_properties.sql_server__name
  resource_group_name = module.sandbox_properties.rg_apps__name
}

resource "azurerm_mssql_database" "main" {
  name      = module.database_name.name
  server_id = data.azurerm_mssql_server.sandbox.id

  sku_name    = var.sku_name
  max_size_gb = var.max_size_gb

  lifecycle {
    prevent_destroy = local.prevent_destroy
  }
}
