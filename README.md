# wvss_openvpn
1. Step 
2x VM erstellen 

2.Step auto reboot danach

Mit network.sh die Ip anpassen auf beiden VM´s 
#nano network.sh
#inhalt einfügen
#Strg + x Speichern
#Strg + o nano close
#chmod +x network.sh
#./network.sh

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

#apt install openvpn -y
ip von VPN Server im webbrowser 
-dort kann die config kopiert werden 
#nano /etc/openvpn/client.conf
#reboot




Client modprobe tun
