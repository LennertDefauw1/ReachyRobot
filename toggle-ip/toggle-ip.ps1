#
# Get physical network adapters : ethernet (802.3)
#
$eth0=Get-NetAdapter -Physical | Where-Object { $_.PhysicalMediaType -match "802.3" -and $_.status -eq "up"}
if (!$eth0)
{
    write-host("")
    write-host("No connected ethernet interface found ! Please connect cable ...")
    exit(1)
}

$eth0_ip=Get-NetIPInterface -InterfaceIndex $eth0.ifIndex -AddressFamily IPv4

if ($eth0_ip.dhcp) {
#
# DHCP enabled
#
    # Disable DHCP

    $eth0 | Set-NetIPInterface -DHCP Disabled
    
    # Ask for IP data

    write-host("")
    write-host("Configuring static IP address 192.168.168.100 ...")
    #write-host("Opvragen van details voor script")
    #write-host("--------------------------------")

    $ip = "192.168.168.100" #Read-Host("Geef het gewenste IP adres in")
    $subnet = "24"#Read-Host("Geef de prefixlengte in")
    $gateway = "192.168.168.1" #Read-Host("Geef de gateway in")
    $dns = "192.168.168.1" #read-host("Geef de eerste DNS server in")

    # Set IP data on network interface

    $eth0 | New-NetIPAddress -AddressFamily IPv4 -IPAddress $ip -PrefixLength $subnet -Type Unicast -DefaultGateway $gateway | Out-Null
    
    # Set DNS server

    $eth0 | Set-DnsClientServerAddress -ServerAddresses $dns
}
else
{
    write-host("")
    write-host("Reverting to DHCP client ...")
    # Remove all previous routes

    #Get-NetRoute -AddressFamily IPv4 -InterfaceIndex $eth0.ifIndex
    Remove-NetRoute -AddressFamily IPv4 -InterfaceIndex $eth0.ifIndex -confirm:$false -ErrorAction SilentlyContinue
    
    # Enable DHCP
    
    $eth0 | Set-NetIPInterface -AddressFamily IPv4 -DHCP Enabled
    
    # Reset DNS through DHCP
    
    $eth0 | Set-DnsClientServerAddress -ResetServerAddresses

    Disable-NetAdapter $eth0.Name -Confirm:$false
    Enable-NetAdapter $eth0.Name -Confirm:$false
}

exit(0)
