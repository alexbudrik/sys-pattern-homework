\# Yandex Cloud Diploma Project



\## Overview



This project implements a fault-tolerant web infrastructure in Yandex Cloud using Terraform and Ansible.



The infrastructure includes:



\- two web servers in different availability zones

\- Network Load Balancer

\- bastion host

\- Nginx configuration

\- monitoring with Yandex Unified Agent

\- centralized Nginx log collection

\- scheduled disk snapshots

\- infrastructure deployment with Terraform

\- server configuration with Ansible



\---



\## Architecture



The infrastructure consists of:



\- `web-1`

&#x20; - zone: `ru-central1-a`

&#x20; - private IP: `192.168.10.21`



\- `web-2`

&#x20; - zone: `ru-central1-b`

&#x20; - private IP: `192.168.20.3`



\- `bastion`

&#x20; - zone: `ru-central1-a`

&#x20; - public SSH entry point



\- Network Load Balancer

&#x20; - distributes HTTP traffic between `web-1` and `web-2`



The web servers do not have public IP addresses.



Ansible connects to the web servers using internal FQDN names:



```text

web-1.ru-central1.internal

web-2.ru-central1.internal

