#!/bin/bash

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

Is is script complete?
This script appears to be complete and is designed to set up an OpenVPN server on a Ubuntu system. It includes the following steps:

Updates the system
Installs OpenVPN and EasyRSA
Creates a directory for the VPN server configuration files
Copies the EasyRSA scripts to the VPN server directory
Initializes the PKI for the VPN server
Generates the CA for the VPN server
Generates the server key and certificate
Generates the Diffie-Hellman parameters
Copies the generated files to the VPN server directory
Creates the OpenVPN server configuration file
Enables IP forwarding
Enables UFW and allows OpenVPN traffic
However, before running the script, you should review and understand each step to ensure that it is appropriate for your use case and modify as needed. Additionally, you should verify that the necessary packages are available and properly configured on your system.




Austin Persaud
Modify the script to output a .ovpn file from the server it creates to desktop 
To output a .ovpn file from the OpenVPN server created by the script to the desktop, you can add the following commands to the end of the script:

bash
Copy code
# Create the .ovpn file for the client
sudo cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/server/client.ovpn
sudo sed -i 's/remote my-server-1 1194/remote <server_ip_address> 1194/g' /etc/openvpn/server/client.ovpn
sudo sed -i 's/;user nobody/user nobody/g' /etc/openvpn/server/client.ovpn
sudo sed -i 's/;group nogroup/group nogroup/g' /etc/openvpn/server/client.ovpn
sudo echo "" >> /etc/openvpn/server/client.ovpn
sudo echo "<ca>" >> /etc/openvpn/server/client.ovpn
sudo cat /etc/openvpn/server/ca.crt >> /etc/openvpn/server/client.ovpn
sudo echo "</ca>" >> /etc/openvpn/server/client.ovpn
sudo echo "<cert>" >> /etc/openvpn/server/client.ovpn
sudo cat /etc/openvpn/server/easy-rsa/pki/issued/server.crt >> /etc/openvpn/server/client.ovpn
sudo echo "</cert>" >> /etc/openvpn/server/client.ovpn
sudo echo "<key>" >> /etc/openvpn/server/client.ovpn
sudo cat /etc/openvpn/server/easy-rsa/pki/private/server.key >> /etc/openvpn/server/client.ovpn
sudo echo "</key>" >> /etc/openvpn/server/client.ovpn

# Move the .ovpn file to the desktop
sudo cp /etc/openvpn/server/client.ovpn ~/Desktop/
This will create a client.ovpn file in the /etc/openvpn/server directory and then move it to the desktop. The client.ovpn file can be used by a client to connect to the OpenVPN server.

Note that you should replace <server_ip_address> with the actual IP address of the server. Additionally, the script will need to be run with administrative privileges to be able to create and move the file.




Austin Persaud
Make a whole new bash script that outputs a new client ovpn file to desktop 
Here is an example of a new bash script that outputs a new client ovpn file to the desktop:

bash
Copy code
#!/bin/bash

# Set variables
SERVER_IP="<server_ip_address>"
CLIENT_NAME="client1"

# Create a directory for the client configuration files
mkdir ~/openvpn-client-configs
chmod 700 ~/openvpn-client-configs

# Generate the client key and certificate
cd /usr/share/easy-rsa/
./easyrsa build-client-full $CLIENT_NAME nopass

# Create the client configuration file
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/openvpn-client-configs/$CLIENT_NAME.ovpn
sed -i "s/remote my-server-1 1194/remote $SERVER_IP 1194/g" ~/openvpn-client-configs/$CLIENT_NAME.ovpn
sed -i "s/;user nobody/user nobody/g" ~/openvpn-client-configs/$CLIENT_NAME.ovpn
sed -i "s/;group nogroup/group nogroup/g" ~/openvpn-client-configs/$CLIENT_NAME.ovpn
echo "<ca>" >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
cat /etc/openvpn/ca.crt >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
echo "</ca>" >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
echo "<cert>" >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
cat /usr/share/easy-rsa/pki/issued/$CLIENT_NAME.crt >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
echo "</cert>" >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
echo "<key>" >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
cat /usr/share/easy-rsa/pki/private/$CLIENT_NAME.key >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn
echo "</key>" >> ~/openvpn-client-configs/$CLIENT_NAME.ovpn

# Move the client configuration file to the desktop
cp ~/openvpn-client-configs/$CLIENT_NAME.ovpn ~/Desktop/

# Set permissions
chmod 600 ~/openvpn-client-configs/$CLIENT_NAME.ovpn
This script assumes that you have already set up an OpenVPN server and have EasyRSA installed. It sets two variables - SERVER_IP and CLIENT_NAME - which should be set to the IP address of the OpenVPN server and the name of the new client, respectively.

The script then creates a directory for the client configuration files and generates a key and certificate for the new client using EasyRSA. It copies the sample client configuration file and modifies it to include the necessary information, such as the IP address of the OpenVPN server and the client key and certificate.

The script then moves the new client configuration file to the desktop and sets appropriate permissions. Note that the script will need to be run with administrative privileges to be able to create and move the file.




Austin Persaud
Modify that script to work with the VPN creation script from earlier
Here's an updated version of the script that integrates the OpenVPN server creation script and the client configuration file generation script:

bash
Copy code
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
