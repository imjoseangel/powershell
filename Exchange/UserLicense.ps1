$count = $args.Count
   if ($count -lt 1) {
       Write-Host
       Write-Host "You need to specify username as arguments:" $MyInvocation.MyCommand.Name "<username@beamglobal.com>" -ForegroundColor Red
       Write-Host
   }
   else {
   $mbx = $args[0]
   Write-Host Searching user: $mbx -ForegroundColor Yellow
   
           # Verify if mailbox exist
           $test = Get-Mailbox $mbx -ErrorAction SilentlyContinue
           if ($test -ne $null) {
                Get-MsolUser -UserPrincipalName $mbx | Select-Object UserPrincipalName, DisplayName, isLicensed, IsBlackberryUser
           }     
           else { Write-Host Mailbox: $mbx does not exist! -ForegroundColor Red}
           
}