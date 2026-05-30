variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
  default     = "rg-genpact"
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
  default     = "vnet-genpact"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "aks_subnet_name" {
  description = "Name of the subnet used by the AKS cluster."
  type        = string
  default     = "snet-aks"
}

variable "aks_subnet_prefix" {
  description = "Address prefix for the AKS subnet."
  type        = string
  default     = "10.1.0.0/16"
}

variable "db_subnet_name" {
  description = "Name of the subnet used by the managed database."
  type        = string
  default     = "snet-db"
}

variable "db_subnet_prefix" {
  description = "Address prefix for the database subnet."
  type        = string
  default     = "10.2.0.0/16"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "aks-genpact"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.29"
}

variable "node_pool_vm_size" {
  description = "VM size for the default node pool."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "node_count" {
  description = "Initial number of nodes in the default node pool."
  type        = number
  default     = 2
}

variable "min_node_count" {
  description = "Minimum number of nodes when autoscaling is enabled."
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes when autoscaling is enabled."
  type        = number
  default     = 5
}

variable "acr_name" {
  description = "Globally unique name for the Azure Container Registry (alphanumeric only)."
  type        = string
  default     = "acrgenpact"
}

variable "acr_sku" {
  description = "SKU for the container registry (Basic, Standard, or Premium)."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be Basic, Standard, or Premium."
  }
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default = {
    environment = "dev"
    project     = "genpact"
    managed_by  = "terraform"
  }
}
