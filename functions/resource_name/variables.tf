variable "organization" {
  description = "The shortname of the organization to be used for creating technical names."
  type        = string
  default     = "wcs"
}

variable "environment" {
  description = "The name of the environment which is targeted in the deployment."
  type        = string

  validation {
    condition     = contains(["dev", "sit", "uat", "prd", "mgm", "sbx"], var.environment)
    error_message = "Allowed values for environment are \"dev\", \"sit\", \"uat\", \"prd\", \"sbx\" or \"mgm\"."
  }
}

variable "location" {
  description = "The name of the deployment location within Microsoft Azure."
  type        = string
}

variable "resource_type" {
  description = "The type of the resource to create."
  type        = string

  validation {
    condition = contains([
      "Application",
      "ApplicationInsights",
      "AppServicePlan",
      "ContainerAppEnvironment",
      "CosmosMongoAccount",
      "DataLake",
      "DevCenter",
      "DocumentIntelligence",
      "EventGridTopic",
      "EventHub",
      "EventHubNamespace",
      "KeyVault",
      "LogAnalyticsWorkspace",
      "ManagedIdentity",
      "NetworkWatcher",
      "OpenAI",
      "PrivateEndpoint",
      "RoleAssignment",
      "ResourceGroup",
      "SqlDatabase",
      "SqlServer",
      "StorageAccount",
      "Subnet",
      "Synapse",
      "VirtualMachineScaleSet",
      "VirtualNetwork",
      "VirtualNetworkPeering"
    ], var.resource_type)

    error_message = "Resource type must be one of the allowed types."
  }
}

variable "name" {
  description = "The short name for the resource's workload, derived from it's purpose without technical details."

  validation {
    condition     = can(regex("^[0-9a-z-]*$", var.name))
    error_message = "The name must be kebab-case."
  }
}

variable "index" {
  description = "An optional index for the resource. If this number is greater than 0, the index will be appended to the name."
  type        = number
  default     = 0
}

variable "short_name" {
  description = "Explicit short name override for resource types with length constraints (e.g. StorageAccount). Passed through to the short_name function."
  type        = string
  default     = null

  validation {
    condition     = var.short_name == null || can(regex("^[0-9a-z-]*$", var.short_name))
    error_message = "short_name must be kebab-case."
  }
}
