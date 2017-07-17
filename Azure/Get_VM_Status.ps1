$RGs = Get-AzureRMResourceGroup
foreach($RG in $RGs)
{
    $VMs = Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName
    foreach($VM in $VMs)
    {
        $VMDetail = Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName -Name $VM.Name -Status
        foreach ($VMStatus in $VMDetail.Statuses)
        { 
            if($VMStatus.Code.CompareTo("PowerState/deallocated") -eq 0)
            {
                $VMStatusDetail = $VMStatus.DisplayStatus
            }
        }
        write-output $VM.Name $VMStatusDetail
    }
}