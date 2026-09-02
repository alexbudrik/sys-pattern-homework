# ============================================================
# LOCALS
# ============================================================

locals {
  subnets = {
    subnet-a = {
      name = "diplom-subnet"
      zone = "ru-central1-a"
      cidr = "192.168.10.0/24"
    }

    subnet-b = {
      name = "diplom-subnet-b"
      zone = "ru-central1-b"
      cidr = "192.168.20.0/24"
    }
  }

  web_servers = {
    web-1 = {
      zone       = "ru-central1-a"
      subnet_key = "subnet-a"
    }

    web-2 = {
      zone       = "ru-central1-b"
      subnet_key = "subnet-b"
    }
  }

  service_servers = {
    zabbix = {
      zone       = "ru-central1-a"
      subnet_key = "subnet-a"
      memory     = 2
    }

    elasticsearch = {
      zone       = "ru-central1-b"
      subnet_key = "subnet-b"
      memory     = 4
    }

    kibana = {
      zone       = "ru-central1-a"
      subnet_key = "subnet-a"
      memory     = 2
    }
  }

  internal_cidrs = [
    for subnet in local.subnets : subnet.cidr
  ]
}


# ============================================================
# NETWORK
# ============================================================

resource "yandex_vpc_network" "diplom_network" {
  name = "diplom-network"
}


# ============================================================
# NAT GATEWAY
# ============================================================

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "diplom-nat-gateway"

  shared_egress_gateway {}
}


resource "yandex_vpc_route_table" "private_route_table" {
  name       = "diplom-private-route-table"
  network_id = yandex_vpc_network.diplom_network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}


# ============================================================
# SUBNETS
# ============================================================

resource "yandex_vpc_subnet" "subnets" {
  for_each = local.subnets

  name           = each.value.name
  zone           = each.value.zone
  network_id     = yandex_vpc_network.diplom_network.id
  v4_cidr_blocks = [each.value.cidr]
  route_table_id = yandex_vpc_route_table.private_route_table.id
}


# Existing subnet resources were refactored to for_each.

moved {
  from = yandex_vpc_subnet.diplom_subnet
  to   = yandex_vpc_subnet.subnets["subnet-a"]
}

moved {
  from = yandex_vpc_subnet.diplom_subnet_b
  to   = yandex_vpc_subnet.subnets["subnet-b"]
}


# ============================================================
# ALB SECURITY GROUP
# ============================================================

resource "yandex_vpc_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for Application Load Balancer"
  network_id  = yandex_vpc_network.diplom_network.id

  ingress {
    description    = "HTTP from Internet"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


# ============================================================
# WEB SECURITY GROUP
# ============================================================

resource "yandex_vpc_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security group for web servers"
  network_id  = yandex_vpc_network.diplom_network.id

  ingress {
    description    = "SSH from internal network"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = local.internal_cidrs
  }

  ingress {
    description       = "HTTP from ALB health checks"
    protocol          = "TCP"
    port              = 80
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    description       = "HTTP from Application Load Balancer"
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.alb_sg.id
  }

  ingress {
    description    = "Zabbix agent"
    protocol       = "TCP"
    port           = 10050
    v4_cidr_blocks = local.internal_cidrs
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


# ============================================================
# MONITORING / LOGGING SECURITY GROUP
# ============================================================

resource "yandex_vpc_security_group" "ops_sg" {
  name        = "ops-sg"
  description = "Security group for Zabbix, Elasticsearch and Kibana"
  network_id  = yandex_vpc_network.diplom_network.id

  ingress {
    description    = "SSH from internal network"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = local.internal_cidrs
  }

  ingress {
    description    = "Zabbix web interface"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = local.internal_cidrs
  }

  ingress {
    description    = "Zabbix server"
    protocol       = "TCP"
    port           = 10051
    v4_cidr_blocks = local.internal_cidrs
  }

  ingress {
    description    = "Elasticsearch API"
    protocol       = "TCP"
    port           = 9200
    v4_cidr_blocks = local.internal_cidrs
  }

  ingress {
    description    = "Kibana web interface"
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = local.internal_cidrs
  }

  egress {
    description    = "Allow outbound traffic through NAT"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


# ============================================================
# WEB SERVERS
# ============================================================

resource "yandex_compute_instance" "web" {
  for_each = local.web_servers

  name        = each.key
  hostname    = each.key
  platform_id = "standard-v3"
  zone        = each.value.zone

  # Existing service account is retained for compatibility
  # with the current infrastructure.
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
    subnet_id = yandex_vpc_subnet.subnets[each.value.subnet_key].id
    nat       = false

    security_group_ids = [
      yandex_vpc_security_group.web_sg.id
    ]
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
            - ${file(pathexpand("~/.ssh/id_ed25519.pub"))}
    EOF
  }

  scheduling_policy {
    preemptible = false
  }
}


moved {
  from = yandex_compute_instance.web_1
  to   = yandex_compute_instance.web["web-1"]
}

moved {
  from = yandex_compute_instance.web_2
  to   = yandex_compute_instance.web["web-2"]
}


# ============================================================
# BASTION
# ============================================================

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

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
    subnet_id = yandex_vpc_subnet.subnets["subnet-a"].id
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
            - ${file(pathexpand("~/.ssh/id_ed25519.pub"))}
    EOF
  }

  scheduling_policy {
    preemptible = false
  }
}


# ============================================================
# ZABBIX / ELASTICSEARCH / KIBANA SERVERS
# ============================================================

resource "yandex_compute_instance" "service" {
  for_each = local.service_servers

  name        = each.key
  hostname    = each.key
  platform_id = "standard-v3"
  zone        = each.value.zone

  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = each.value.memory
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
    subnet_id = yandex_vpc_subnet.subnets[each.value.subnet_key].id

    # No public IP.
    # Internet access is provided by NAT Gateway.
    nat = false

    security_group_ids = [
      yandex_vpc_security_group.ops_sg.id
    ]
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
            - ${file(pathexpand("~/.ssh/id_ed25519.pub"))}
    EOF
  }

  scheduling_policy {
    preemptible = false
  }
}


# ============================================================
# APPLICATION LOAD BALANCER TARGET GROUP
# ============================================================

resource "yandex_alb_target_group" "web_target_group" {
  name = "web-alb-target-group"

  dynamic "target" {
    for_each = yandex_compute_instance.web

    content {
      subnet_id  = target.value.network_interface[0].subnet_id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}


# ============================================================
# ALB BACKEND GROUP
# ============================================================

resource "yandex_alb_backend_group" "web_backend_group" {
  name = "web-backend-group"

  http_backend {
    name             = "web-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web_target_group.id]

    load_balancing_config {
      panic_threshold = 50
    }

    healthcheck {
      timeout             = "3s"
      interval            = "5s"
      healthy_threshold   = 2
      unhealthy_threshold = 2

      http_healthcheck {
        path = "/"
      }
    }
  }
}


# ============================================================
# HTTP ROUTER
# ============================================================

resource "yandex_alb_http_router" "web_router" {
  name = "web-http-router"
}


# ============================================================
# VIRTUAL HOST
# ============================================================

resource "yandex_alb_virtual_host" "web_virtual_host" {
  name           = "web-virtual-host"
  http_router_id = yandex_alb_http_router.web_router.id

  route {
    name = "web-route"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_backend_group.id
        timeout          = "5s"
      }
    }
  }
}


# ============================================================
# APPLICATION LOAD BALANCER
# ============================================================

resource "yandex_alb_load_balancer" "web_alb" {
  name       = "web-application-load-balancer"
  network_id = yandex_vpc_network.diplom_network.id

  security_group_ids = [
    yandex_vpc_security_group.alb_sg.id
  ]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnets["subnet-a"].id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnets["subnet-b"].id
    }
  }

  listener {
    name = "http-listener"

    endpoint {
      address {
        external_ipv4_address {}
      }

      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.web_router.id
      }
    }
  }
}


# ============================================================
# SNAPSHOT SCHEDULE
# ============================================================

resource "yandex_compute_snapshot_schedule" "web_backup" {
  name        = "web-daily-backup"
  description = "Daily snapshots of diploma virtual machines"

  schedule_policy {
    expression = "0 2 * * *"
  }

  snapshot_count = 7

  snapshot_spec {
    description = "Daily diploma infrastructure backup"

    labels = {
      project = "diplom"
      type    = "daily-backup"
    }
  }

  disk_ids = concat(
    [
      for vm in yandex_compute_instance.web :
      vm.boot_disk[0].disk_id
    ],
    [
      for vm in yandex_compute_instance.service :
      vm.boot_disk[0].disk_id
    ],
    [
      yandex_compute_instance.bastion.boot_disk[0].disk_id
    ]
  )
}


# ============================================================
# OUTPUTS
# ============================================================

output "alb_public_ip" {
  description = "Public IP address of Application Load Balancer"

  value = try(
    yandex_alb_load_balancer.web_alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address,
    null
  )
}


output "service_private_ips" {
  description = "Private IP addresses of Zabbix, Elasticsearch and Kibana"

  value = {
    for name, vm in yandex_compute_instance.service :
    name => vm.network_interface[0].ip_address
  }
}


output "service_fqdns" {
  description = "Internal FQDN names of service servers"

  value = {
    for name, vm in yandex_compute_instance.service :
    name => vm.fqdn
  }
}