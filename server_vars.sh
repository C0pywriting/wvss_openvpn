#!/bin/bash
#===================================================
#
#       FILE:       server_vars.sh
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

clear
ip a
echo -e "\n \n Bitte gebe die Variablen ein: \n"
read -p "Dateiname für Server <>.cert? " servername
read -p "Dateiname für Client01 <>.cert? " clientname01
read -p "Dateiname für Client02 <>.cert? " clientname02
read -p "VPN Netz IP bsp. (n) 10.8.0.0? " VpnNetzIp
case ${VpnNetzIp:0:1} in
    n|N )
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
echo -e "\n \n Easy Rsa Vars Einstellungen:"
echo -e "Standardwerte mit (1) Uebernehmen: \n"
echo "Land:         DE"
echo "Bundesland:   Baden-Wuerttemberg"
echo "Stadt:        Mannheim"
echo "Organisation: Private Organization"
echo "E-Mail:       mail@example.com"
echo "OU:           Private OU"

read -p "Land? " country
case ${country:0:1} in
    1 )
        country="DE"
    ;;
    * )
        
    ;;
esac

read -p "Bundesland? " province
case ${province:0:1} in
    1 )
        province="Baden-Wuerttemberg"
    ;;
    * )
        
    ;;
esac

read -p "Stadt? " city
case ${city:0:1} in
    1 )
        city="Mannheim"
    ;;
    * )
        
    ;;
esac

read -p "Organisation? " org
case ${org:0:1} in
    1 )
        org="Private Organization"
    ;;
    * )
        
    ;;
esac

read -p "E-Mail? " mail
case ${mail:0:1} in
    1 )
        mail="mail@example.com"
    ;;
    * )
        
    ;;
esac

read -p "OU? " ou
case ${ou:0:1} in
    1 )
        ou="Private OU"
    ;;
    * )
        
    ;;
esac
read -p "Tage die das ca gültig sein soll 3650? " tageca
read -p "Tage die das crt gültig sein soll 1080? " tagecrt
clear
echo -e "\n \n"
echo "Eingaben in der Übersicht:"
echo -e "VPN \n Netz: $VpnNetzIp \n Submask: 255.255.255.0 -> /24 \n"
echo -e "VPN Server \n IP: $serverip \n"
echo -e "Diffie Hellman Parameter \n Eingabe: $dh \n"
echo -e "Server Dateien \n $servername.cert \n $servername.key \n "
echo -e "Client 01 Dateien \n $clientname01.cert \n $clientname01.key \n"
echo -e "Client 02 Dateien \n $clientname02.cert \n $clientname02.key \n"
echo -e "Easy Rsa Vars Einstellungen: \n"
echo "Land: $country"
echo "Bundesland: $province"
echo "Stadt: $city"
echo "Organisation: $org"
echo "E-Mail: $mail"
echo "OU: $ou"

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
#Start
echo -e "\n Lehne dich zurück wir arbeiten jetzt für dich ....."

echo -e "\n \n \n     Easy-rsa \n"
echo -e "Erstellung der Zertifikate\n"

cd /usr/share/doc/easy-rsa/
make-cadir /root/my_ca
cd /root/my_ca
#Vars Einstellungen übernehmen und in vars schreiben 

echo "set_var EASYRSA_DN     "org"" >> vars
echo "set_var EASYRSA_REQ_COUNTRY     "$country"" >> vars
echo "set_var EASYRSA_REQ_PROVINCE    "$province"" >> vars
echo "set_var EASYRSA_REQ_CITY        "$city"" >> vars
echo "set_var EASYRSA_REQ_ORG         "$org"" >> vars
echo "set_var EASYRSA_REQ_EMAIL       "$mail"" >> vars
echo "set_var EASYRSA_REQ_OU          "$ou"" >> vars

#Tage der vars einstellen

echo "set_var EASYRSA_CA_EXPIRE          "$tageca"" >> vars
echo "set_var EASYRSA_CERT_EXPIRE          "$tagecrt"" >> vars


echo -e "\n Initialize PKI \n"

./vars
./easyrsa clean-all
./easyrsa build-ca nopass
#./easyrsa gen-dh


echo -e "\n Create Server Certificates \n"
#Create Server Certificates
./easyrsa build-server-full $servername nopass


echo -e "\n Create Client Certificate \n"
#Create Client Certificate
./easyrsa build-client-full $clientname01 nopass
./easyrsa build-client-full $clientname02 nopass

echo -e "\n Ende Easy-rsa \n"
cd /etc/openvpn/
echo -e  "Diffie Hellman Parameter erzeugen \n"
openssl dhparam -out dh.pem $dh
clear


#OpenVpn wird nun vorbereitet
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

#OpenVpn Client confs

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


#Ende OpenVpn

#Weitergabe der Client confs über Webserver

apt install apache2 -y
cd /var/www/html/
rm -r index.html

cp $clientpath /var/www/html/
cp $clientpath2 /var/www/html/
clear
#User Infos

echo -e "VPN Server ist fertig!"
echo -e "Die Client .conf findest du unter:"
echo -e "http://$serverip"
echo -e "\n"
echo -e "Angaben für network_client_server.sh"
echo -e "Clientname:    $clientname01"
echo -e "ServerIP:      $serverip"
echo -e ""
echo -e ""
echo -e "Warten bis beim Client gemeldet wird das es hier weiter gehen kann"
read -p "Bitte warten weiter mit (y)? " ncs
case ${ncs:0:1} in
    y|Y )
        
    ;;
    * )
       echo -e "Warten bis beim Client gemeldet wird das es hier weiter gehen kann"
        read -p "Bitte warten weiter mit (y)? " ncs1
case ${ncs1:0:1} in
    y|Y )
        
    ;;
    * )
        
        
    ;;
esac 
        
    ;;
esac

#Neustart
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
