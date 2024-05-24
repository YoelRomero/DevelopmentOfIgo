terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-d"
}
########################################################

#Images
resource "yandex_compute_image" "ubuntu_2004" {
  source_family = "ubuntu-2004-lts"
}
#Disk
resource "yandex_compute_disk" "boot-disk-vm1" {
  name		= "boot-disk-1"
  type		= "network-hdd"
  zone		= "ru-central1-d"
  size		= "10"
  image_id	= yandex_compute_image.ubuntu_2004.id
}
#VM parameters
resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"
  platform_id = "standard-v2"
  resources {
    cores = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-vm1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = <<-EOF
      #!/bin/bash
      echo "Hello, IGO, you are nuclear-engineer! ░░░░░░░░░░░▄▄▄▄▄▄▄▄▄▄▄▄░░░░░░░░░░░
                                                  ░░░░░░░▄▄██▀▀▀▀▀▀▀▀▀▀▀▀██▄▄░░░░░░░
                                                  ░░░░░▄██▀▄░░░░░░░░░░░░░░▄▀██▄░░░░░
                                                  ░░░▄██▀▄███░░░░░░░░░░░░███▄▀██▄░░░
                                                  ░░██▀▄██████░░░░░░░░░░██████▄▀██░░
                                                  ░██░█████████▄░░░░░░▄█████████░██░
                                                  ██░███████████▄░░░░▄███████████░██
                                                  ██▄███████████▀▄▄▄▄▀███████████▄██
                                                  █████████████░██████░█████████████
                                                  ██░░░░░░░░░░░░██████░░░░░░░░░░░░██
                                                  ██░░░░░░░░░░░░░▀▀▀▀░░░░░░░░░░░░░██
                                                  ▀█░░░░░░░░░░░░██████▄░░░░░░░░░░░██
                                                  ░██░░░░░░░░░▄████████▄░░░░░░░░░██░
                                                  ░░██▄░░░░░░▄██████████▄░░░░░░▄██░░
                                                  ░░░▀██▄░░░▄████████████▄░░░▄██▀░░░
                                                  ░░░░░▀██▄░▀████████████▀░▄██▀░░░░░
                                                  ░░░░░░░▀▀██▄▄▄██████▄▄▄██▀▀░░░░░░░ 
                                                  ░░░░░░░░░░░▀▀▀▀▀▀▀▀▀▀▀▀░░░░░░░░░░░" > index.html
      nohup busybox httpd -f -p 8080 &
      EOF
  } 
}
#Network
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "subnet-1" {
  value = yandex_vpc_subnet.subnet-1.id
}
#Firewall
resource "yandex_vpc_security_group" "group1" {
  name        = "My security group"
  description = "description for my security group"
  network_id  = "${yandex_vpc_network.network-1.id}"

  labels = {
    my-label = "my-label-value"
  }
}

resource "yandex_vpc_security_group_rule" "allow-http-ingress" {
  security_group_binding = yandex_vpc_security_group.group1.id
  direction              = "ingress"
  description            = "rule1 description"
  v4_cidr_blocks         = ["0.0.0.0/24"]
  port                   = 8080
  protocol               = "TCP"
}
