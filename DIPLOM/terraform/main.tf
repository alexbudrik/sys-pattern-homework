resource "yandex_vpc_network" "diplom_network" {
  name = "diplom-network"
}

resource "yandex_vpc_subnet" "diplom_subnet" {
  name           = "diplom-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diplom_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "diplom_subnet_b" {
  name           = "diplom-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diplom_network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_vpc_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security group for web servers"
  network_id  = yandex_vpc_network.diplom_network.id

  ingress {
    description = "SSH from internal network"
    protocol    = "TCP"
    port        = 22

    v4_cidr_blocks = [
      "192.168.10.0/24",
      "192.168.20.0/24"
    ]
  }

  ingress {
    description    = "HTTP traffic via load balancer"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "NLB health checks"
    protocol          = "TCP"
    port              = 80
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "web_1" {
  name                      = "web-1"
  hostname                  = "web-1"
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"
  service_account_id        = "aje13md9tfjgjqm5eb6k"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8qmr57ndfedjv8lfgk"
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.diplom_subnet.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web_sg.id]
  }

  metadata = {
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ubuntu
          groups: sudo
          shell: /bin/bash
          sudo: 'ALL=(ALL) NOPASSWD:ALL'
          ssh_authorized_keys:
            - ${file("C:/Users/sasha/.ssh/id_ed25519.pub")}
    EOF
  }

  scheduling_policy {
    preemptible = false
  }
}

resource "yandex_compute_instance" "bastion" {
  name                      = "bastion"
  hostname                  = "bastion"
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8qmr57ndfedjv8lfgk"
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.diplom_subnet.id
    nat       = true
  }

  metadata = {
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ubuntu
          groups: sudo
          shell: /bin/bash
          sudo: 'ALL=(ALL) NOPASSWD:ALL'
          ssh_authorized_keys:
            - ${file("C:/Users/sasha/.ssh/id_ed25519.pub")}
    EOF
  }

  scheduling_policy {
    preemptible = false
  }
}

resource "yandex_compute_instance" "web_2" {
  name                      = "web-2"
  hostname                  = "web-2"
  platform_id               = "standard-v3"
  zone                      = "ru-central1-b"
  service_account_id        = "aje13md9tfjgjqm5eb6k"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8qmr57ndfedjv8lfgk"
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.diplom_subnet_b.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web_sg.id]
  }

  metadata = {
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ubuntu
          groups: sudo
          shell: /bin/bash
          sudo: 'ALL=(ALL) NOPASSWD:ALL'
          ssh_authorized_keys:
            - ${file("C:/Users/sasha/.ssh/id_ed25519.pub")}
    EOF
  }

  scheduling_policy {
    preemptible = false
  }
}

resource "yandex_lb_target_group" "web_target_group" {
  name = "web-target-group"

  target {
    subnet_id = yandex_vpc_subnet.diplom_subnet.id
    address   = yandex_compute_instance.web_1.network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.diplom_subnet_b.id
    address   = yandex_compute_instance.web_2.network_interface[0].ip_address
  }
}

resource "yandex_lb_network_load_balancer" "web_lb" {
  name = "web-load-balancer"

  listener {
    name = "http-listener"
    port = 80

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web_target_group.id

    healthcheck {
      name = "http-healthcheck"

      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

resource "yandex_compute_snapshot_schedule" "web_backup" {
  name        = "web-daily-backup"
  description = "Daily snapshots of web-1 and web-2"

  schedule_policy {
    expression = "0 2 * * *"
  }

  snapshot_count = 7

  snapshot_spec {
    description = "Daily web server backup"

    labels = {
      project = "diplom"
      type    = "daily-backup"
    }
  }

  disk_ids = [
    yandex_compute_instance.web_1.boot_disk[0].disk_id,
    yandex_compute_instance.web_2.boot_disk[0].disk_id
  ]
}