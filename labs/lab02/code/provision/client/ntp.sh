#!/bin/bash
echo "Provisioning script $0"
echo "Copy configuration files"
cp -R /vagrant/provision/client/ntp/etc/* /etc
restorecon -vR /etc
echo "Restart chronyd service"
systemctl restart chronyd
