$ServerAccess = read-host "Which Server do you want to access to?"

$ADFSCredential = Get-Credential
Enter-PSSession $ServerAccess -Credential $ADFSCredential