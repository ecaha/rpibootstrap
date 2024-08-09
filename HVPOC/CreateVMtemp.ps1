$vmPath = "C:\VM\bootstrapper"  
$ubuIso = "C:\_ISO\ubuntu-24.04-live-server-amd64.iso"
$oscdimg = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
$ubuVhdx = "C:\temp\ubuvhd-20240712\ubuntu-24.04-server-cloudimg-amd64.vhdx"

#vm spec
$vm = @(
    @{
        Name = "ubu01"
        Memory = 4GB
        CPU=4
        DiskSize = 32GB
        Networks = @(
            @{
                SwitchName = "Internet"
                VLANid = 100
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
    }
)



# bash -c "sudo apt update && sudo apt install -y whois"

# bash -c 'echo "Smrcek123456!" | mkpasswd --method=SHA-512 --rounds=4096 --stdin'


# Create VM, boot from ubuIso and attach the cloud-init iso, add data disks and networks
foreach ($vmSpec in $vm) {
    $vmPathloc = "$vmPath\$($vmSpec.Name)"
    New-VM -Name $vmSpec.Name -Memory $vmSpec.Memory -Path $vmPathloc -Generation 2
    Set-VMFirmware -EnableSecureBoot Off -VMName $vmSpec.Name
    foreach ($network in $vmSpec.Networks) {
        Add-VMNetworkAdapter -VMName $vmSpec.Name -SwitchName $network.SwitchName 
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
    Set-VMComPort -VMName $vmSpec.Name -Path "\\.\pipe\$($vmSpec.Name)" -Number 1

    Start-VM -Name $vmSpec.Name
}
 
 The script creates a VM with the following specs: 
 
 Name: ubu01 
 Memory: 4GB 
 CPU: 4 
 DiskSize: 32GB 
 Networks: sLAN with VLAN 100 
 DataDisks: Data01 and Data02 with 100GB each 
 
 The script creates a cloud-init user-data and meta-data file for each VM in the  cidata  directory. It then creates an ISO file for each VM using the  oscdimg  tool. 
 Finally, the script creates the VM, boots from the Ubuntu ISO, attaches the cloud-init ISO, adds the data disks and networks, and sets the CPU count


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
