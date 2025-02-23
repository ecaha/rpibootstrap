$vmPath = "C:\VM\bootstrapper"  
$ubuIso = "C:\_ISO\ubuntu-24.04-live-server-amd64.iso"
$oscdimg = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
$ubuVhdx = "C:\temp\ubuvhd\ubuntu-24.04-server-cloudimg-amd64.vhdx"
$scriptsPath = "C:\VM\bootstrapper\scripts"

#vm spec
$vm = @(
    @{
        Name = "uburoute"
        Memory = 2GB
        CPU=4
        DiskSize = 32GB
        Networks = @(
            @{
                SwitchName = "vsw-WAN"
                AdapterName = "WAN"
                VlanId = 0
                MacSpoofing = $false
            },
            @{
                SwitchName = "vsw-LAN"
                AdapterName = "LAN"
                VlanId = 0
                MacSpoofing = $false
            }
        )
        NetworkConfig = @"
network:
    version: 2
    ethernets:
        eth0:
            dhcp4: true
            nameservers:
                addresses: [192.168.174.1]
        eth1:
            addresses:
                - 192.168.10.1/24
"@

        UserData = @"
#cloud-config

hostname: uburoute
create_hostname_file: true

users:
  - name: erycek
    passwd: `$6`$x/Tx/ZeZDA87KyyZ`$p72RNDX6xOH0Xz02nGXxOk07CyzhJ9av7mAmIGbc0VedfnpCjuSTAV8KPTKYZzp3wgtqj6CNN7PQcOy03nhyX.
    groups: sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmktBaqfCDw8cY9lchNRhP/o69wvXhXkTVmf/s53rouyeYetVJ/0viuDSOzpkTK3m1it5svIabCFx1PiHiwQ5HgiJQaliKjDiAhDygfJGrZIfsDMeU1NBALZNVOxpcZZEXdzy9wnV62r+IYntAVballsLrK7nYighTNJUpgB6FtgiAUFI0+G7ZTvsJOrOmB17G9pEDQkJg9eeIRCbKvxwPDdshmEHvdfKtlajC5S2v5GRXC9127gvZCFyG5n+vOV1vf12ugFQEGvBzqoSIMK9sfyYSHSPJyt+bnHZqp1K0W3HqFP2FgDQbWZOPsrN4xrMUkRGtuhP2by5950gC8rdV rsa-key-20241113

runcmd:
  - sysctl -w net.ipv4.ip_forward=1
  - iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
"@

    },
    @{
        Name = "ubu01"
        Memory = 4GB
        CPU=4
        DiskSize = 32GB
        Networks = @(
            @{
                SwitchName = "vsw-LAN"
                AdapterName = "LAN01"
                VlanId = 0
                MacSpoofing = $true
            },
            @{
                SwitchName = "vsw-LAN"
                AdapterName = "LAN02"
                VlanId = 0 
                MacSpoofing = $true
            }
        )
        DataDisks = @(
            @{
                Name="Data01"
                DiskSize=100GB
            },
            @{
                Name="Data02"
                DiskSize=100GB
            }
        )
        NetworkConfig = @"
network:
    version: 2
    ethernets:
        eth0:
            dhcp4: false
        eth1:
            dhcp4: false
    bonds:
        bond0:
            interfaces: [eth0, eth1]
            addresses: 
              - 192.168.10.10/24
              - 172.16.0.10/24
            gateway4: 192.168.10.1
            nameservers:
                addresses: [8.8.8.8]
"@

        UserData = @"
#cloud-config

hostname: ubu01
create_hostname_file: true

users:
  - name: erycek
    passwd: `$6`$x/Tx/ZeZDA87KyyZ`$p72RNDX6xOH0Xz02nGXxOk07CyzhJ9av7mAmIGbc0VedfnpCjuSTAV8KPTKYZzp3wgtqj6CNN7PQcOy03nhyX.
    groups: sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmktBaqfCDw8cY9lchNRhP/o69wvXhXkTVmf/s53rouyeYetVJ/0viuDSOzpkTK3m1it5svIabCFx1PiHiwQ5HgiJQaliKjDiAhDygfJGrZIfsDMeU1NBALZNVOxpcZZEXdzy9wnV62r+IYntAVballsLrK7nYighTNJUpgB6FtgiAUFI0+G7ZTvsJOrOmB17G9pEDQkJg9eeIRCbKvxwPDdshmEHvdfKtlajC5S2v5GRXC9127gvZCFyG5n+vOV1vf12ugFQEGvBzqoSIMK9sfyYSHSPJyt+bnHZqp1K0W3HqFP2FgDQbWZOPsrN4xrMUkRGtuhP2by5950gC8rdV rsa-key-20241113

package_update: true
package_upgrade: true
package_reboot_if_required: true

bootcmd:
  - echo 192.168.10.1 uburouter >> /etc/hosts
  - echo 192.168.10.2 ace >> /etc/hosts
  - echo 192.168.10.10 ubu01 >> /etc/hosts
  - echo 192.168.10.20 ubu02 >> /etc/hosts
  - echo 192.168.10.30 ubu03 >> /etc/hosts

runcmd:
  - sysctl -w net.ipv4.ip_forward=1
            
"@

    },
    @{
        Name = "ubu02"
        Memory = 4GB
        CPU=4
        DiskSize = 32GB
        Networks = @(
            @{
                SwitchName = "vsw-LAN"
                AdapterName = "LAN01"
                VlanId = 0
                MacSpoofing = $true
            },
            @{
                SwitchName = "vsw-LAN"
                AdapterName = "LAN02"
                VlanId = 0 
                MacSpoofing = $true
            }
        )
        DataDisks = @(
            @{
                Name="Data01"
                DiskSize=100GB
            },
            @{
                Name="Data02"
                DiskSize=100GB
            }
        )
        NetworkConfig = @"
network:
    version: 2
    ethernets:
        eth0:
            dhcp4: false
        eth1:
            dhcp4: false
    bonds:
        bond0:
            interfaces: [eth0, eth1]
            addresses: 
              - 192.168.10.20/24
              - 172.16.0.20/24
            gateway4: 192.168.10.1
            nameservers:
                addresses: [8.8.8.8]
"@

        UserData = @"
#cloud-config

hostname: ubu02
create_hostname_file: true

users:
  - name: erycek
    passwd: `$6`$x/Tx/ZeZDA87KyyZ`$p72RNDX6xOH0Xz02nGXxOk07CyzhJ9av7mAmIGbc0VedfnpCjuSTAV8KPTKYZzp3wgtqj6CNN7PQcOy03nhyX.
    groups: sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmktBaqfCDw8cY9lchNRhP/o69wvXhXkTVmf/s53rouyeYetVJ/0viuDSOzpkTK3m1it5svIabCFx1PiHiwQ5HgiJQaliKjDiAhDygfJGrZIfsDMeU1NBALZNVOxpcZZEXdzy9wnV62r+IYntAVballsLrK7nYighTNJUpgB6FtgiAUFI0+G7ZTvsJOrOmB17G9pEDQkJg9eeIRCbKvxwPDdshmEHvdfKtlajC5S2v5GRXC9127gvZCFyG5n+vOV1vf12ugFQEGvBzqoSIMK9sfyYSHSPJyt+bnHZqp1K0W3HqFP2FgDQbWZOPsrN4xrMUkRGtuhP2by5950gC8rdV rsa-key-20241113

package_update: true
package_upgrade: true
package_reboot_if_required: true

bootcmd:
  - echo 192.168.10.1 uburouter >> /etc/hosts
  - echo 192.168.10.2 ace >> /etc/hosts
  - echo 192.168.10.10 ubu01 >> /etc/hosts
  - echo 192.168.10.20 ubu02 >> /etc/hosts
  - echo 192.168.10.30 ubu03 >> /etc/hosts

runcmd:
  - sysctl -w net.ipv4.ip_forward=1
            
"@
    },
    @{
        Name = "ubu03"
        Memory = 4GB
        CPU=4
        DiskSize = 32GB
        Networks = @(
            @{
                SwitchName = "vsw-LAN"
                AdapterName = "LAN01"
                VlanId = 0
                MacSpoofing = $true
            },
            @{
                SwitchName = "vsw-LAN"
                AdapterName = "LAN02"
                VlanId = 0 
                MacSpoofing = $true
            }
        )
        NetworkConfig = @"
network:
    version: 2
    ethernets:
        eth0:
            dhcp4: false
        eth1:
            dhcp4: false
    bonds:
        bond0:
            interfaces: [eth0, eth1]
            addresses: 
              - 192.168.10.30/24
              - 172.16.0.30/24
            gateway4: 192.168.10.1
            nameservers:
                addresses: [8.8.8.8]
"@

        UserData = @"
#cloud-config

hostname: ubu03
create_hostname_file: true

users:
  - name: erycek
    passwd: `$6`$x/Tx/ZeZDA87KyyZ`$p72RNDX6xOH0Xz02nGXxOk07CyzhJ9av7mAmIGbc0VedfnpCjuSTAV8KPTKYZzp3wgtqj6CNN7PQcOy03nhyX.
    groups: sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmktBaqfCDw8cY9lchNRhP/o69wvXhXkTVmf/s53rouyeYetVJ/0viuDSOzpkTK3m1it5svIabCFx1PiHiwQ5HgiJQaliKjDiAhDygfJGrZIfsDMeU1NBALZNVOxpcZZEXdzy9wnV62r+IYntAVballsLrK7nYighTNJUpgB6FtgiAUFI0+G7ZTvsJOrOmB17G9pEDQkJg9eeIRCbKvxwPDdshmEHvdfKtlajC5S2v5GRXC9127gvZCFyG5n+vOV1vf12ugFQEGvBzqoSIMK9sfyYSHSPJyt+bnHZqp1K0W3HqFP2FgDQbWZOPsrN4xrMUkRGtuhP2by5950gC8rdV rsa-key-20241113

package_update: true
package_upgrade: true
package_reboot_if_required: true

bootcmd:
  - echo 192.168.10.1 uburouter >> /etc/hosts
  - echo 192.168.10.2 ace >> /etc/hosts
  - echo 192.168.10.10 ubu01 >> /etc/hosts
  - echo 192.168.10.20 ubu02 >> /etc/hosts
  - echo 192.168.10.30 ubu03 >> /etc/hosts

runcmd:
  - sysctl -w net.ipv4.ip_forward=1
            
"@

        }
)

# cloud-init userdata
$userdata = @"
#cloud-config

hostname: #HOSTNAME#
create_hostname_file: true

users:
  - name: erycek
    passwd: `$6`$x/Tx/ZeZDA87KyyZ`$p72RNDX6xOH0Xz02nGXxOk07CyzhJ9av7mAmIGbc0VedfnpCjuSTAV8KPTKYZzp3wgtqj6CNN7PQcOy03nhyX.
    groups: sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
  - name: hacluster
    passwd: `$6`$lB6Y3tr6g6/Umzim`$bzloWfQ1H/SU3QCQj3yDF3QmwfT57hP.ZiCPLEeMdhxz80cHrTs0bjsv9JYlxhVPK3aSDaTS6RTKfA380lk93.
    shell: /bin/bash
    lock_passwd: false

"@

# bash -c "sudo apt update && sudo apt install -y whois"

# bash -c 'echo "Smrcek123456!" | mkpasswd --method=SHA-512 --rounds=4096 --stdin'

$metadata = @"
"@

# Create directory per VM .vmanmecidata
$vm | ForEach-Object {
    $userdataVM = $_.UserData
    $netConfVM = $_.NetworkConfig
    $vmPathloc = "$vmPath\$($_.Name)\cidata"
    New-Item -Path $vmPathloc -ItemType Directory -Force
   # New-Item -Path "$vmPathloc\user-data" -ItemType File -Value $userdataVM
    $userdataVM | Out-File -FilePath "$vmPathloc\user-data" -Encoding ascii
   # New-Item -Path "$vmPathloc\meta-data" -ItemType File -Value $metadata 
    $metadata | Out-File -FilePath "$vmPathloc\meta-data" -Encoding ascii
    $netConfVM | Out-File -FilePath "$vmPathloc\network-config" -Encoding ascii
    # Copy sripts from the scripts directory to the VM directory
    Copy-Item -Path $scriptsPath -Destination $vmPathloc -Recurse -Force
}

#create ISO for each VM
$vm | ForEach-Object {
    $vmPathloc = "$vmPath\$($_.Name)\cidata"
    $isoPath = "$vmPath\$($_.Name)\$($_.Name).iso"
    & $oscdimg -lcidata -n "$vmPathloc" "$isoPath"
}


# Create VM, boot from ubuIso and attach the cloud-init iso, add data disks and networks
foreach ($vmSpec in $vm) {
    $vmPathloc = "$vmPath\$($vmSpec.Name)"
    New-VM -Name $vmSpec.Name -Memory $vmSpec.Memory -Path $vmPathloc -Generation 2 
    Set-VMFirmware -EnableSecureBoot Off -VMName $vmSpec.Name
    Remove-VmNetworkAdapter -VMName $vmSpec.Name -Name "Network Adapter"
    foreach ($network in $vmSpec.Networks) {
        Add-VMNetworkAdapter -VMName $vmSpec.Name -SwitchName $network.SwitchName -Name $network.AdapterName
        if ($network.MacSpoofing) {
            Set-VMNetworkAdapter -VMName $vmSpec.Name -MacAddressSpoofing On -Name $network.AdapterName
        }
        if ($network.VlanId -ne 0) {
            Set-VMNetworkAdapterVlan -VMName $vmSpec.Name -VlanId $network.VlanId -Access -Name $network.AdapterName
        }
        #Set-VMNetworkAdapterVlan -VMName $vmSpec.Name -VlanId $network.VLANid
    }
    Set-VM -VMName $vmSpec.Name -ProcessorCount $vmSpec.CPU
    New-Item -Path "$vmPathloc\Virtual Hard Disks" -ItemType Directory -Force
    Copy-Item -Path $ubuVhdx -Destination "$vmPathloc\Virtual Hard Disks\$($vmSpec.Name).vhdx" -Force
    Add-VMHardDiskDrive -VMName $vmSpec.Name -Path "$vmPathloc\Virtual Hard Disks\$($vmSpec.Name).vhdx"
    Set-VMFirmware -FirstBootDevice $(Get-VMHardDiskDrive -VMName $vmSpec.Name) -VMName $vmSpec.Name
    foreach ($dataDisk in $vmSpec.DataDisks) {
        New-VHD -Path "$vmPathloc\Virtual Hard Disks\$($dataDisk.Name).vhdx" -Size $dataDisk.DiskSize -Dynamic -BlockSizeBytes 1MB
        Add-VMHardDiskDrive -VMName $vmSpec.Name -Path "$vmPathloc\Virtual Hard Disks\$($dataDisk.Name).vhdx"
    }
    Add-VMDvdDrive -VMName $vmSpec.Name -Path "$vmPathloc\$($vmSpec.Name).iso"
    Set-VMComPort -VMName $vmSpec.Name -Path "\\.\pipe\$($vmSpec.Name)" -Number 1

    Start-VM -Name $vmSpec.Name
}
 
#  The script creates a VM with the following specs: 
 
#  Name: ubu01 
#  Memory: 4GB 
#  CPU: 4 
#  DiskSize: 32GB 
#  Networks: sLAN with VLAN 100 
#  DataDisks: Data01 and Data02 with 100GB each 
 
#  The script creates a cloud-init user-data and meta-data file for each VM in the  cidata  directory. It then creates an ISO file for each VM using the  oscdimg  tool. 
#  Finally, the script creates the VM, boots from the Ubuntu ISO, attaches the cloud-init ISO, adds the data disks and networks, and sets the CPU count


#cehck if vm exists, shutdown and remove, remove files
$vm | ForEach-Object {
    $vmPathloc = "$vmPath\$($_.Name)"
    $vmName = $_.Name
    if (Get-VM -Name $vmName -ErrorAction SilentlyContinue) {
        Stop-VM -Name $vmName -Force
        Remove-VM -Name $vmName -Force
    }
    Remove-Item -Path $vmPathloc -Recurse -Force
}
