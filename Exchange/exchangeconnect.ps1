Set-ExecutionPolicy RemoteSigned
$Credential = Get-Credential
 
$PSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Credential -Authentication Basic -AllowRedirection
 
Import-PSSession $PSSession
