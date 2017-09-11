$mailbox = $args[0]
 
# Mailbox Full Access Permissions
[array]$Result = Get-MailboxPermission $Mailbox | where { ($_.AccessRights -like "*FullAccess*") -and ($_.IsInherited -eq $false) -and -not ($_.User -like "NT AUTHORITY\SELF") } | Select User
[array]$AccessUsers=@()
$Members = @()
foreach ($Item in $Result)
{
    $User = Get-User $Item.User.ToString() -ErrorAction SilentlyContinue
    $Members += $User.UserPrincipalName
}
 
$Members