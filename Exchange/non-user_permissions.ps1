$AllUsers = Get-Mailbox -RecipientTypeDetails 'UserMailbox' -ResultSize Unlimited

ForEach ($Alias in $AllUsers)
{
$Mailbox = "" + $Alias.Name
Write-Host "Getting folders for mailbox: " $Mailbox
$Folders = Get-MailboxFolderStatistics $Mailbox | % {$_.folderpath} | % {$_.replace(“/”,”\”)}

ForEach ($F in $Folders)
{
$FolderKey = $Mailbox + ":" + $F
$Permissions = Get-MailboxFolderPermission -identity $FolderKey -ErrorAction SilentlyContinue
$Permissions | Where-Object {$_.User -notlike "Default" -and $_.User -notlike "Anonymous" -and $_.AccessRights -notlike "None" -and $_.AccessRights -notlike "Owner" }| Format-Table $Mailbox, User, FolderName, AccessRights -AutoSize
}
}