#!/bin/bash
LOGIN=elsaiedadel
PASS=123456
echo "Provisioning script $0"
echo "Install needed packages"
dnf -y install samba samba-client cifs-utils
echo "Copy configuration files"
cp -R /vagrant/provision/server/smb/etc/* /etc
chown -R root:root /etc/samba/*
restorecon -vR /etc
echo "Configure firewall"
firewall-cmd --add-service samba --permanent
firewall-cmd --reload
echo "Users and groups"
groupadd -g 1010 sambagroup
usermod -aG sambagroup $LOGIN
echo -ne "$PASS\n$PASS\n" | smbpasswd -L -a -s $LOGIN
echo "Make share dir"
mkdir -p /srv/sambashare
chgrp sambagroup /srv/sambashare
chmod g=rwx /srv/sambashare
echo "Tuning SELinux"
semanage fcontext -a -t samba_share_t "/srv/sambashare(/.*)?"
setsebool samba_export_all_rw 1
setsebool samba_export_all_rw 1 -P
restorecon -vR /srv/sambashare
echo "Start smb service"
systemctl enable smb
systemctl start smb
systemctl restart firewalld