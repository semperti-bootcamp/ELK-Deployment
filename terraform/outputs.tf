#############################################
# Output IP Addresses
#############################################
output "00 - GENERAL INFORMATION" {
 value = "\n_____________________________________________"
}

output "03 - internal_ip_address" {
 value = "${vsphere_virtual_machine.vm.guest_ip_addresses.0}\n\n\n"
 description = "Internal IP Address for Docker VM"
}
output "02 - external_ip_address" {
 value = "${vsphere_virtual_machine.vm.guest_ip_addresses.1}"
 description = "External IP Address for Docker VM"
}

output "01 - VM_name" {
 value = "${vsphere_virtual_machine.vm.name}"
 description = "Virtual Machine Name"
}

output "04 - VMware Enforcer Compliance Status" {
    value = "${(vsphere_virtual_machine.vm.cpu_hot_add_enabled && vsphere_virtual_machine.vm.cpu_hot_remove_enabled) && (vsphere_virtual_machine.vm.memory_hot_add_enabled) && (vsphere_virtual_machine.vm.num_cpus <= 4 ? true : false ) && ((((vsphere_virtual_machine.vm.num_cpus * vsphere_virtual_machine.vm.num_cores_per_socket) / 2) == ceil(((vsphere_virtual_machine.vm.num_cpus * vsphere_virtual_machine.vm.num_cores_per_socket) / 2)) && ((vsphere_virtual_machine.vm.num_cpus * vsphere_virtual_machine.vm.num_cores_per_socket) / 2) == floor(((vsphere_virtual_machine.vm.num_cpus * vsphere_virtual_machine.vm.num_cores_per_socket) / 2))) || vsphere_virtual_machine.vm.num_cpus == 1 ) && (vsphere_virtual_machine.vm.network_interface.0.adapter_type == vsphere_virtual_machine.vm.network_interface.1.adapter_type && vsphere_virtual_machine.vm.network_interface.1.adapter_type == "vmxnet3" && vsphere_virtual_machine.vm.network_interface.0.adapter_type == "vmxnet3") }\n\nDETAILS\n_____________________________________________"
}
output "04a - Hot Add & Remove CPU" {
 value = "${vsphere_virtual_machine.vm.cpu_hot_add_enabled && vsphere_virtual_machine.vm.cpu_hot_remove_enabled}"
 description = "Hot Add & Remove CPU"
}
output "04b - Hot Add RAM" {
 value = "${vsphere_virtual_machine.vm.memory_hot_add_enabled}"
 description = "Hot Add RAM"
}

output "04c - CPU [Should be CPU <= 4]" {
 value = "${vsphere_virtual_machine.vm.num_cpus <= 4 ? true : false }"
 description = "vCPU quantity"
}
output "04d - vCPU [Divisible by 2 or CPU = 1]" {
 value = "${(((vsphere_virtual_machine.vm.num_cpus * vsphere_virtual_machine.vm.num_cores_per_socket) / 2) == ceil(((vsphere_virtual_machine.vm.num_cpus * vsphere_virtual_machine.vm.num_cores_per_socket) / 2)) && ((vsphere_virtual_machine.vm.num_cpus * vsphere_virtual_machine.vm.num_cores_per_socket) / 2) == floor(((vsphere_virtual_machine.vm.num_cpus * vsphere_virtual_machine.vm.num_cores_per_socket) / 2))) || vsphere_virtual_machine.vm.num_cpus == 1 }"
 description = "vCPU quantity"
}


output "04e - Network Adapter [Should be VMXNET3]" {
 value = "${vsphere_virtual_machine.vm.network_interface.0.adapter_type == vsphere_virtual_machine.vm.network_interface.1.adapter_type && vsphere_virtual_machine.vm.network_interface.1.adapter_type == "vmxnet3" && vsphere_virtual_machine.vm.network_interface.0.adapter_type == "vmxnet3"}\n\n\n"
 description = "Network Adapter to be VMXNET3"
}

output "05 - IQB Compliance Status" {
    value = "${(vsphere_virtual_machine.vm.cpu_hot_add_enabled && vsphere_virtual_machine.vm.cpu_hot_remove_enabled) && (vsphere_virtual_machine.vm.memory_hot_add_enabled) && (contains(split("-",data.vsphere_datastore_cluster.datastore.name),"Dev")) && (vsphere_virtual_machine.vm.num_cpus <= 4 ? true : false ) && ((((vsphere_virtual_machine.vm.num_cpus * vsphere_virtual_machine.vm.num_cores_per_socket) / 2) == ceil(((vsphere_virtual_machine.vm.num_cpus * vsphere_virtual_machine.vm.num_cores_per_socket) / 2)) && ((vsphere_virtual_machine.vm.num_cpus * vsphere_virtual_machine.vm.num_cores_per_socket) / 2) == floor(((vsphere_virtual_machine.vm.num_cpus * vsphere_virtual_machine.vm.num_cores_per_socket) / 2))) || vsphere_virtual_machine.vm.num_cpus == 1 ) && ((vsphere_virtual_machine.vm.memory / 1024) <= 16 ? true : false) && (vsphere_virtual_machine.vm.network_interface.0.adapter_type == vsphere_virtual_machine.vm.network_interface.1.adapter_type && vsphere_virtual_machine.vm.network_interface.1.adapter_type == "vmxnet3" && vsphere_virtual_machine.vm.network_interface.0.adapter_type == "vmxnet3") }\n\nDETAILS\n_____________________________________________"
}

output "05a - Datastore [Should contain Dev]" {
 value = "${contains(split("-",data.vsphere_datastore_cluster.datastore.name),"Dev")}"
 description = "Datastore Cluster"
}
output "05b - Max CPU allocated <= 4 " {
 value = "${(vsphere_virtual_machine.vm.num_cpus * vsphere_virtual_machine.vm.num_cores_per_socket) <= 4 ? true : false}"
 description = "Datastore Cluster"
}
output "05c - RAM [Should be RAM <= 16 GB]" {
 value = "${(vsphere_virtual_machine.vm.memory / 1024) <= 16 ? true : false}"
 description = "RAM quantity"
}


# data "external" "example" {
#   program = ["sh", "echo ${vsphere_virtual_machine.vm.guest_ip_addresses.0} > ../ansible/java-docker.txt" ]
# }
resource "local_file" "elk_ip" {
    content     = "${vsphere_virtual_machine.vm.guest_ip_addresses.0}"
    filename = "ansible/elk-stack.txt"
}
