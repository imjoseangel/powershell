$mailboxAccess = read-host "Which mailbox do you want to give Full Access to?"
$mailboxUser = read-host "Which user do you want to give access to $mailboxAccess to (give full email address)?"
 
Add-MailboxPermission $mailboxAccess -AccessRights FullAccess -User $mailboxUser -InheritanceType All -Confirm:$false