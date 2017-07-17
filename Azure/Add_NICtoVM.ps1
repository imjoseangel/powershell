$VMname='vfvm100pa01'
$VMRG='rgnedvtitfwarm'
$NICName='vfvm100pa01-eth5'
$NICResourceGroup='rgnedvtitfwarm'

#Get the VM
$VM = Get-AzureRmVM -Name $VMname -ResourceGroupName $VMRG

#Add the NIC
$NewNIC =  Get-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $NICResourceGroup
$VM = Add-AzureRmVMNetworkInterface -VM $VM -Id $NewNIC.Id

# Show the Network interfaces
$VM.NetworkProfile.NetworkInterfaces

#Update the VM configuration (The VM will be restarted)
Update-AzureRmVM -VM $VM -ResourceGroupName $VMRG
