Login-AzureRmAccount

# Select Subscription

$SubscrName = "DVT_IT_PROD"
Select-AzureRMSubscription -SubscriptionName $SubscrName

# Global Variables

$ResourceGroupName = "rgnedvtitprodarm"
$Location = "North Europe"

# Create Network

$VNetName = "vndvtitprodnearm"

New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix "10.30.16.0/21"

# Create subnets

$SubnetFront01 = "sndvtitprodnefront01"
$SubnetFront02 = "sndvtitprodnefront02"
$SubnetMiddl01 = "sndvtitprodnemidd01"
$SubnetMiddl02 = "sndvtitprodnemidd02"
$SubnetBackE01 = "sndvtitprodneback01"
$SubnetBackE02 = "sndvtitprodneback02"
$SubnetGateW = "GatewaySubnet"

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName

Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetFront01 -VirtualNetwork $vnet -AddressPrefix 10.30.16.0/26
Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetFront02 -VirtualNetwork $vnet -AddressPrefix 10.30.16.64/26
Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetMiddl01 -VirtualNetwork $vnet -AddressPrefix 10.30.17.0/25
Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetMiddl02 -VirtualNetwork $vnet -AddressPrefix 10.30.17.128/25
Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetBackE01 -VirtualNetwork $vnet -AddressPrefix 10.30.18.0/25
Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetBackE02 -VirtualNetwork $vnet -AddressPrefix 10.30.18.128/25
Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetGateW -VirtualNetwork $vnet -AddressPrefix 10.30.16.192/29

# Create DNS

$vnet.DhcpOptions.DnsServers += "10.30.18.11"
$vnet.DhcpOptions.DnsServers += "10.30.18.12"
$vnet.DhcpOptions.DnsServers += "10.30.2.11"
$vnet.DhcpOptions.DnsServers += "10.30.2.12"
$vnet.DhcpOptions.DnsServers += "10.30.2.13"
$vnet.DhcpOptions.DnsServers += "10.30.2.14"


Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

# Add Local Network Gateway

$NetworkGWName = "lndvtitprodemeaarm"

New-AzureRmLocalNetworkGateway -Name $NetworkGWName -ResourceGroupName $ResourceGroupName -Location $Location -GatewayIpAddress '62.23.184.10' -AddressPrefix @('141.143.128.54/32','143.47.16.4/32','143.47.18.12/32','10.211.0.0/16','172.16.0.0/16','172.18.10.0/24','141.143.80.6/32','141.143.80.3/32','10.30.0.0/20','10.30.24.0/23','10.30.26.0/23','172.27.56.0/21','141.143.128.51/32','143.47.16.3/32','141.143.132.15/32','143.47.18.13/32','10.16.86.0/24','80.94.191.0/24','194.5.133.0/24','10.223.0.0/28','141.143.128.52/32','141.143.80.5/32','141.143.80.4/32','141.143.132.14/32','141.143.132.13/32','141.143.132.12/32','141.143.128.53/32','172.28.0.0/16','80.94.190.0/25','172.17.64.0/20','172.23.8.0/21','10.24.16.0/20','172.20.0.0/20','172.20.16.0/20')

# IP Address for the VPN Gateway

$PublicIPName = "vndvtitprodneiparm"

$gwpip = New-AzureRmPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic

# Create the GW IP Address Configuration

$PublicGWName = "vndvtitprodneipgwarm"

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet
$gwipconfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name vndvtittestnegwarm -SubnetId $subnet.Id -PublicIpAddressId $gwpip.Id


# Create the VNET Gateway

$VNGWName = "vndvtitprodnegwarm"

New-AzureRmVirtualNetworkGateway -Name $VNGWName -ResourceGroupName $ResourceGroupName -Location $Location -IpConfigurations $gwipconfig -GatewayType Vpn -VpnType PolicyBased -GatewaySku Basic

# Configure VPN Device with this IP

Get-AzureRmPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName

# Create VPN Connection

$gateway = Get-AzureRmVirtualNetworkGateway -Name $VNGWName -ResourceGroupName $ResourceGroupName
$local = Get-AzureRmLocalNetworkGateway -Name $NetworkGWName -ResourceGroupName $ResourceGroupName

$VPNName = "vndvtitprodnearm"

New-AzureRmVirtualNetworkGatewayConnection -Name $VPNName -ResourceGroupName $ResourceGroupName -Location $Location -VirtualNetworkGateway1 $gateway -LocalNetworkGateway2 $local -ConnectionType IPsec -RoutingWeight 10 -SharedKey '6RNf2g7OdxgglzmWDclQmqeDJBgWNZGH'

# Test Connection

Get-AzureRmVirtualNetworkGatewayConnection -Name $VPNName -ResourceGroupName $ResourceGroupName