$Filename = (Get-Date -Format "MMyyyy") + "_Approvals.csv"

$wsus = Get-WsusServer -Name $Env:COMPUTERNAME -PortNumber 8530
$KBs = Import-Csv E:\Approvals\$Filename | Select-Object -ExpandProperty KB

$Group = $wsus.GetComputerTargetGroups() | Where-Object {$_.Name -eq 'All computers'}

For ($Row=0; $Row -lt $KBs.Count; $Row++){
   # Set Variables

   $KB = $KBs[$Row]
    
   #Instrument the Default Web Site remotely. Restart IIS
   try {
       $Update = $wsus.SearchUpdates($KB)
       $update[0].ApproveForOptionalInstall($Group)     
   }
   catch {
       $ErrorMessage = $_.Exception.Message
       $FailedItem = $_.Exception.ItemName
       Write-Warning "We failed to Update Configuration for Server $Computer. The error message was $ErrorMessage"
   }
}