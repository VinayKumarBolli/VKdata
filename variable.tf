variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Location of the resource group."
}

variable "databricks_workspace_name" {
  type        = string
  description = "Name of the Azure Databricks workspace."
}
