$VMName = "VTORALNX01ARM"
$OSDiskUri = "https://sanedvtittestvhdos01arm.blob.core.windows.net/vhds/VTORALNX01.vhd"
$DataDiskUri = "https://sanedvtitestvhddata01arm.blob.core.windows.net/vhds/VTORALNX01-DATA01.vhd"
$VMSize = "Standard_D1"
$SubnetName = $SubnetMiddl
$IPAddress = "10.30.24.133"
$VirtualMachine  = Set-AzureRMVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption Attach -Windows