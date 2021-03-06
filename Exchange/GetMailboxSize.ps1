# This script retrieves mailbox size based on an input file

$A = (Get-Host).UI.RawUI
$A.BackgroundColor = "Black"
$A.ForegroundColor = "White"
$A.WindowTitle = "Get Mailbox Size"

$OutputFile = "MailboxSize.txt"
New-Item .\$OutputFile -Type File

Clear Host

$Data = Get-Content $Args[0]

# Remove completed move requests
ForEach ($Account in $Data)
{
   
$MB= Get-MailboxStatistics -Identity "$Account"
$DisplayName = $($MB.DisplayName)
$TotalItemSize = $($MB.TotalItemSize)
Add-Content $OutputFile "$Displayname;$TotalItemSize"

}