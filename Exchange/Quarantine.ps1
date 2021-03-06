$count = $args.Count
   if ($count -lt 1) {
       Write-Host
       Write-Host "You need to specify username as arguments:" $MyInvocation.InvocationName "<username@beamglobal.com>" -ForegroundColor Red
       Write-Host
   }
   else {
   $mbx = $args[0]
   Write-Host Searching user: $mbx -ForegroundColor Yellow
   
           # Verify if mailbox exist
           $test = Get-Mailbox $mbx -ErrorAction SilentlyContinue
           if ($test -ne $null) {
               Get-QuarantineMessage -RecipientAddress $mbx | Select ReceivedTime, SenderAddress, Subject
           }     
           else { Write-Host Mailbox: $mbx does not exist! -ForegroundColor Red}
           
}