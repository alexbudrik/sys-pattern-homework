# Yandex Cloud Diploma Project

## Overview

This project implements a fault-tolerant web infrastructure in Yandex Cloud using Terraform and Ansible.

The infrastructure includes:

- two web servers in different availability zones
- Application Load Balancer
- NAT Gateway for private virtual machines
- bastion host
- Zabbix monitoring
- Elasticsearch + Kibana centralized logging
- Filebeat log collection
- scheduled snapshots
- infrastructure deployment with Terraform
- server configuration with Ansible

---

## Architecture

The main components are:

### Web servers

- `web-1`
  - zone: `ru-central1-a`
  - private IP: `192.168.10.21`

- `web-2`
  - zone: `ru-central1-b`
  - private IP: `192.168.20.3`

The web servers do not have public IP addresses.

### Service servers

- `zabbix`
  - private IP: `192.168.10.36`
  - FQDN: `zabbix.ru-central1.internal`

- `elasticsearch`
  - private IP: `192.168.20.24`
  - FQDN: `elasticsearch.ru-central1.internal`

- `kibana`
  - private IP: `192.168.10.15`
  - FQDN: `kibana.ru-central1.internal`

### Bastion

The bastion host is used as an administrative entry point into the private infrastructure.

### NAT Gateway

Private virtual machines use Yandex Cloud NAT Gateway to access external package repositories without receiving public IP addresses.

### Application Load Balancer

Yandex Application Load Balancer distributes HTTP traffic between `web-1` and `web-2`.

The ALB uses:

- target group
- backend group
- HTTP router
- virtual host
- HTTP health checks

---

## Project structure

```text
DIPLOM/
├── README.md
├── .gitignore
├── terraform/
│   ├── main.tf
│   ├── provider.tf
│   └── .terraform.lock.hcl
└── ansible/
    ├── inventory.ini
    ├── web.yml
    ├── zabbix-agent.yml
    ├── zabbix-server.yml
    ├── elasticsearch.yml
    ├── kibana.yml
    ├── filebeat.yml
    ├── vault.yml
    └── templates/
        └── index.html.j2