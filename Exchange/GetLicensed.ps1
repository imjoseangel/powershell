Connect-MsolService
Get-MsolUser -All | Get-Member | Out-GridView
Get-MsolUser -All | Where-Object { $_.isLicensed -eq "TRUE" }