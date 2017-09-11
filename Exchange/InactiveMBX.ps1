#################################################################################
# 
# The sample scripts are not supported under any Microsoft standard support 
# program or service. The sample scripts are provided AS IS without warranty 
# of any kind. Microsoft further disclaims all implied warranties including, without 
# limitation, any implied warranties of merchantability or of fitness for a particular 
# purpose. The entire risk arising out of the use or performance of the sample scripts 
# and documentation remains with you. In no event shall Microsoft, its authors, or 
# anyone else involved in the creation, production, or delivery of the scripts be liable 
# for any damages whatsoever (including, without limitation, damages for loss of business 
# profits, business interruption, loss of business information, or other pecuniary loss) 
# arising out of the use of or inability to use the sample scripts or documentation, 
# even if Microsoft has been advised of the possibility of such damages
#
#################################################################################
#
# Script to  collect inactive mailbox list on Exchange 2007/2010/2013 servers .
# Powershell 2.0 or later required.
# Created by sukum@microsoft.com.
# Last Update July 04 2013.
# Version 1.0.3
# Version 1.0.1 Excluding SystemMailboxes, DiscoveryMailbox and Federal Mailbox in output.
# Version 1.0.2 EmailID,HubServer,Database parameters are added.The report can be sent thru email.
# Version 1.0.3 Added Progress / Status bar.


Function Get-InActiveMailbox
{

[cmdletBinding()]

Param(
[Parameter(Mandatory=$true)][ValidateRange(1,5000)][Int]$Idledays,
[String]$FilePath,
[String]$Server,
[String]$Database,
[String]$HUBServer,
[String]$EmailID

)

Process
{
$CurDate=Get-Date
$DayInactiveMailbox="DayInactiveMailbox"

#It checks whether FilePath given. If not, it stores the output file in script running folder. If the path is given without \ at end, it adds \.

if($FilePath -eq ""){$FilePath = ".\"} elseif($FilePath.EndsWith("\")){$FilePath=$FilePath} else{$FilePath=$FilePath+"\"}

# It checkes whether Server and Database parameters are used together.

If (($server -ne "") -and ($Database -ne ""))
{
Write-Host "================================================================"
Write-Host ""
Write-Host "You cannot use Server and Database together. Exiting script." -ForegroundColor Yellow
Write-Host ""
Break
}

# It checks whether HUBServer and EmailID are used to send email.

if(($EmailID -ne "") -and ($HUBServer -eq ""))
{
Write-Host "================================================================"
Write-Host ""
Write-Host "You have to use EmailID with HUBServer. Exiting script." -ForegroundColor Yellow
Write-Host ""
$SendEmail = "False"
Break
} 
elseif(($EmailID -eq "") -and ($HUBServer -eq "")) 
{
$SendEmail = "False"
}
else
{
$SendEmail = "True"
}

#If the database is  given , it looks for the mailboxes in the database , else it will run agaist all the mailboxes in organization.

If ((!$Database) -and ($Server -eq ""))
{
Write-Progress -Activity "Getting List of mailboxes" -Status "In Progress....."
$lstmbx=Get-Mailbox -ResultSize unlimited  | where {(!$_.name.startswith("SystemMailbox")) -and (!$_.name.startswith("FederatedEmail")) -and (!$_.name.startswith("DiscoverySearchMailbox"))}
}
elseif (($Database) -and ($Server -eq ""))
{
Write-Progress -Activity "Getting List of mailboxes" -Status "In Progress....."
$lstmbx=Get-Mailbox -ResultSize unlimited -Database $Database | where {(!$_.name.startswith("SystemMailbox")) -and (!$_.name.startswith("FederatedEmail")) -and (!$_.name.startswith("DiscoverySearchMailbox"))}
}

#If the server is given , it looks for the mailbox databases mounted on the server, else it will run agaist all the mailboxes in orgganization.

If ((!$Server) -and ($Database -eq ""))
{
Write-Progress -Activity "Getting List of mailboxes" -Status "In Progress....."
$lstmbx=Get-Mailbox -ResultSize unlimited | where {(!$_.name.startswith("SystemMailbox")) -and (!$_.name.startswith("FederatedEmail")) -and (!$_.name.startswith("DiscoverySearchMailbox"))}
}
elseif (($Server) -and ($Database -eq ""))
{
Write-Progress -Activity "Getting List of mailboxes" -Status "In Progress....."
$lstmbx=Get-Mailbox -ResultSize unlimited -server $Server | where {(!$_.name.startswith("SystemMailbox")) -and (!$_.name.startswith("FederatedEmail")) -and (!$_.name.startswith("DiscoverySearchMailbox"))}
}

$cmplt=0
# As there is a restriction in using multiple pipes in Powershell 2.0, I have stored the get-mailbox into a variable and piping into foreach, then checking the sent item folder for recent sent message.

$lstmbx | foreach-object {
	$cmplt++
	$mbx=$_
	$als=$mbx.alias
	write-progress -activity "Checking the mailboxes to calculate Idle days" -status "Currently processing the mailbox(alias) : $als" -percentcomplete (($cmplt/$lstmbx.count)*100)	
	$FS =Get-MailboxFolderStatistics -identity $mbx.alias -IncludeOldestAndNewestItems -folderscope sentitems 
	
    add-member -input $FS -membertype noteproperty -name "MBXName" -value $mbx.Name -ea silentlycontinue
	add-member -input $FS -membertype noteproperty -name "Alias" -value $mbx.alias -ea silentlycontinue
	add-member -input $FS -membertype noteproperty -name "Server Name" -value $mbx.servername -ea silentlycontinue
    add-member -input $FS -membertype noteproperty -name "Org. Unit" -value $mbx.OrganizationalUnit -ea silentlycontinue
	add-member -input $FS -membertype noteproperty -name "DB" -value $mbx.Database -ea silentlycontinue
	add-member -input $FS -membertype noteproperty -name "Cust. ATTR1" -value $mbx.CustomAttribute1 -ea silentlycontinue
		
        if ($FS.NewestItemReceivedDate)
		{
		add-member -input $FS -membertype noteproperty -name "When Was Email Sent(Days)" -value ($CurDate.subtract($FS.NewestItemReceivedDate).days) -ea silentlycontinue
		}
		else 
		{
		add-member -input $FS -membertype noteproperty -Name "When Was Email Sent(Days)" -value "Never Sent Email/New Mailbox" -ea silentlycontinue
		}

		$countsent = $FS."When Was Email Sent(Days)"

		if($countsent -ge $Idledays -OR $countsent -eq "Never Sent Email/New Mailbox")
		{
		$FS | select-object MBXName,Alias,NewestItemReceivedDate,"When Was Email Sent(Days)","Org. Unit",DB,"Cust. ATTR1"
		}


} | EXPORT-CSV $FilePath$Idledays$DayInactiveMailbox.csv 

$AddFile="$FilePath$Idledays$DayInactiveMailbox.csv"
Write-Host "================================================================"
Write-Host ""
Write-Host "File Generated. The details available in $AddFile" -ForegroundColor Yellow
Write-Host ""

# Sending email.
# When you are sending email, the sender should get authenticated as aunonymous is not allowed in HUB server by default. 
# If EmailID parameter is used, you will be prompted for user name and password.

If($SendEmail -eq "True"){
$PWD = Get-Credential 
send-mailmessage -from $EmailID -to $EmailID -subject "Inactive Mailbox List : $CurDate" -credential $PWD -body "Inactive Mailbox List. Please check the attachment for the result" -smtpServer "$HUBServer" -Attachments $AddFile 

}

Write-Host "================================================================"
Write-Host ""
Write-Host "Script Completed.Thank you using the script" -ForegroundColor Yellow
Write-Host ""

}
}