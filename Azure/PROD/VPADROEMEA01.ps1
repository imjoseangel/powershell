# Login to Azure RM

Login-AzureRmAccount

# Select Subscription

$SubscrName = "DVT_IT_PROD"
Select-AzureRMSubscription -SubscriptionName $SubscrName


# Global Variables

$ResourceGroupName = "rgnedvtitprodarm"
$Location = "North Europe"

# Select Storage Account

$StorageAccountOS = "sanedvtitprodvhdos01arm"
$StorageAccountDATA = "sanedvtitprodvhdata01arm"
$StorageAccountMGNT = "sanedvtitprodarm"

# Select Network

$SubnetFront01 = "sndvtitprodnefront01"
$SubnetFront02 = "sndvtitprodnefront02"
$SubnetMiddl01 = "sndvtitprodnemidd01"
$SubnetMiddl02 = "sndvtitprodnemidd02"
$SubnetBackE01 = "sndvtitprodneback01"
$SubnetBackE02 = "sndvtitprodneback02"
$SubnetGateW = "GatewaySubnet"

$VNetName = "vndvtitprodnearm"
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName


# VM Variables

$VMName = "VPADROEMEA01ARM"
$OSDiskUri = "https://sanedvtitprodvhdos01arm.blob.core.windows.net/vhds/VPADROEMEA01.vhd"
$DataDiskUri = "https://sanedvtitprodvhdata01arm.blob.core.windows.net/vhds/VPADROEMEA01-DATA01.vhd"
# $Data2DiskUri = "https://sanedvtitprodvhdata01arm.blob.core.windows.net/vhds/VTINTER01-DATA02.vhd"
$VMSize = "Standard_D1"
$OSDiskName = "$VMName" + "-OS"
$DataDiskName = "$VMName" + "-Data"
# $Data2DiskName = "$VMName" + "-Data2"
$VMResourceGroupName = $ResourceGroupName
$VMAvailabilitySetName = "ASPADROEMEA"

# Get Availability Set

$VMAvailabilitySet = Get-AzureRmAvailabilitySet -ResourceGroupName $VMResourceGroupName -Name $VMAvailabilitySetName

# Network Variables

$IPAddress = "10.30.16.21"
$SubnetName = $SubnetFront01
$InterfaceName = $VMName + "-Primary"
$VNetName = $VNetName
$VNetResourceGroupName = $ResourceGroupName
$VNet   = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $VNetResourceGroupName
$Subnet = Get-AzureRMVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VNet

# Create the Interface
$IPconfig = New-AzureRmNetworkInterfaceIpConfig -Name "ipconfig1" -PrivateIpAddressVersion IPv4 -PrivateIpAddress $IPAddress -SubnetId $Subnet.Id
$Interface = New-AzureRmNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -IpConfiguration $IPconfig

# Old Way
# $Interface  = New-AzureRMNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $Subnet.Id

# Use an existing interface
# $Interface = Get-AzureRMNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName

# Create VM
$VirtualMachine  = New-AzureRMVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetId $VMAvailabilitySet.Id
$VirtualMachine  = Add-AzureRMVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id
$VirtualMachine  = Set-AzureRMVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption Attach -Windows
$VirtualMachine  = Add-AzureRMVMDataDisk -VM $VirtualMachine -Name $DataDiskName -VhdUri $DataDiskUri -LUN 2 -Caching None -CreateOption Attach
# $VirtualMachine  = Add-AzureRMVMDataDisk -VM $VirtualMachine -Name $Data2DiskName -VhdUri $Data2DiskUri -LUN 3 -Caching None -CreateOption Attach


New-AzureRMVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine