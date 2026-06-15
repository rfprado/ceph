#!/bin/bash
# /scripts/setup_network.sh

# Identificação dinâmica das interfaces (evita hardcode eth0/eth1)
# eth0 geralmente é a primeira (NAT), eth1 a segunda (Privada)
NAT_IFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
PRIVATE_IFACE=$(ip -o -4 addr show | grep '192.168.1' | awk '{print $2}')

echo "=== Configurando rotas ==="

# 1. Ajusta interface NAT para ser a preferencial (métrica 50)
if [ -n "$NAT_IFACE" ]; then
  sudo nmcli connection modify "$NAT_IFACE" ipv4.route-metric 50
  sudo nmcli connection up "$NAT_IFACE"
fi

# 2. Ajusta interface Privada para ser estritamente interna (métrica 200)
# E garante que ela NÃO tenha um gateway definido
if [ -n "$PRIVATE_IFACE" ]; then
  sudo nmcli connection modify "$PRIVATE_IFACE" ipv4.route-metric 200
  sudo nmcli connection modify "$PRIVATE_IFACE" ipv4.gateway ""
  sudo nmcli connection modify "$PRIVATE_IFACE" ipv4.never-default yes
  sudo nmcli connection up "$PRIVATE_IFACE"
fi

# 3. Força o DNS (o resolv.conf no Rocky Linux pode ser sobrescrito pelo NetworkManager)
sudo nmcli device modify "$NAT_IFACE" ipv4.dns "8.8.8.8 1.1.1.1"