sudo apt update -y
sudo apt upgrade -y
sudo apt-get install -y tftpd-hpa isc-dhcp-server

# Setup tftp server on tftpd-hpa
sudo mkdir -p /var/lib/tftpboot
sudo curl https://boot.netboot.xyz/ipxe/netboot.xyz.efi -o /var/lib/tftpboot/netboot.xyz.efi
sudo curl https://boot.netboot.xyz/ipxe/netboot.xyz.kpxe -o /var/lib/tftpboot/netboot.xyz.kpxe

# Configure tftpd-hpa
echo 'TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/var/lib/tftpboot"
TFTP_ADDRESS="192.168.20.1:69"
TFTP_OPTIONS="--secure"' | sudo tee /etc/default/tftpd-hpa

# Restart tftpd-hpa service to apply changes
sudo systemctl restart tftpd-hpa

# # Configure isc-dhcp-server
echo '
    subnet 192.168.20.0 netmask 255.255.255.0
    {
        allow booting;
        allow bootp;
        range 192.168.20.220 192.168.20.250;
        option routers 192.168.20.1;
        option domain-name-servers 8.8.8.8;
        option subnet-mask 255.255.255.0;
        option dhcp-client-identifier "PXEClient"; #option 60
        option tftp-server-name "192.168.20.1"; #option 66
        option bootfile-name "netboot.xyz.efi"; #option 67
        filename "netboot.xyz.efi";
        next-server 192.168.20.1;
        default-lease-time 600;
        max-lease-time 7200;
    }' | sudo tee /etc/dhcp/dhcpd.conf

# # Restart isc-dhcp-server service to apply changes
sudo systemctl restart isc-dhcp-server

# # Enable isc-dhcp-server service to start on boot
sudo systemctl enable isc-dhcp-server
sudo systemctl enable tftpd-hpa
