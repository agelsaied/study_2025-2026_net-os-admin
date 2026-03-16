#!/bin/bash
echo "Provisioning script $0"
echo "Install needed packages"
dnf -y install chrony
echo "Copy configuration files"
cp -R /vagrant/provision/server/ntp/etc/* /etc
restorecon -vR /etc
echo "Configure firewall"
firewall-cmd --add-service=ntp
firewall-cmd --add-service=ntp --permanent
echo "Restart chronyd service"
systemctl restart chronyd
