Set-ExecutionPolicy RemoteSigned
$Credential = Get-Credential
 
$PSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Credential -Authentication Basic -AllowRedirection
 
Import-PSSession $PSSession
 
$mailboxAccess = read-host "Which mailbox do you want to give full access to?"
$mailboxUser = read-host "Which user do you want to give access to $mailboxAccess to (give full email address)?"
 
Add-MailboxPermission $mailboxAccess -User $mailboxUser -AccessRights FullAccess -InheritanceType All