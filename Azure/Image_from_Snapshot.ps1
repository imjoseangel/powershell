$rgName = "we-a-rsg-shared"
$location = "westeurope"
$snapshotName = "we-s-master-OSDisk"
$imageName = "windows2012r2-basic-1519335187"

$snapshot = Get-AzureRmSnapshot -ResourceGroupName $rgName -SnapshotName $snapshotName

$imageConfig = New-AzureRmImageConfig -Location $location
$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsState Generalized -OsType Windows -SnapshotId $snapshot.Id

New-AzureRmImage -ImageName $imageName -ResourceGroupName $rgName -Image $imageConfig
