# wvss_openvpn

## Getting Started

Step 1
- Erstelle 2 VM's

Step 2 VPN Server -> network_client_server.sh Ip anpassen 
- nano network.sh
- inhalt einfügen
- Strg + x Speichern
- Strg + o nano close
- chmod +x network.sh
- ./network.sh
- Server startet neu

Netzwerkbrücke schulnetz einstellen 

Step 3 VPN Server -> server_vars.sh 
- nano server.sh 
- inhalt einfügen
- Strg + x Speichern
- Strg + o nano close
- chmod +x server.sh 
- ./server.sh 

Step 4 VPN Linux Client -> network_client_server.sh
- client einstellungen
- Client startet neu 

Netzwerkbrücke schulnetz einstellen nach reboot


Bei evtl problemen diesen Befehl absetzen.
- modprobe tun
