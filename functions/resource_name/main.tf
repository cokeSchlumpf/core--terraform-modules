module "location" {
  source   = "../resource_location"
  location = var.location
}
module "short_name_sa" {
  source     = "../short_name"
  name       = var.name
  short_name = var.short_name
  max_length = local.sa_max_name_length
}

module "short_name_kv" {
  source     = "../short_name"
  name       = var.name
  short_name = var.short_name
  max_length = local.kv_max_name_length
}

locals {
  #
  # See also https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations.
  # Extend the following list when required.
  #
  resource_types = {
    Application             = "app"
    ApplicationInsights     = "appi"
    AppServicePlan          = "asp"
    ContainerApp            = "ca"
    ContainerAppEnvironment = "cae"
    CosmosMongoAccount      = "cosmon"
    DataLake                = "dls"
    DevCenter               = "dc"
    DocumentIntelligence    = "di"
    EventGridTopic          = "evgt"
    EventHub                = "evh"
    EventHubNamespace       = "evhns"
    KeyVault                = "kv"
    LogAnalyticsWorkspace   = "log"
    ManagedIdentity         = "id"
    NetworkWatcher          = "nw"
    OpenAI                  = "oai"
    PrivateEndpoint         = "pep"
    RoleAssignment          = "ra"
    ResourceGroup           = "rg"
    SqlDatabase             = "sqldb"
    SqlServer               = "sql"
    StorageAccount          = "sa"
    Subnet                  = "snet"
    Synapse                 = "syn"
    VirtualMachineScaleSet  = "vmss"
    VirtualNetwork          = "vnet"
    VirtualNetworkPeering   = "peer"
  }

  #
  # Compute max possible name length for storage account after removing standard prefix and suffix
  #
  sa_max_name_length = 24 - length(replace(local.base_name, "-", "")) - length(var.index > 0 ? format("%02d", var.index) : "")

  #
  # Compute max possible name length for key vault after removing standard prefix and suffix.
  # Unlike the storage account the key vault keeps single dashes, so the collapsed prefix and
  # the dash separating it from the name both count against the 24 character limit.
  #
  kv_prefix          = replace(local.base_name, "--", "-")
  kv_max_name_length = 24 - length(local.kv_prefix) - 1 - length(var.index > 0 ? "-${format("%02d", var.index)}" : "")

  #
  # Key vaults allow dashes, so keep the readable name as given when it fits within the
  # limit and only fall back to the abbreviated short name when it does not.
  #
  kv_name = length(var.name) <= local.kv_max_name_length ? var.name : module.short_name_kv.name

  #
  # Create standard name
  #
  base_name = "${var.organization}--${var.environment}--${module.location.shortname}--${local.resource_types[var.resource_type]}"
  name      = join("--", compact([local.base_name, var.name, var.index > 0 ? format("%02d", var.index) : ""]))

  #
  # Resources where special naming conventions need to be applied
  #
  custom_names = {
    Application    = replace(join("-", compact([var.environment, var.name, var.index > 0 ? format("%02d", var.index) : ""])), "--", "-")
    KeyVault       = replace(join("-", compact([local.kv_prefix, local.kv_name, var.index > 0 ? format("%02d", var.index) : ""])), "--", "-")
    SqlDatabase    = replace(local.name, "-", "_")
    StorageAccount = replace(join("", compact([local.base_name, module.short_name_sa.name, var.index > 0 ? format("%02d", var.index) : ""])), "-", "")
  }
}

output "name" {
  value = lookup(local.custom_names, var.resource_type, local.name)
}
