Set-AzureRmContext -SubscriptionName 'Development & Test'

#Provide the subscription Id of the subscription where managed disk exists
$sourceSubscriptionId='1bfce26d-xxx'

#Provide the name of your resource group where managed disk exists
$sourceResourceGroupName='we-s-rsg-shared'

#Provide the name of the managed disk
$managedDiskName='we-s-vm-master_OsDisk'

#Set the context to the subscription Id where Managed Disk exists
Select-AzureRmSubscription -SubscriptionId $sourceSubscriptionId

#Get the source managed disk
$managedDisk= Get-AzureRMDisk -ResourceGroupName $sourceResourceGroupName -DiskName $managedDiskName

#Provide the subscription Id of the subscription where managed disk will be copied to
#If managed disk is copied to the same subscription then you can skip this step
$targetSubscriptionId='7ffdeabf-xxx

#Name of the resource group where snapshot will be copied to
$targetResourceGroupName='we-s-rsg-shared'

#Set the context to the subscription Id where managed disk will be copied to
#If snapshot is copied to the same subscription then you can skip this step
Select-AzureRmSubscription -SubscriptionId $targetSubscriptionId

$diskConfig = New-AzureRmDiskConfig -SourceResourceId $managedDisk.Id -Location $managedDisk.Location -CreateOption Copy 

#Create a new managed disk in the target subscription and resource group
New-AzureRmDisk -Disk $diskConfig -DiskName $managedDiskName -ResourceGroupName $targetResourceGroupName
