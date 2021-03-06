# This script retrieves SMTP Address based on an input file

$A = (Get-Host).UI.RawUI
$A.BackgroundColor = "Black"
$A.ForegroundColor = "White"
$A.WindowTitle = "Get SMTP Address"

$OutputFile = "InputFile.txt"
New-Item .\$OutputFile -Type File

Clear Host

$Data = Get-Content $Args[0]

# Grab SMTP Addresses
ForEach ($Account in $Data)
{
   
$MB= Get-Mailbox -Identity "$Account"
$SMTPAddress = $($MB.PrimarySMTPAddress)
Add-Content $OutputFile "$SMTPAddress"

}