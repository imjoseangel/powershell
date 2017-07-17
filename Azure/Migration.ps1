Login-AzureRmAccount

# Select Subscription

$SubscrName = "DVT_IT_PROD"
Select-AzureRMSubscription -SubscriptionName $SubscrName

# Global Variables

$ResourceGroupName = "rgnedvtitprodarm"
$Location = "North Europe"

# Create Resource Group

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location

# Create Storage Accounts

$StorageAccountOS = "sanedvtitprodvhdos01arm"
$StorageAccountDATA = "sanedvtitprodvhdata01arm"
$StorageAccountMGNT = "sanedvtitprodarm"

New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountOS -Type "Standard_LRS" -Location $Location
New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountDATA -Type "Standard_LRS" -Location $Location
New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountMGNT -Type "Standard_LRS" -Location $Location

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

# Copy VHDs

& "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\AzCopy.exe" /Source:https://sanedvtittestvhdos01.blob.core.windows.net/vhds /Dest:https://sanedvtittestvhdos01arm.blob.core.windows.net/vhds /SourceKey:WF+cGQtKOoxburUrjo99/TTcZbADvGY6GNVzoaRrQayk+hGd0NDry6DbaToGkGVyv3YLqAMOu9H5fgxPp0ZT6Q== /DestKey:PNLDE6GURf6YJtUzpmu2MBAeo5dmU/eGudbRF7HhRP9xzieDkdrEul5Atb/7tPQ1LMDEaMah6YRtnCBiCOnJSg== /Pattern:*.vhd

& "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\AzCopy.exe" /Source:https://sanedvtittestvhddata01.blob.core.windows.net/vhds /Dest:https://sanedvtitestvhddata01arm.blob.core.windows.net/vhds /SourceKey:chfXD1M+hYuz0tuT5SpeFRx6ph6VH+2+wvLGBK56qIVU2QfY91RY6xLH0cXWBY0ocmH9I2WG2u01WGihGqbiNw== /DestKey:h+WJEBqKwmV/kBJnmyqsg4CWmuiX82MjY40qpiwnVVpJ5SWX+aItXpSnAeciADrMuCgOaHwL0Dj3Cj3PGT+e3Q== /Pattern:vmtest01-data01.vhd

& "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\AzCopy.exe" /Source:https://sanedvtittest.blob.core.windows.net/vhds /Dest:https://sanedvtittestarm.blob.core.windows.net/vhds /SourceKey:8pbguSG4ubVuGX0eJ88q/5usuH8+MEuQD8Xa8wsjvd69mAuhNQzHEQL19ilvJ7jItDSdOp8wzyiY51E/CMVfZA=== /DestKey:1RmjaoYtJHJ6NoOl28mY1mG7M6Fs2iqApheecvEQyU88oobuMkcDsBe+26Oaa1K4ZxmNhKxq5LsRsuGRDyjjOw== /Pattern:vmtest01-data01.vhd

# Compute Variables
$VMName = "VDJBOSS01ARM"
$OSDiskUri = "https://sanedvtittestvhdos01arm.blob.core.windows.net/vhds/VDJBOSS01.vhd"
$DataDiskUri = "https://sanedvtitestvhddata01arm.blob.core.windows.net/vhds/VDORALNX01-DATA01.vhd"
$VMSize = "Standard_D2"
$OSDiskName = "$VMName" + "-OS"
$DataDiskName = "$VMName" + "-Data"
$VMResourceGroupName = $ResourceGroupName
$VMAvailabilitySetName = "None"

# Network Variables
$SubnetName = $SubnetMiddl01
$InterfaceName = $VMName + "-Primary"
$VNetName = $VNetName
$VNetResourceGroupName = $ResourceGroupName

# Remember to create a new ResourceGroupName for Network

# Network Script

$VNet   = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $VNetResourceGroupName
$Subnet = Get-AzureRMVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VNet


# Create the Interface
$Interface  = New-AzureRMNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $Subnet.Id
# Use an existing interface
# $Interface = Get-AzureRMNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName

# Compute Script
# $AvailabilitySet = Get-AzureRmAvailabilitySet -ResourceGroupName $VMResourceGroupName  -Name $VMAvailabilitySetName
# $VirtualMachine  = New-AzureRMVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet.Id
$VirtualMachine  = New-AzureRMVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine  = Add-AzureRMVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id
$VirtualMachine  = Set-AzureRMVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption Attach -Linux
$VirtualMachine  = Add-AzureRMVMDataDisk -VM $VirtualMachine -Name $DataDiskName -VhdUri $DataDiskUri -LUN 2 -Caching None -CreateOption Attach

# Create the VM in Azure
New-AzureRMVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine