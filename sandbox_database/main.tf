module "sandbox_properties" {
  source = "../functions/sandbox_properties"
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

  sku_name                    = "GP_S_Gen5_1"
  auto_pause_delay_in_minutes = var.auto_pause_delay_in_minutes
  min_capacity                = var.min_capacity
  max_size_gb                 = var.max_size_gb
}
