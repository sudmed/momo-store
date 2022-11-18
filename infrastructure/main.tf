# Create VM 'master' (manager node in swarm cluster)
resource "yandex_compute_instance" "vm-master" {
  platform_id = var.master_platform_id
  count       = var.master_count
  name        = "momo-store-master"

  resources {
    cores         = var.master_cores
    memory        = var.master_ram
    core_fraction = var.master_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.master_boot_disk_size
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.master_nat
  }

  metadata = {
    ssh-keys           = "ubuntu:${file("keys/id_rsa.pub")}"
    serial-port-enable = var.master_serial-port-enable
  }

  # Copy script for docker install
  provisioner "file" {
    source      = "scripts/install_docker.sh"
    destination = "/tmp/install_docker.sh"
  }

  # Copy script for portainer install
  provisioner "file" {
    source      = "scripts/install_portainer.sh"
    destination = "/tmp/install_portainer.sh"
  }

  # Install docker, init Swarm mode, install portainer
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_docker.sh",
      "/tmp/install_docker.sh",
      "echo =================================================================================================",
      "echo DOCKER INSTALLED",
      "echo =================================================================================================",
      "sleep 1",
      "sudo docker swarm init --advertise-addr eth0",
      "echo =================================================================================================",
      "echo JOIN-TOKEN: `sudo docker swarm join-token -q worker`",
      "echo =================================================================================================",
      "echo `sudo docker swarm join-token -q worker` > /tmp/token.txt",
      "chmod +x /tmp/install_portainer.sh",
      "/tmp/install_portainer.sh",
      "echo =================================================================================================",
      "echo PORTAINER INSTALLED",
      "echo =================================================================================================",
      "ssh-keyscan ${self.network_interface.0.nat_ip_address}"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("keys/id_rsa")
    host        = self.network_interface.0.nat_ip_address
  }
}


# Create VM for worker node
resource "yandex_compute_instance" "vm-worker" {
  platform_id = var.worker_platform_id
  count       = var.workers_count
  name        = "momo-store-worker${count.index}"

  resources {
    cores         = var.workers_cores
    memory        = var.workers_ram
    core_fraction = var.workers_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.worker_boot_disk_size
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.worker_nat
  }

  metadata = {
    ssh-keys           = "ubuntu:${file("keys/id_rsa.pub")}"
    serial-port-enable = var.worker_serial-port-enable
  }

  # Copy script for docker install
  provisioner "file" {
    source      = "scripts/install_docker.sh"
    destination = "/tmp/install_docker.sh"
  }

  # Install docker and join new worker node to swarm
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_docker.sh",
      "/tmp/install_docker.sh",
      "mkdir -p ~/.ssh",
      "echo '${file("keys/id_rsa")}' > ~/.ssh/id_rsa",
      "echo ~/.ssh/id_rsa",
      "sudo chmod 600 ~/.ssh/id_rsa",
      "sudo chmod 700 ~/.ssh",
      "scp -oStrictHostKeyChecking=no ubuntu@${yandex_compute_instance.vm-master[0].network_interface.0.ip_address}:/tmp/token.txt /tmp/token.txt",
      "sudo docker swarm join ${yandex_compute_instance.vm-master[0].network_interface.0.ip_address}:2377 --token $(cat /tmp/token.txt)",
      "echo =================================================================================================",
      "echo JOIN-TOKEN: $(cat /tmp/token.txt)",
      "echo ================================================================================================="
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("keys/id_rsa")
    host        = self.network_interface.0.nat_ip_address
  }

  # worker node create and add to swarm after its init
  depends_on = [yandex_compute_instance.vm-master]

}
