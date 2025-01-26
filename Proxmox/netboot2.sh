sudo apt update -y
sudo apt upgrade -y

sudo systemctl disable --now systemd-resolved

sudo rm -rf /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

sudo apt-get install dnsmasq dnsutils ldnsutils -y

sudo mkdir -p /var/lib/tftpboot
sudo curl https://boot.netboot.xyz/ipxe/netboot.xyz.efi -o /var/lib/tftpboot/netboot.xyz.efi
sudo curl https://boot.netboot.xyz/ipxe/netboot.xyz.kpxe -o /var/lib/tftpboot/netboot.xyz.kpxe

echo '
port=53
domain-needed
bogus-priv
listen-address=127.0.0.1,192.168.20.1
expand-hosts
domain=dns-example.com
server=8.8.8.8
cache-size=1000 
interface=bond0
dhcp-range=192.168.20.220,192.168.20.250,255.255.255.0,4h
dhcp-option=3,192.168.20.1
dhcp-option=6,192.168.20.1
dhcp-option=66,192.168.20.1
dhcp-match=set:bios,option:client-arch,0
dhcp-match=set:uefi,option:client-arch,7
dhcp-boot=tag:bios,netboot.xyz.kpxe
dhcp-boot=tag:uefi,netboot.xyz.efi
enable-tftp
tftp-root=/var/lib/tftpboot
tftp-no-blocksize
log-queries
log-facility=/var/log/dnsmasq.log
' | sudo tee /etc/dnsmasq.conf

sudo systemctl restart dnsmasq
sudo systemctl enable dnsmasq

echo "nameserver 192.168.20.1" | sudo tee /etc/resolv.conf

