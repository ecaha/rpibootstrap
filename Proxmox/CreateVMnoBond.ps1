$vmPath = "C:\VM\pve"  
$ubuIso = "C:\_ISO\ubuntu-24.04-live-server-amd64.iso"
$oscdimg = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
$ubuVhdx = "C:\temp\ubuvhd\ubuntu-24.04-server-cloudimg-amd64.vhdx"
$scriptsPath = "C:\VM\pve\scripts"

#vm spec
$vm = @(
    @{
        Name = "pveuburoute"
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
                SwitchName = "vsw-TOR1"
                AdapterName = "LAN1"
                VlanId = 0
                MacSpoofing = $true
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
            dhcp4: false
            addresses:
               - 192.168.20.1/24
        eth2:
            dhcp4: false
"@

        UserData = @"
#cloud-config

hostname: pveuburoute
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
        Name = "pveqdevice"
        Memory = 2GB
        CPU=2
        DiskSize = 32GB
        Networks = @(
            @{
                SwitchName = "vsw-TOR1"
                AdapterName = "LAN1"
                VlanId = 0
                MacSpoofing = $true
            },
            @{
                SwitchName = "vsw-TOR2"
                AdapterName = "LAN2"
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
                - 192.168.20.10/24
            parameters:
                mode: balance-rr
            gateway4: 192.169.20.1
            nameservers:
                addresses: [192.168.174.1]
"@

        UserData = @"
#cloud-config

hostname: pveqdevice
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
  - sudo apt udate -y
  - sudo apt upgrade -y
  - sudo apt-get install -y corosync-qnetd

"@

    }
)

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

# Create VM in the loop (0-3), boot form network, two network interfaces connected to vsw-TOR1 and vsw-TOR2, system disk capcaity 128gb and data disk capacity 100GB
for ($i = 0; $i -lt 2; $i++) {
    $vmName = "pve$i"
    $vmPathloc = "$vmPath\$vmName"
    New-VM -Name $vmName -Memory 4GB -Path $vmPathloc -Generation 2
    Set-VMFirmware -EnableSecureBoot Off -VMName $vmName
    Remove-VmNetworkAdapter -VMName $vmName -Name "Network Adapter"
    Add-VMNetworkAdapter -VMName $vmName -SwitchName "vsw-TOR1" -Name "LAN1"
    Set-VMNetworkAdapter -VMName $vmName -MacAddressSpoofing On -Name "LAN1"
    Add-VMNetworkAdapter -VMName $vmName -SwitchName "vsw-TOR2" -Name "LAN2"
    Set-VMNetworkAdapter -VMName $vmName -MacAddressSpoofing On -Name "LAN2"
    Set-VM -VMName $vmName -ProcessorCount 4
    New-Item -Path "$vmPathloc\Virtual Hard Disks" -ItemType Directory -Force
    New-VHD -Path "$vmPathloc\Virtual Hard Disks\$vmName.vhdx" -Size 128GB -Dynamic -BlockSizeBytes 1MB
    Add-VMHardDiskDrive -VMName $vmName -Path "$vmPathloc\Virtual Hard Disks\$vmName.vhdx"
    New-VHD -Path "$vmPathloc\Virtual Hard Disks\$vmName-data.vhdx" -Size 100GB -Dynamic -BlockSizeBytes 1MB
    Add-VMHardDiskDrive -VMName $vmName -Path "$vmPathloc\Virtual Hard Disks\$vmName-data.vhdx"
    Set-VMFirmware -FirstBootDevice $(Get-VMNetworkAdapter -VMName $vmName) -VMName $vmName
    Set-VMComPort -VMName $vmName -Path "\\.\pipe\$vmName" -Number 1
    Set-VMProcessor -VMName $vmName -ExposeVirtualizationExtensions $true

    Start-VM -Name $vmName
}

$vms = Get-VM | where {$_.Name -like "pve*"} 
$vms | Stop-VM -Force
$vms | Remove-VM -Force
Remove-Item -Path $vmPath -Recurse -Force




# - iptables -t nat -A PREROUTING -p tcp --dport 30206 -j DNAT --to-destination 192.168.20.20:8006
# - iptables -t nat -A PREROUTING -p tcp --dport 30306 -j DNAT --to-destination 192.168.20.30:8006
# - for i in {2..219}; do iptables -t nat -A PREROUTING -p tcp --dport 22$(printf "%03d" $i) -j DNAT --to-destination 192.168.20.$i:22; done