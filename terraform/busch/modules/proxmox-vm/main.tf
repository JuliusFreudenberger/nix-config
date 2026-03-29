terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

resource "proxmox_vm_qemu" "truenas" {
  name               = var.name
  description        = var.description
  target_node        = var.target_node
  vmid               = var.vmid
  machine            = length(var.mapped_pcie_devices) == 0 ? "pc" : "q35"
  memory             = var.memory
  balloon            = 1024
  scsihw             = "virtio-scsi-pci"
  boot               = "order=scsi0;ide0"
  start_at_node_boot = true

  cpu {
    cores   = var.cpu_cores
    sockets = 1
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.disk_storage
          size    = var.disk_size
        }
      }
    }
    ide {
      ide0 {
        cdrom {
          iso = var.iso_path
        }
      }
    }
  }

  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }

  dynamic "pci" {
    for_each = { for device in var.mapped_pcie_devices : index(var.mapped_pcie_devices, device) => device }

    content {
      id         = pci.key
      mapping_id = pci.value
      pcie       = true
    }
  }

  startup_shutdown {
    order         = var.startup_order
    startup_delay = var.startup_delay
  }

}
