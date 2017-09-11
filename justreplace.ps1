Param (
    [String]$List = "ReplacementList.csv",
    [String]$Files = ".\Usage.html"
)
$ReplacementList = Import-Csv $List;
Get-ChildItem $Files |
ForEach-Object {
    $Content = Get-Content -Path $_.FullName;
    foreach ($ReplacementItem in $ReplacementList)
    {
        $Content = $Content.Replace($ReplacementItem.OldValue, $ReplacementItem.NewValue)
    }
    Set-Content -Path $_.FullName -Value $Content
}