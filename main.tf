terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.5.1"
    }
  }
}

provider "vsphere" {
  user                 = "administrator@vsphere.local"
  password             = "P@ssw0rd"
  vsphere_server       = "10.200.124.40"
  allow_unverified_ssl = true
}

# 1) Datacenter
data "vsphere_datacenter" "dc" {
  name = "MCC-IBM3650-Datacenter"
}

# 2) Cluster
data "vsphere_compute_cluster" "cluster" {
  name          = "MCC-IBM3650-Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 3) Network
data "vsphere_network" "network" {
  name          = "VLAN-124"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 4) Datastore
data "vsphere_datastore" "ds" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

provider "vsphere" {
  user                 = "administrator@vsphere.local"
  password             = "P@ssw0rd"
  vsphere_server       = "10.200.124.40"
  allow_unverified_ssl = true
}

# 1) Datacenter
data "vsphere_datacenter" "dc" {
  name = "MCC-IBM3650-Datacenter"
}

# 2) Cluster
data "vsphere_compute_cluster" "cluster" {
  name          = "MCC-IBM3650-Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 3) Network
data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 4) Datastore
data "vsphere_datastore" "ds" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 5) Template VM
data "vsphere_virtual_machine" "template" {
  name          = "mcc_pudrhel9-template-build"  # ชื่อ Template ที่สร้างไว้
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 6) สร้าง VM จาก Template
resource "vsphere_virtual_machine" "vm" {
  name             = "rhel9-test"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id

  num_cpus = 2
  memory   = 2048
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "rhel9-testpud"
        domain    = "local"
      }

      network_interface {
        ipv4_address = "10.200.124.247"
        ipv4_netmask = 23
      }

      ipv4_gateway = "10.200.124.1"
    }
  }
}
