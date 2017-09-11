# Clear Completed move requests.
# This resumes move requests from a list of users provided in an input file.

$A = (Get-Host).UI.RawUI
$A.BackgroundColor = "Black"
$A.ForegroundColor = "White"
$A.WindowTitle = "Resume move requests..."

Clear Host

$Data = Get-Content $Args[0]

# Get Credentials
Write-Host
Write-Host
Write-host -Fore Red
{

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

Enter your Credentials in UPN format

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

}

$O365Cred= Get-Credential

# Connect to Office 365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $O365Cred -Authentication Basic -AllowRedirection
Import-PsSession $Session

# Loop through move requests

ForEach ($User in $Data)
{
# Declare loop variables

Write-Host
Write-Host
Write-Host -Fore Magenta "Resuming MoveRequest for user: $User "

Resume-MoveRequest -Identity $User

}

Write-Host
Write-Host
Write-Host
Write-Host -Fore Magenta "All users in input file $Args have been processed."


# Close and remove the PSSession
Write-Host
Write-Host
Write-Host
Write-Host -No -Fore Magenta "Close and remove the PSSession..."

Remove-PSSession $Session

Write-Host -Fore Magenta ". . .complete ** "

Write-host -Fore Green
{

 All Processing complete

}

