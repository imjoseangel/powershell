<#
    .SYNOPSIS
    Script to create Azure VMs
    .DESCRIPTION
    This script provides a way to create Azure VMs automatically
    .INPUTS
    ComputerName
    Subscription Name
    .EXAMPLE
    New-AzureVM.ps1 -ComputerName <Computer Name> -SubscrName <Subscription>
    You can create servers as follows:
    $ComputerName = Get-Content "$pwd\computers.txt"; Foreach ($Computer in $ComputerName) {.\New-AzureVM.ps1 -ComputerName $Computer -SubscrName "Subscription" }
    .LINK
    
#>


# Define Parameters
param 
( 
        [Parameter(Mandatory=$True,Position=1)]
        [string]$ComputerName,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$SubscrName
)



# Select Subscription

Select-AzureRMSubscription -SubscriptionName $SubscrName

$ResourceGroupName = "we-s-rsg-development"
$VNetResourceGroupName = "we-s-rsg-network"
$Location = "West Europe"

# Snapshot
$snapshotName = "we-s-master-OSDisk"
$snapshotRN = "we-s-rsg-shared"
$storageType = "PremiumLRS"
$snapshot = Get-AzureRmSnapshot -ResourceGroupName $snapshotRN -SnapshotName $snapshotName
$diskConfig = New-AzureRmDiskConfig -AccountType $storageType -Location $Location -CreateOption Copy -SourceResourceId $snapshot.Id

# Network

$VNetName = "we-s-vnet-devtest"

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $VNetResourceGroupName -Name $VNetName

# Compute Variables
$VMName = $ComputerName

$VMSize = "Standard_DS1_v2"
$OSDiskName = "$VMName" + "_OsDisk"
# $VMResourceGroupName = $ResourceGroupName
# $VMAvailabilitySetName = "we-s-avset-dc"

# Network Variables
$SubnetName = "we-s-vnet-dttemp"
$InterfaceName = $VMName + "-nic1"

# More Network Script

Write-Output " "
Write-Output "Creating Disk for $ComputerName"
Write-Output " "

$OSDisk = New-AzureRmDisk -Disk $diskConfig -DiskName $OSDiskName -ResourceGroupName $resourceGroupName

$VNet   = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $VNetResourceGroupName
$Subnet = Get-AzureRMVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VNet

Write-Output " "
Write-Output "Creating NIC for $ComputerName"
Write-Output " "

# Create the Interface
$Interface  = New-AzureRMNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $Subnet.Id
# Use an existing interface
# $Interface = Get-AzureRMNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName

# Compute Script
# $AvailabilitySet = Get-AzureRmAvailabilitySet -ResourceGroupName $VMResourceGroupName -Name $VMAvailabilitySetName
# $VirtualMachine  = New-AzureRMVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet.Id
$VirtualMachine  = New-AzureRMVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine  = Add-AzureRMVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id
$VirtualMachine  = Set-AzureRMVMOSDisk -VM $VirtualMachine -ManagedDiskId $OSDisk.Id -StorageAccountType $storageType -DiskSizeInGB 128 -CreateOption Attach -Windows
# $VirtualMachine  = Add-AzureRMVMDataDisk -VM $VirtualMachine -Name $DataDiskName -VhdUri $DataDiskUri -LUN 2 -Caching None -CreateOption Attach

Write-Output " "
Write-Output "Creating VM $ComputerName"
Write-Output " "

# Create the VM in Azure
New-AzureRMVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine -LicenseType "Windows_Server"