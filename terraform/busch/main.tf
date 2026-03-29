terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_token_id
  pm_api_token_secret = var.proxmox_token_secret
  pm_tls_insecure     = true
}

module "truenas" {
  source = "./modules/proxmox-vm"

  name          = "truenas"
  target_node   = "busch"
  vmid          = 100
  memory        = 8192
  cpu_cores     = 2
  disk_storage  = "local"
  disk_size     = "32G"
  iso_path      = "local:iso/TrueNAS-SCALE-25.10.2.1.iso"
  startup_order = 1

  mapped_pcie_devices = ["HBA"]
}

module "nixos-docker" {
  source = "./modules/proxmox-vm"

  name          = "nixos-docker"
  target_node   = "busch"
  vmid          = 101
  memory        = 4096
  cpu_cores     = 2
  disk_storage  = "truenas-lvm"
  disk_size     = "64G"
  iso_path      = "local:iso/latest-nixos-minimal-x86_64-linux.iso"
  startup_order = 2
  startup_delay = 240
}
