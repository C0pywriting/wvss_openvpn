# wvss_openvpn

## Getting Started

Step 1
- Erstelle 2 VM's

Step 2 VPN Server
Mit network.sh die Ip anpassen 

- nano network.sh
- inhalt einfügen
- Strg + x Speichern
- Strg + o nano close
- chmod +x network.sh
- ./network.sh

Netzwerkbrücke schulnetz einstellen 

Step 3
VM die als VPN Server arbeiten soll. -> server.sh 

- nano server.sh 
- inhalt einfügen
- Strg + x Speichern
- Strg + o nano close
- chmod +x server.sh 
- ./server.sh 

Step 4
VM auf der der Client laufen soll

ip von VPN Server im webbrowser 
-dort kann die config kopiert werden 
nano /etc/openvpn/client.conf
reboot




Client modprobe tun
