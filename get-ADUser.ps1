Param (
    [String]$List = $args[0]
)
$UserList = Get-Content $List;

ForEach-Object {
    
    foreach ($Alias in $UserList)
    {
        Get-ADUser -Identity $Alias -Server AMDC2.americas.bgsw.com -Properties Name,Title,Department | Export-Csv User.csv -NoTypeInformation -Append
    }
}
