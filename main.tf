###########################################
# Define Variable 
###########################################
variable "vcenter" {}
variable "username" {}
variable "password" {}
variable "datacenter" {}
variable "cluster" {}
variable "datastore" {}
variable "network" {}
variable "foldername" {}
variable "template" {}

################################################
# Provider section
################################################
provider "vsphere" {
  user           = var.username
  password       = var.password
  vsphere_server = var.vcenter

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

#################################################
#Capturing the data from vsphere
#################################################
data "vsphere_datacenter" "dc" {
  name = "${var.datacenter}"
}

data "vsphere_compute_cluster" "cluster" {
  name = "${var.cluster}"
   datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

########################################################
# sourcing template
#############################################################
data "vsphere_virtual_machine" "template" {
  name          = "${var.template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

#########################################################
# Resource
##########################################################
resource "vsphere_folder" "folder" {
  path          = var.foldername
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "random_id" "id" {
  count            = 2
  byte_length      = 3
}

resource "vsphere_virtual_machine" "vm" {
  count            = 2
  name             = "vm-${element(random_id.id.*.hex, count.index)}"
  folder           = var.foldername
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 4096
  guest_id = "rhel7_64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  wait_for_guest_net_routable = true

  disk {
    label = "disk0"
    size  = 50
  }
  ################################################################
  # Initiate the clone 
  #################################################################
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "vm-${element(random_id.id.*.hex, count.index)}"
        domain    = "moorenix.com"
      }
      
      network_interface {}

    }
  }

  depends_on = [
    vsphere_folder.folder
  ]

}

######################################
# Terraform Ansible Inventory Creation
######################################
data "template_file" "hosts" {
  template              = templatefile("${path.module}/templates/hosts.tpl", { default_ip_address = ["${vsphere_virtual_machine.vm.*.default_ip_address}"]}
  )
}

resource "null_resource" "hosts" {
  triggers              = {
    template_rendered   = "${data.template_file.hosts.rendered}"
  }
  provisioner "local-exec" {
    command             = "echo '${data.template_file.hosts.rendered}' > '${path.module}/ansible/hosts.yml'"
  }
}