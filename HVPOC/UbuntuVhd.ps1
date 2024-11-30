# get date in ISO format
$date = Get-Date -Format "yyyyMMdd"
$tempfolder = "C:\temp\ubuvhd"#"C:\temp\ubuvhd-$date"
$ubuVersion = "24.04"

# Recreate temp folder
Remove-Item -Path $tempfolder -Recurse -Force -ErrorAction SilentlyContinue
New-Item -Path $tempfolder -ItemType Directory -Force

# Download Ubuntu 20.04.1 LTS img
$ubuVerName = "ubuntu-$ubuVersion-server-cloudimg-amd64"    
$ubuDestImg = "$tempfolder\$ubuVerName.img"
$ubuSrcImg = "https://cloud-images.ubuntu.com/releases/$ubuVersion/release/$ubuVerName.img"
Invoke-WebRequest -Uri $ubuSrcImg -OutFile $ubuDestImg

Set-Location $tempfolder
#run only once
#bash -c "sudo apt update && sudo apt install -y qemu-utils"
#bash -c "sudo apt update && sudo apt install -y whois"
#bash -c "sudo apt update && sudo apt install -y fdisk"

# Convert to VHD
$command = """qemu-img convert -p -f qcow2 -O vhdx $ubuVerName.img $ubuVerName.vhdx"""
bash -c $command

#Resize VHD to 32GB
Resize-VHD -Path "$ubuVerName.vhdx" -SizeBytes 32GB

# wsl mount vhd
wsl --mount --vhd "$tempfolder\$ubuVerName.vhdx"

# mount VHD
Mount-VHD .\ubuntu-22.04-server-cloudimg-amd64.vhdx

#mount to wsl
https://learn.microsoft.com/en-us/windows/wsl/wsl2-mount-disk
#resisze
https://forum.cloudron.io/topic/6086/ubuntu-20-04-how-to-extend-partition-for-noobs