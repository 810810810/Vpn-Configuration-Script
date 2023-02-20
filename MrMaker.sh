#!/bin/bash

# Set variables
SERVER_IP="<server_ip_address>"
CLIENT_NAME="client1"

# Update the system
sudo apt update
sudo apt upgrade -y

# Install OpenVPN and EasyRSA
sudo apt install openvpn easy-rsa -y

# Create a directory for the VPN server configuration files
sudo mkdir /etc/openvpn/server

# Copy the EasyRSA scripts to the VPN server directory
sudo cp -r /usr/share/easy-rsa/* /etc/openvpn/server/

# Initialize the PKI (public key infrastructure) for the VPN server
cd /etc/openvpn/server/easy-rsa/
sudo ./easyrsa init-pki

# Generate the CA (certificate authority) for the VPN server
sudo ./easyrsa build-ca nopass

# Generate the server key and certificate
sudo ./easyrsa build-server-full server nopass

# Generate the Diffie-Hellman parameters
sudo ./easyrsa gen-dh

# Copy the generated files to the VPN server directory
sudo cp /etc/openvpn/server/easy-rsa/pki/ca.crt /etc/openvpn/server/
sudo cp /etc/openvpn/server/easy-rsa/pki/dh.pem /etc/openvpn/server/
sudo cp /etc/openvpn/server/easy-rsa/pki/issued/server.crt /etc/openvpn/server/
sudo cp /etc/openvpn/server/easy-rsa/pki/private/server.key /etc/openvpn/server/

# Create the OpenVPN server configuration file
sudo touch /etc/openvpn/server/server.conf
sudo chmod 777 /etc/openvpn/server/server.conf
echo "port 1194" >> /etc/openvpn/server/server.conf
echo "proto udp" >> /etc/openvpn/server/server.conf
echo "dev tun" >> /etc/openvpn/server/server.conf
echo "ca /etc/openvpn/server/ca.crt" >> /etc/openvpn/server/server.conf
echo "cert /etc/openvpn/server/server.crt" >> /etc/openvpn/server/server.conf
echo "key /etc/openvpn/server/server.key" >> /etc/openvpn/server/server.conf
echo "dh /etc/openvpn/server/dh.pem" >> /etc/openvpn/server/server.conf
echo "server 10.8.0.0 255.255.255.0" >> /etc/openvpn/server/server.conf
echo "ifconfig-pool-persist ipp.txt" >> /etc/openvpn/server/server.conf
echo "push \"redirect-gateway def1 bypass-dhcp\"" >> /etc/openvpn/server/server.conf
echo "push \"dhcp-option DNS 8.8.8.8\"" >> /etc/openvpn/server/server.conf
echo "keepalive 10 120" >> /etc/openvpn/server/server.conf
echo "cipher AES-256-CBC" >> /etc/openvpn/server/server.conf
echo "user nobody" >> /etc/openvpn/server/server.conf
echo "group nogroup" >> /etc/openvpn/server/server.conf
echo "persist-key" >> /etc/openvpn/server/server.conf
echo "persist-tun" >> /etc/openvpn/server/server.conf
echo "status openvpn-status.log" >> /etc/openvpn/server/server.conf
echo "verb 3" >> /etc/openvpn/server/server.conf

# Enable IP forwarding
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo sysctl -p

# Enable UFW (uncomplicated firewall) and allow OpenVPN traffic
sudo ufw allow OpenSSH
sudo ufw allow 1194/udp
sudo ufw --force enable

# Create a directory for the client configuration files
mkdir ~/openvpn-client-configs
chmod 700 ~/openvpn-client-configs

# Generate the client key and certificate
cd /etc/openvpn/server/easy-rsa/
./easyrsa build-client-full $CLIENT_NAME nopass

# Create the client configuration file
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/openvpn-client-configs/$CLIENT_NAME.ovpn
sed -i "s/remote my-server-1 1194/remote $SERVER_IP 1194/g" ~/openvpn-client-configs/$CLIENT_NAME.ovpn
sed -i "s/;user nobody/user nobody/g" ~/openvpn-client-configs/$CLIENT_NAME.ovpn
sed -i "s/;group nogroup/group nogroup/g" ~/openvpn-client-configs/$CLIENT_NAME.ovpn
echo "<ca>" >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
cat /etc/openvpn/server/ca.crt >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
echo "</ca>" >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
echo "<cert>" >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
cat /etc/openvpn/server/easy-rsa/pki/issued/$CLIENT_NAME.crt >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
echo "</cert>" >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
echo "<key>" >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
cat /etc/openvpn/server/easy-rsa/pki/private/$CLIENT_NAME.key >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
echo "</key>" >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn

# Move the client configuration file to the desktop
cp ~/openvpn-client-configs/$CLIENT_NAME.ovpn ~/Desktop/

# Set permissions
chmod 600 ~/openvpn-client-configs/$CLIENT_NAME.ovpn
