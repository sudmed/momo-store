output "master_public_ip" {
  value = [
    for instance in yandex_compute_instance.vm-master[*] :
    join(" ", [instance.name, instance.hostname, instance.network_interface.0.nat_ip_address])
  ]
}

output "master_private_ip" {
  value = [
    for instance in yandex_compute_instance.vm-master[*] :
    join(" ", [instance.name, instance.hostname, instance.network_interface.0.ip_address])
  ]
}

output "workers_public_ip" {
  value = [
    for instance in yandex_compute_instance.vm-worker[*] :
    join(" ", [instance.name, instance.hostname, instance.network_interface.0.nat_ip_address])
  ]
}

output "workers_private_ip" {
  value = [
    for instance in yandex_compute_instance.vm-worker[*] :
    join(" ", [instance.name, instance.hostname, instance.network_interface.0.ip_address])
  ]
}
