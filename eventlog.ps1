<#
    .SYNOPSIS
    Script to check Event ID Number
    .DESCRIPTION
    This script provides a way to check Event Logs IDs remotelly
    .INPUTS
    ComputerName
    EventID
    Credential
    .EXAMPLE
    eventlog.ps1 -ComputerName <Computer Name> -EventID <23> -Credential <admin@domain.com>
    You can run several servers as follows:
    $ComputerName = Get-Content "$pwd\serverlist.txt"; Foreach ($Computer in $ComputerName) {.\msuinstall.ps1 -ComputerName $Computer -W2K8R2KB KB3191566 -W2K12R2KB KB3191564 -Credential $youfcred}
    .LINK
    http://github.com/imjoseangel
#>


# Define Parameters
param
(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]$ComputerName,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$EventID = "153",
    [Parameter(Mandatory = $True, Position = 3)]
    [string]$LogName = "Application",
    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty
)

# Credentials

# You can generate the vault as follows:
# Read-host -assecurestring | convertfrom-securestring | out-file "$pwd\domain.vault"

#$valuevault = Get-Content "$pwd\domain.vault" | convertto-securestring
#$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist "myaccount@domain.biz",$valuevault

# Tests if Computer Exists
try {
    $ComputerExists = Test-Connection -ComputerName $ComputerName -BufferSize 16 -Count 1 -ErrorAction 0 -quiet
}
catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Warning "We failed to Test Connection. The error message was $ErrorMessage"
    Break
}

If (!($ComputerExists)) {
    Write-Warning "We failed to ping $ComputerName."
    break
}

# # Tests if WinRM is enabled
# try {
#     $WinRMEnabled = Test-WSMan -ComputerName $ComputerName -ErrorAction 0
# }
# catch {
#     $ErrorMessage = $_.Exception.Message
#     $FailedItem = $_.Exception.ItemName
#     Write-Warning "We failed to Test WinRM. The error message was $ErrorMessage"
#     Break
# }

# If (!($WinRMEnabled)) {
#     Write-Warning "We failed to reach WinRM at $ComputerName."
#     break
# }

# Mount C:\Windows\Temp\ Locally under the name RemoteTemp
try {

    Write-Host $ComputerName
    Write-Host "*****************************"
    Write-Host " "
    Get-WinEvent -LogName $LogName -ComputerName $ComputerName -Credential $Credential | Where-Object {$_.Id -eq $EventID}
    # Get-EventLog -ComputerName $ComputerName -LogName $LogName | Where-Object {$_.eventID -eq $EventID}
}
catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Warning "We failed to get log $FailedItem. The error message was $ErrorMessage"
    Break
}
