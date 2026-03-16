#!/bin/bash

echo "Provisioning script $0"

nmcli connection modify "eth1" ipv4.gateway "192.168.1.1"
nmcli connection up "eth1"

nmcli connection modify eth0 ipv4.never-default true
nmcli connection modify eth0 ipv6.never-default true

nmcli connection down eth0
nmcli connection up eth0

# systemctl restart NetworkManager
