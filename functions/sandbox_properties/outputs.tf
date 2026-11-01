output "subscription_id" {
  description = "The subscription ID of the sandbox environment"
  value       = local.subscription_id
}

output "location" {
  description = "The Azure region of the sandbox environment"
  value       = local.location
}

output "rg_apps__name" {
  description = "The name of the Resource Group containing Container Registry and App Service Plan"
  value       = local.rg_apps__name
}

output "asp_app__name" {
  description = "The name of the Azure App Service Plan"
  value       = local.asp_app__name
}

output "acr__name" {
  description = "The name of the Azure Container Registry"
  value       = local.acr__name
}

output "kv_apps__name" {
  description = "The name of the Key Vault"
  value       = local.kv_apps__name
}

output "sql_server__name" {
  description = "The name of the SQL Server"
  value       = local.sql_server__name
}

output "sql_server__fqdn" {
  description = "The fully qualified domain name of the SQL Server"
  value       = local.sql_server__fqdn
}

output "sql_admin_username" {
  description = "The SQL Server administrator username"
  value       = local.sql_admin_username
}

output "sql_admin_password_secret_name" {
  description = "The name of the Key Vault secret containing the SQL admin password"
  value       = local.sql_admin_password_secret_name
}

output "tfstate" {
  description = "Properties of Terraform States Storage Container"
  value       = local.tfstate
}

output "tfstate_storage_account_id" {
  description = "The resource ID of the storage account used for Terraform state"
  value       = local.tfstate.storage_account_id
}

output "tfstate_container_name" {
  description = "The name of the blob container used for Terraform state"
  value       = local.tfstate.container_name
}

output "di__name" {
  description = "The name of the Document Intelligence account"
  value       = local.di__name
}

output "di__endpoint" {
  description = "The endpoint URL for Document Intelligence"
  value       = local.di__endpoint
}

output "di_api_key_secret_name" {
  description = "The name of the Key Vault secret containing the DI API key"
  value       = local.di_api_key_secret_name
}

output "azure_openai__endpoint" {
  description = "The endpoint URL for Azure OpenAI"
  value       = local.azure_openai__endpoint
}

output "azure_openai__name" {
  description = "The name of the Azure OpenAI account"
  value       = local.azure_openai__name
}

output "azure_openai_api_key_secret_name" {
  description = "The name of the Key Vault secret containing the Azure OpenAI API key"
  value       = local.azure_openai_api_key_secret_name
}

output "dns_zones" {
  description = "DNS zones in which apps create the records of their custom domains: zone name → resource group"
  value       = local.dns_zones
}
