variable "vmid" {
  description = "ID of the VM to create"
  type        = string
}

variable "name" {
  description = "Name of the VM to create"
  type        = string
}

variable "description" {
  description = "Description of the VM to create"
  type        = string
  default     = null
  nullable    = true
}

variable "target_node" {
  description = "Name of the target node to create the VM on"
  type        = string
}

variable "memory" {
  description = "Memory to allocate for the VM"
  type        = string
}

variable "cpu_cores" {
  description = "Number of CPU cores to allocate for the VM"
  type        = number
}

variable "disk_storage" {
  description = "Name of the storage to store the disk on"
  type        = string
  default     = "local"
}

variable "disk_size" {
  description = "Size of the primary disk"
  type        = string
}

variable "iso_path" {
  description = "Path of the ISO to use to install an OS"
  type        = string
}

variable "startup_order" {
  description = "Order number of the VM in the startup chain"
  type        = number
}

variable "startup_delay" {
  description = "Startup delay in seconds"
  type        = number
  default     = -1
}

variable "mapped_pcie_devices" {
  description = "PCI mappings"
  type        = list(string)
  default     = []
}
