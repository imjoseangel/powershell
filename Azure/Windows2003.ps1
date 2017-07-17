# Login to Azure RM

Login-AzureRmAccount

# Select Subscription

$SubscrName = "DVT_IT_DEV"
Select-AzureRMSubscription -SubscriptionName $SubscrName


# Global Variables

$ResourceGroupName = "rgnedvtitdevarm"
$Location = "North Europe"

# Select Storage Account

$StorageAccountOS = "sanedvtitdevvhdos01arm"
# $StorageAccountDATA = "sanedvtitdevvhdata01arm"
# $StorageAccountMGNT = "sanedvtitdevarm"

# Select Network

$SubnetFront01 = "sndvtitdevnefront01"
$SubnetMiddl01 = "sndvtitdevnemidd01"
$SubnetBack01 = "sndvtitdevneback01"
$SubnetGateW = "GatewaySubnet"

$VNetName = "vndvtitdevnearm"
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName


# VM Variables

$VMName = "WINDOWS2003ARM"
$OSDiskUri = "https://sanedvtitdevvhdos01arm.blob.core.windows.net/vhds/Windows_2003.vhd"
# $DataDiskUri = "https://sanedvtitdevvhdata01arm.blob.core.windows.net/vhds/VPADEMEA01-DATA01.vhd"
# $Data2DiskUri = "https://sanedvtitdevvhdata01arm.blob.core.windows.net/vhds/VTINTER01-DATA02.vhd"
$VMSize = "Standard_D1"
$OSDiskName = "$VMName" + "-OS"
# $DataDiskName = "$VMName" + "-Data"
# $Data2DiskName = "$VMName" + "-Data2"
$VMResourceGroupName = $ResourceGroupName
$VMAvailabilitySetName = "None"


# Network Variables

$IPAddress = "10.30.26.14"
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
$VirtualMachine  = New-AzureRMVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine  = Add-AzureRMVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id
$VirtualMachine  = Set-AzureRMVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption Attach -Windows
# $VirtualMachine  = Add-AzureRMVMDataDisk -VM $VirtualMachine -Name $DataDiskName -VhdUri $DataDiskUri -LUN 2 -Caching None -CreateOption Attach
# $VirtualMachine  = Add-AzureRMVMDataDisk -VM $VirtualMachine -Name $Data2DiskName -VhdUri $Data2DiskUri -LUN 3 -Caching None -CreateOption Attach


New-AzureRMVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine