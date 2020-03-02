#!/bin/bash
apt install openvpn -y

echo -e "\n Dateiname für Server <>.cert"
read servername

echo -e "\n Dateiname für Client01 <>.cert"
read clientname01

echo -e "\n Dateiname für Client02 <>.cert"
read clientname02

echo -e "\n VPN Netz IP bsp. 192.168.0.0"
read VpnNetzIp

echo -e "\n Diffie Hellman Parameter Engabe von: 1024 / 2048 / 4096"
read dh

echo "VPN Server netz \n Netz:§VpnNetzIp \n Submask: 255.255.255.0 -> /24 \n"
echo "iffie Hellman Parameter \n Eingabe $dh \n"
echo "Server Dateien \n $servername.cert $servername.key \n "
echo "Client 01 Dateien \n $clientname01.cert $clientname01.key \n"
echo "Client 02 Dateien \n $clientname02.cert $clientname02.key \n"

read -p "Alle Eingaben Richtig (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        #hier könnte Werbung stehen
    ;;
    * )
        exit
    ;;
esac



echo -e "\n Easy-rsa \n"
echo -e "Erstellung der Zertifikate\n"

cd /usr/share/doc/easy-rsa/
make-cadir /root/my_ca
cd /root/my_ca

./easyrsa clean-all
./easyrsa build-ca nopass
./easyrsa gen-dh

./easyrsa build-server-full $servername nopass
./easyrsa build-client-full $clientname01 nopass
./easyrsa build-client-full $clientname02 nopass

echo -e "\n Ende Easy-rsa \n"

echo -e  "\n Diffie Hellman Parameter erzeugen \n"
openssl dhparam -out dh.pem $dh

cp /root/my_ca/pki/private/$servername.key /etc/openvpn/
cp /root/my_ca/pki/issued/$servername.crt /etc/openvpn/
cp /root/my_ca/pki/ca.crt /etc/openvpn/
cp /root/my_ca/pki/dh.pem /etc/openvpn/

path="/etc/openvpn/server.conf"

echo "server $VpnNetzIp 255.255.255.0" > $path
echo "port 1194" >> $path
echo "proto udp" >> $path
echo "dev tun" >> $path
echo "ca ca.crt" >> $path
echo "cert server.crt" >> $path
echo "key server.key" >> $path
echo "dh dh.pem" >> $path
echo "ping-timer-rem" >> $path
echo "keepalive 20 180" >> $path

systemctl restart openvpn

apt install apache2 -y
cd /var/www/html/
rm -r index.html

cp /root/my_ca/pki/ca.crt /var/www/html/
cp /root/my_ca/pki/private/client02.key /var/www/html/
cp /root/my_ca/pki/issued/client02.crt /var/www/html/
