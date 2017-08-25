<#
    .SYNOPSIS
    Script to create Azure Data Disks
    .DESCRIPTION
    This script provides a way to create Azure Data Disks automatically
    .INPUTS
    ComputerName
    .EXAMPLE
    New-AzureDisk.ps1 -ComputerName <Computer Name> -SubscrName <Subscription>
    You can create servers as follows:
    $ComputerName = Get-Content "$pwd\computers.txt"; Foreach ($Computer in $ComputerName) {.\New-AzureDisk.ps1 -ComputerName $Computer -SubscrName "Subscription" }
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

Select-AzureRMSubscription -SubscriptionName $SubscrName

$ResourceGroupName = "we-s-rsg-development"
# Compute Variables
$VMName = $ComputerName

$Location = "West Europe"
$storageType = 'StandardLRS'
$dataDiskName = "$VMName" + "_Data1"

$diskConfig = New-AzureRmDiskConfig -AccountType $storageType -Location $Location -CreateOption Empty -DiskSizeGB 128
$dataDisk1 = New-AzureRmDisk -DiskName $dataDiskName -Disk $diskConfig -ResourceGroupName $ResourceGroupName

$vm = Get-AzureRmVM -Name $VMName -ResourceGroupName $ResourceGroupName 

$vm = Add-AzureRmVMDataDisk -VM $vm -Name $dataDiskName -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 1

Write-Output "Updating VM $vm"

Update-AzureRmVM -VM $vm -ResourceGroupName $ResourceGroupName