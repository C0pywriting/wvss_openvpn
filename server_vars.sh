#!/bin/bash

clear
ip a
echo -e "\n \n Bitte gebe die Variablen ein: \n"
#echo -e "Dateiname für Server <>.cert"
read -p "Dateiname für Server <>.cert? " servername

#echo -e "\n Dateiname für Client01 <>.cert"
read -p "Dateiname für Client01 <>.cert? " clientname01

#echo -e "\n Dateiname für Client02 <>.cert"
read -p "Dateiname für Client02 <>.cert? " clientname02

#echo -e "\n VPN Netz IP bsp. 192.168.0.0"
read -p "VPN Netz IP bsp. (1) 10.8.0.0? " VpnNetzIp
case ${VpnNetzIp:0:1} in
    1 )
        VpnNetzIp="10.8.0.0"
    ;;
    * )
        
    ;;
esac
read -p "VPN Server IP? " serverip

echo -e "\n Diffie Hellman Parameter Engabe"
read -p "Bitte wähle: (1) 2048 / (2) 4096? " dh
case ${dh:0:1} in
    1 )
        dh="2048"
    ;;
    2 )
        dh="4096"
    ;;
esac

clear
echo -e "\n \n"
echo "Eingaben in der Übersicht:"
echo -e "VPN \n Netz: $VpnNetzIp \n Submask: 255.255.255.0 -> /24 \n"
echo -e "VPN Server \n IP: $serverip \n"
echo -e "Diffie Hellman Parameter \n Eingabe: $dh \n"
echo -e "Server Dateien \n $servername.cert \n $servername.key \n "
echo -e "Client 01 Dateien \n $clientname01.cert \n $clientname01.key \n"
echo -e "Client 02 Dateien \n $clientname02.cert \n $clientname02.key \n"

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
echo -e "\n Lehne dich zurück wir arbeiten jetzt für dich ....."

echo -e "\n \n \n     Easy-rsa \n"
echo -e "Erstellung der Zertifikate\n"

cd /usr/share/doc/easy-rsa/
make-cadir /root/my_ca
cd /root/my_ca

echo "set_var EASYRSA_REQ_COUNTRY     "DE"" >> vars
echo "set_var EASYRSA_REQ_PROVINCE    "Baden-Wuerttemberg"" >> vars
echo "set_var EASYRSA_REQ_CITY        "Mannheim"" >> vars
echo "set_var EASYRSA_REQ_ORG "Private Organization"" >> vars
echo "set_var EASYRSA_REQ_EMAIL       "mail@example.com"" >> vars
echo "set_var EASYRSA_REQ_OU          "Private OU"" >> vars

echo -e "\n Initialize PKI \n"

. ./vars
./easyrsa clean-all
./easyrsa build-ca nopass
./easyrsa gen-dh


echo -e "\n Create Server Certificates \n"
#3. Create Server Certificates
./easyrsa build-server-full $servername nopass


echo -e "\n Create Client Certificate \n"
#4. Create Client Certificate
./easyrsa build-client-full $clientname01 nopass
./easyrsa build-client-full $clientname02 nopass

echo -e "\n Ende Easy-rsa \n"
cd /etc/openvpn/
echo -e  "Diffie Hellman Parameter erzeugen \n"
openssl dhparam -out dh.pem $dh

echo -e "Server key / cert / ca.cert / dh.pem werden in /etc/openvpn/ kopiert \n"
cp /root/my_ca/pki/private/$servername.key /etc/openvpn/
cp /root/my_ca/pki/issued/$servername.crt /etc/openvpn/
cp /root/my_ca/pki/ca.crt /etc/openvpn/
cp /root/my_ca/pki/dh.pem /etc/openvpn/

echo -e "server.conf wird in /etc/openvpn/ erstellt \n"
path="/etc/openvpn/server.conf"

echo "server $VpnNetzIp 255.255.255.0" > $path
echo "port 1194" >> $path
echo "proto udp" >> $path
echo "dev tun" >> $path
echo "ca ca.crt" >> $path
echo "cert $servername.crt" >> $path
echo "key $servername.key" >> $path
echo "dh dh.pem" >> $path
echo "ping-timer-rem" >> $path
echo "keepalive 20 180" >> $path
echo "tls-server" >> $path

systemctl restart openvpn

echo "VPN Server ist aktiv"


echo "Client01 conf erstellen"
mkdir /home/tmp
cd /home/tmp
cp /root/my_ca/pki/issued/$clientname01.crt $clientname01.crt
cp /root/my_ca/pki/private/$clientname01.key $clientname01.key
cp /root/my_ca/pki/ca.crt ca.cert

clientpath="/home/tmp/$clientname01.conf"
echo "client" > $clientpath
echo "remote $serverip 1194" >> $clientpath
echo "proto udp" >> $clientpath
echo "dev tun" >> $clientpath
echo "ping-timer-rem" >> $clientpath
echo "keepalive 20 180" >> $clientpath
echo "tls-client" >> $clientpath
echo "<ca>" >> $clientpath
cat ca.cert >> $clientpath 
echo "</ca>" >> $clientpath
echo "<cert>" >> $clientpath
cat $clientname01.crt >> $clientpath 
echo "</cert>" >> $clientpath
echo "<key>" >> $clientpath
cat $clientname01.key >> $clientpath 
echo "</key>" >> $clientpath

echo "Client02 conf erstellen"
cp /root/my_ca/pki/issued/$clientname02.crt $clientname02.crt
cp /root/my_ca/pki/private/$clientname02.key $clientname02.key


clientpath2="/home/tmp/$clientname02.conf"

echo "client" > $clientpath2
echo "remote $serverip 1194" >> $clientpath2
echo "proto udp" >> $clientpath2
echo "dev tun" >> $clientpath2
echo "ping-timer-rem" >> $clientpath2
echo "keepalive 20 180" >> $clientpath2
echo "tls-client" >> $clientpath2
echo "<ca>" >> $clientpath2
cat ca.cert >> $clientpath2 
echo "</ca>" >> $clientpath2
echo "<cert>" >> $clientpath2
cat $clientname02.crt >> $clientpath2
echo "</cert>" >> $clientpath2
echo "<key>" >> $clientpath2
cat $clientname02.key >> $clientpath2 
echo "</key>" >> $clientpath2


#--------

apt install apache2 -y
cd /var/www/html/
rm -r index.html

cp $clientpath /var/www/html/
cp $clientpath2 /var/www/html/


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
