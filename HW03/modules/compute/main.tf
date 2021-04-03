terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.53.0"
    }
  }
}

data "yandex_compute_image" "web" {
  family    = var.image_family
}

resource "yandex_compute_instance" "web" {
  platform_id = var.platform_id

  count = var.instance_count

  name  = "${var.name}-${count.index}"
  zone  = var.zone

  hostname = "${var.hostname}-${count.index}"

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.web.id
      type     = "network-ssd"
      size     = var.size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = var.is_nat
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo echo 'hello web'",
      "sudo apt update",
      "sudo apt install nginx -y",
    ]
  }

}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = var.zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

