####################################################
# Remember to run "terraform init" to get proper provider plugin
####################################################


####################################################
# Provider
# Variables defined at variables.tf
# You can use -var-file to provide user & password. 
# server can be changed to "${var.vsphere_server}" to ask for a specific vCenter
####################################################
terraform { 
    # In case you want to keep the TFState on AWS
    # backend "s3" {
    #     bucket="bucket_name"
    #     key="keyname.tfstate"
    #     region="us-east-1"
    # }
}
provider "vsphere" {
    user        = "${var.vsphere_user}"
    password    = "${var.vsphere_password}"
    vsphere_server      = "${var.vcenter_server}"

    # As we have a self-signed
    allow_unverified_ssl = true
}

####################################################
# Data section
####################################################

######################################
# Datacenter
######################################
data "vsphere_datacenter" "dc" {
    name = "DC_REPLACE"
}

######################################
# Compute Cluster
######################################
data "vsphere_compute_cluster" "cluster" {
    name = "COMPUTE_CLUSTER_REPLACE"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

######################################
# Datastore Cluster
######################################
data "vsphere_datastore_cluster" "datastore" {
    name = "DATASTORE_NAME_REPLACE"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

######################################
# DMZ - Network 
######################################
data "vsphere_network" "network-dmz" {
    name = "NETWORK_REPLACE"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

######################################
# Internal - Network 
# ######################################
data "vsphere_network" "network-int" {
    name = "NETWORK_REPLACE"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


######################################
# Defined Template [! Warning !] 
######################################
data "vsphere_virtual_machine" "template" {
    name    = "TEMPLATE_REPLACE"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


####################################################
# Resource section
####################################################


######################################
# Tag for future reference
# Can't create, no permissions
######################################
# resource "vsphere_tag" "tag" {
#     name = "${var.tag_name}-test-tag"
#     category_id = "${vsphere_tag_category.category.id}"
#     description = "Created using Terraform"
# }


######################################
# Folder structure for VM
# ######################################
resource "vsphere_folder" "folder" {
    path = "${var.user_folder}"
    type = "vm"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_folder" "elk-stack" {
    path = "${var.user_folder}/elk-stack"
    type = "vm"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

######################################
# VM 
######################################
resource "vsphere_virtual_machine" "vm" {
    name             = "centos7-elk-stack"
    # In case we need a Resource Pool in the future
    # resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
    resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"

    datastore_cluster_id     = "${data.vsphere_datastore_cluster.datastore.id}"
    name   = "centos7-elk-stack"

    num_cpus = 2
    memory   = 4096
    cpu_hot_add_enabled = true
    cpu_hot_remove_enabled = true
    memory_hot_add_enabled = true

    guest_id  = "${data.vsphere_virtual_machine.template.guest_id}"
    scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"


    network_interface {
        network_id    = "${data.vsphere_network.network-dmz.id}"
        adapter_type  = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
    }

    network_interface {
        network_id    = "${data.vsphere_network.network-int.id}"
        adapter_type  = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
    }

    disk {
        label            = "Bootable-Disk"
        size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
        eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
        thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
    }
    annotation = "Created by Semperti"

    clone {
        template_uuid = "${data.vsphere_virtual_machine.template.id}"
        timeout = 30

        customize {
            timeout = 30
            linux_options {
                host_name = "centos7-elk-stack"
                domain    = "localdomain"
            }
            ######################################
            # Dual Network [DMZ & INT] 
            ######################################
            network_interface {}
            network_interface {}
        }
    }
    folder = "${var.user_folder}/elk-stack"
}