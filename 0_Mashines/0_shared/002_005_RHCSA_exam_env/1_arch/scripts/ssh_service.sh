#!/bin/bash

# ssh_services=("sshd" "ssh")
#
# for svc in "${ssh_services[@]}"; do
#   systemctl status "$svc" 2>/dev/null && break
# done

echo "===== CHECKING SYSTEMD STATE ====="
systemctl is-system-running 2>/dev/null

echo
echo "===== CHECKING SSH SERVICE ====="
ssh_services=("sshd" "ssh")
for svc in "${ssh_services[@]}"; do
  if systemctl status "$svc" >/dev/null 2>&1; then
    echo "Found SSH service: $svc"
    systemctl status "$svc"
    break
  fi
done

echo
echo "===== CHECKING NETWORK SERVICES ====="
net_services=("systemd-networkd" "NetworkManager")
for svc in "${net_services[@]}"; do
  systemctl status "$svc" >/dev/null 2>&1 && systemctl status "$svc"
done

echo
echo "===== CHECKING FIREWALL SERVICES ====="
fw_services=("firewalld" "ufw")
for svc in "${fw_services[@]}"; do
  if command -i >/dev/null 2>&1; then
    echo "$svc is installed"
  fi
done

echo
echo "===== CHECKING OPEN PORTS ====="
ss -tulpn
