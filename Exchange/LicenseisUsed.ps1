$count = $args.Count
   if ($count -lt 1) {
       Write-Host
       Write-Host "You need to specify input csv file as arguments:" $MyInvocation.MyCommand.Name "LastLogonDate.csv" -ForegroundColor Red
       Write-Host
   }
   else {
   $file = $args[0]
   Write-Host Using File: $file -ForegroundColor Yellow
   
		Import-Csv $args[0] | Where-Object {$_.LastLogonDate -eq "Never Logged In"} | Foreach-Object{
		$test = Get-Mailbox $_.UserPrincipalName -ErrorAction SilentlyContinue
		
		if ($test -ne $null) {
                Get-MsolUser -UserPrincipalName $_.UserPrincipalName | Where-Object { $_.isLicensed -eq "TRUE" }
           }     
           else { Write-Host Mailbox: $_.UserPrincipalName does not exist! -ForegroundColor Red}
		   
		
		}
	}