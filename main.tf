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
##########################################################################

###Disk##########################################################
resource "yandex_compute_disk" "boot-disk-1" {
  name     = "gitlab-1716812825474"
  type     = "network-hdd"
  zone     = "ru-central1-d"
  size     = "20"
  image_id = "fd87q5833j757gs2omg3"
}

###VM parameters##################################################
resource "yandex_compute_instance" "vm-1" {
  name = "gitlab"

  resources {
    cores  = 2
    memory = 8
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
    nat_ip_address   = "158.160.170.158"
  }

  platform_id = "standard-v2"

  metadata = {
    user-data = "${file("cloud-init.yaml")}"
  }
}

###Network########################################################
resource "yandex_vpc_network" "gitlab" {
  name = "gitlab"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "gitlab_subnet"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.gitlab.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

resource "yandex_vpc_address" "addr" {
  name = "vm-address"
  external_ipv4_address {
    zone_id = "ru-central1-d"
  }
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

###Firewall##############################################################
resource "yandex_vpc_security_group" "allow-ssh-ping" {
  name        = "Allow SSH and Ping"
  description = "Allow SSH and Ping"
  network_id  = yandex_vpc_network.gitlab.id

  labels = {
    my-label = "Allow SSH and Ping"
  }
}

resource "yandex_vpc_security_group_rule" "allow-ssh-ingress" {
  security_group_binding = yandex_vpc_security_group.allow-ssh-ping.id
  direction              = "ingress"
  description            = "Allow SSH"
  v4_cidr_blocks         = ["0.0.0.0/24"]
  port                   = 22
  protocol               = "TCP"
}

resource "yandex_vpc_security_group_rule" "allow-ssh-egress" {
  security_group_binding = yandex_vpc_security_group.allow-ssh-ping.id
  direction              = "egress"
  description            = "Allow SSH"
  v4_cidr_blocks         = ["0.0.0.0/24"]
  port                   = 22
  protocol               = "TCP"
}


resource "yandex_vpc_security_group_rule" "allow-ping-ingress" {
  security_group_binding = yandex_vpc_security_group.allow-ssh-ping.id
  direction              = "ingress"
  description            = "Allow Ping"
  v4_cidr_blocks         = ["0.0.0.0/24"]
  protocol               = "ICMP"
}

resource "yandex_vpc_security_group_rule" "allow-ping-egress" {
  security_group_binding = yandex_vpc_security_group.allow-ssh-ping.id
  direction              = "egress"
  description            = "Allow Ping"
  v4_cidr_blocks         = ["0.0.0.0/24"]
  protocol               = "ICMP"
}
