#!/bin/bash
LOGIN=elsaiedadel
echo "Provisioning script $0"
mkdir -p /mnt/samba
echo "Install needed packages"
dnf -y install samba-client cifs-utils
echo "Copy configuration files"
cp -R /vagrant/provision/client/smb/etc/* /etc
chown -R root:root /etc/samba/*
restorecon -vR /etc
echo "Configure firewall"
firewall-cmd --add-service samba-client --permanent
firewall-cmd --reload
echo "Users and groups"
groupadd -g 1010 sambagroup
usermod -aG sambagroup $LOGIN
echo "Mounting dirs"
mkdir -p /srv/sambashare
echo "//server/sambashare /mnt/samba cifs user,rw,credentials=/etc/samba/smbusers,uid=elsaiedadel,gid=sambagroup,_netdev 0 0" >> /etc/fstab
restorecon -vR /etc
umount /mnt/samba
mount /mnt/samba