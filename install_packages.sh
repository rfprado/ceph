#!/bin/bash
echo "=== Instalando dependências ==="
sudo dnf upgrade --refresh -y
sudo dnf config-manager --set-enabled crb -y
sudo dnf install -y epel-release epel-next-release
sudo dnf update -y
sudo dnf install -y sshpass net-tools bind-utils vim nmap-ncat
sudo dnf install -y ansible git chrony