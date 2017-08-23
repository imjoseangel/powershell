param (
    [Parameter(Mandatory=$true)][string]$server
#    [Securestring]$password = $( Read-Host -assecurestring "Input password, please" )
 )

$Computer = $server

$valuedom1 = cat "$pwd\domain1.vault" | convertto-securestring
$valuedom2 = cat "$pwd\domain2.vault" | convertto-securestring

$dom1cred = new-object -typename System.Management.Automation.PSCredential -argumentlist "admin@domain1",$valuedom1
$dom2cred = new-object -typename System.Management.Automation.PSCredential -argumentlist "admin@domain2",$valuedom2

Invoke-Command -ComputerName server.domain1 -Credential $dom1cred -EnableNetworkAccess `
-ConfigurationName microsoft.powershell -ScriptBlock { Invoke-Command -ComputerName $Using:Computer `
-EnableNetworkAccess -Credential $Using:dom2cred -ScriptBlock { Import-Module WebAdministration; `
Get-WebSite | Format-Table }}