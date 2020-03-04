# wvss_openvpn

## Getting Started

1. Step
Erstelle 2 VM's

2. Step VPN Server
Mit network.sh die Ip anpassen 
...
Mit network.sh die Ip anpassen 
nano network.sh
inhalt einfügen
Strg + x Speichern
#Strg + o nano close
#chmod +x network.sh
#./network.sh
...
Netzwerkbrücke schulnetz einstellen 


2.Step auto reboot danach

Mit network.sh die Ip anpassen auf beiden VM´s 
...
nano network.sh
inhalt aus Git einfügen
Strg + x Speichern
Strg + o nano close
chmod +x network.sh
./network.sh  ausführen
...

Netzwerkbrücke schulnetz einstellen 

3. Step 
VM die als VPN Server arbeiten soll. -> server.sh 

#nano server.sh 
#inhalt einfügen
#Strg + x Speichern
#Strg + o nano close
#chmod +x server.sh 
#./server.sh 

4. Step 
VM auf der der Client laufen soll

ip von VPN Server im webbrowser 
-dort kann die config kopiert werden 
#nano /etc/openvpn/client.conf
#reboot




Client modprobe tun
