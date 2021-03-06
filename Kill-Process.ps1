if ($args.Length -lt 1) {
    write-host ""
    write-host "Usage:" $MyInvocation.InvocationName "<Process Name>"
    write-host ""
    return
}

$process = $args[0]

 $test = Get-Process | Where {$_.Name -eq "$process"}
 if ($test -ne $null) {
 
    Get-Process | Where {$_.Name -eq "$process"} | Select Id |  Stop-Process -Force
    Write-Host Process: $process stopped -ForegroundColor Yellow
    
    }
    
    else { Write-Host Process: $process does not exist! -ForegroundColor Red }