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

resource "yandex_compute_disk" "boot-disk" {
  name = "example-disk"
  size = 5
}

resource "yandex_compute_instance" "example" {
  name        = "example"
  platform_id = "standard-v2"
  zone        = "ru-central1-d"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.foo.id
  }

  metadata = {
    foo = "bar"
  }
}
resource "yandex_vpc_network" "foo" {}


resource "yandex_vpc_subnet" "foo" {
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.foo.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}
