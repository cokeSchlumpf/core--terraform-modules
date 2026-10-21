output "connection_string" {
  description = "ADO.NET connection string (without credentials)"
  value       = "Server=tcp:${data.azurerm_mssql_server.sandbox.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.main.name};Encrypt=True;TrustServerCertificate=False;"
}

output "database_name" {
  description = "The name of the database"
  value       = azurerm_mssql_database.main.name
}

output "server_fqdn" {
  description = "The fully qualified domain name of the SQL Server"
  value       = data.azurerm_mssql_server.sandbox.fully_qualified_domain_name
}
