$count = $args.Count
   if ($count -lt 1) {
       Write-Host
       Write-Host "You need to specify input file as arguments:" $MyInvocation.MyCommand.Name "Log File" -ForegroundColor Red
       Write-Host
   }
   else {
   $file = $args[0]
   Write-Host Using File: $file -ForegroundColor Yellow
   
			
	$test = Get-Content -path $args[0] -ErrorAction SilentlyContinue
		
		if ($test -ne $null) {
                Get-Content -path $args[0] -wait
           }     
           else { Write-Host File: $args[0] does not exist! -ForegroundColor Red}
		   

	}