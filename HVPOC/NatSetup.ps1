<#
 
Scenario
 
Hyper-V Host: 192.168.0.102
VMs IP-Range: 192.168.81.0 /24
 
#>

$extIpPrefix = "192.168.174.1/24"
$intIp = "192.168.81.0/24"
$intIpPrefix = $intIp.Split("/")[1]
$intIpFirst = ($intIp.Split("/")[0].Split(".")[0..2] -join ".") + ".1"

# Create a new NAT-Switch
New-VMSwitch -Name vsw-NAT -SwitchType Internal
 
# Retrieve the Interface ID of your NAT-Switch
$ifIndex = Get-NetAdapter | where {$_.Name -like "*NAT*"}| Select-Object -ExpandProperty InterfaceIndex
 
# Configure the first address of 192.168.99.0 /24 on NAT-Switch (Note the InterfaceIndex retrieved above)
New-NetIPAddress -IPAddress $intIpFirst -PrefixLength $intIpPrefix -InterfaceIndex $ifIndex
 
# Activate NAT
New-NetNat -Name MyNAT -InternalIPInterfaceAddressPrefix $intIp 
 
# Check NAT 
Get-NetNat