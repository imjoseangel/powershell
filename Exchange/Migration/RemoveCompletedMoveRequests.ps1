# This script clears completed move requests based on the specified input file.

$A = (Get-Host).UI.RawUI
$A.BackgroundColor = "Black"
$A.ForegroundColor = "White"
$A.WindowTitle = "Clear Move Requests"

Clear Host

$Data = Get-Content $Args[0]

# Get credentials
Write-Host
Write-Host
Write-Host -Fore RED
{

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

Enter your Credentials in UPN format

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

}

$O365Cred= Get-Credential

# Connect to Office 365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $O365cred -Authentication Basic -AllowRedirection
Import-PSSession $Session

# Remove completed move requests
ForEach ($Account in $Data)
{
   Get-MoveRequest -Identity $Account | Where {$_.Status -eq "Completed"} | Remove-MoveRequest
}

Get-PSSession | Remove-PSSession
