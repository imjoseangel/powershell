$mailboxAccess = read-host "Which mailbox do you want to give SendAs access to?"
$mailboxUser = read-host "Which user do you want to give access to $mailboxAccess to (give full email address)?"
 
Add-RecipientPermission $mailboxAccess -AccessRights SendAs -Trustee $mailboxUser