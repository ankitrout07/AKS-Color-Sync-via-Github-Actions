variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "AK8S-REBUILD-TF"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "centralindia"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-colorsync-tf"
}

variable "aks_node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "aks_vm_size" {
  description = "VM size for AKS nodes (optimized for Azure Student)"
  type        = string
  default     = "Standard_B2s_v2"
}
