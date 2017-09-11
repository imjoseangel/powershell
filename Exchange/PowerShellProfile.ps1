#Import-Module MSOnline

Function O365-Connect
{
$O365Credential = Get-Credential
$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $O365Credential -Authentication Basic -AllowRedirection
Import-PSSession $O365Session
Connect-MSOLService -Credential $O365Credential
}

Function O365-Disconnect
{
Get-PSSession | Remove-PSSession
}

Function Get-Statistics
{
Get-MoveRequest | Get-MoveRequestStatistics | Select Alias, DisplayName, PercentComplete, TotalInProgressDuration, TotalMailboxSize, StatusDetail | Sort-Object 'PercentComplete' | Format-Table -Autosize
}

# Set default script location
Set-Location C:\Scripts\PowerShell