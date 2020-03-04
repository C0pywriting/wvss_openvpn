#!/bin/bash
#===================================================
#
#       FILE:       network_client_server.sh
#
#       AUTHOR:     C0pywriting  
#
#       LINK:       https://github.com/C0pywriting
#
#       VERSION:    1.0
#
#       CREATED:    04.03.2020
#
#====================================================

echo -e "Welche IP-Adresse soll genutzt werden? \n"
read -p "bsp 10.10.raum.pc+100: " ip
echo -e "VPN Server oder VPN Client \n"
read -p "(s) Server (c) Client " Y
echo -e "Welche IP-Adresse soll genutzt werden? \n"
read -p "bsp 10.10.raum.pc+100: " ip
case ${Y:0:1} in
    s|S )
        #Server        
    ;;
    c|C )
        #Client
        read -p "VPN Server IP: " ipvpnserver
        read -p "Client name: " clientname        
    ;;
    * )
        echo "Bitte Wähle aus ob dies der Server oder dier Client ist"
        echo "versuche es noch einmal"
        exit 
    ;;
esac


clear
echo -e "\n \n"
echo "Eingaben in der Übersicht:"
echo -e "IP: $ip \n \n"

case ${Y:0:1} in
    s|S )
        #Server        
    ;;
    c|C )
        #Client
        read -p "VPN Server IP: " ipvpnserver
        read -p "Client name: " clientname       
    ;;
esac

read -p "Alle Eingaben Richtig (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        #hier könnte Werbung stehen
    ;;
    * )
        echo "Abbruch es wurde noch nichts am system veraendert!!!"
        exit
    ;;
esac

apt update
apt install openvpn -y
apt install ntp -y


case ${Y:0:1} in
    s|S )
        #Server        
    ;;
    c|C )
        #Client
        #Wget 
        wget $ipvpnserver/$clientname.conf
        mv $clientname.conf /etc/openvpn/$clientname.conf
        echo "Es kann bei server_vars.sh weiter gehen"
        read -p "Weiter gegangen? (y/n)? " weiter
case ${weiter:0:1} in
    y|Y )
        #hier könnte Werbung stehen
        
    ;;
    * )
        
        
    ;;
esac
    ;;
esac


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

read -p "reboot? (y/n)? " re
case ${re:0:1} in
    y|Y )
        #hier könnte Werbung stehen
        reboot
    ;;
    * )
        
        exit
    ;;
esac
