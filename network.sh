#!/bin/bash

apt update
echo Welche IP-Adresse soll genutzt werden?
read ip

path="/etc/network/interfaces"

echo "source /etc/network/interfaces.d/*" > $path
echo "" >> $path
echo "auto enp0s3" >> $path
echo "iface enp0s3 inet static" >> $path
echo "address $ip" >> $path
echo "netmask 255.0.0.0" >> $path
echo "gateway 10.16.1.245" >> $path

path2="/etc/resolv.conf"
echo "nameserver 10.16.1.253" > $path2

systemctl restart networking
reboot
