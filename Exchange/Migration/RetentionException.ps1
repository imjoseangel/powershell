#Import CSV file (specified in command line)
#The CSV file should have one column containing users' UPN
#This script must be run from Normal Powershell session (as administrator)

$data = Get-Content $args[0]


$a = (Get-Host).UI.RawUI
$a.BackgroundColor = "Black"
$a.ForegroundColor = "White"
$a.WindowTitle = "Applies the Retention Policy Exception to Mailboxes"

Clear-Host


#Setup LogFile file name
$LogFile = ".\$((Get-Date -uformat %Y-%m-%d_%H.%M.%S).ToString())_Indefinite_RetentionLogFile.txt"
Write-Host -Fore MAGENTA The log file for this session is: $LogFile

Write-Host
Write-Host
Write-Host
Write-Host
Write-host -fore RED {

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

Enter your Credentials in UPN format

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

}

$O365Cred= Get-Credential

Write-Host
Write-Host
Write-Host
Write-Host
Write-host -fore GREEN {

# Connect to Office 365
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $O365cred -Authentication Basic -AllowRedirection
Import-PsSession $session

Write-host
Write-host
write-host


foreach ($user in $data)
{
# declare loop variables

Write-Host
Write-Host
Write-Host -fore magenta "Creating new move request for user: $user "

Get-Mailbox -Identity $user -ResultSize unlimited | Set-Mailbox -RetentionPolicy "Indefinite Retention" >> $logfile

}

Write-Host
Write-Host
Write-Host
Write-Host -fore magenta " All users in input file $args have been processed."

Write-Host
Write-Host
Write-Host
Write-host -fore magenta "Cleaning up... Removing PS-Session"

Remove-PSSession $session



Write-host -fore green {



 All Processing complete.

}


