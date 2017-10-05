$Filename = (Get-Date -Format "MMyyyy") + "_Approvals.csv"
$wsus = Get-WsusServer -Name $Env:COMPUTERNAME -PortNumber 8530

# Select Format Date (Mine is in US English)
$(Get-Culture).DateTimeFormat.ShortDatePattern = 'MM-dd-yyyy'
$(Get-Date).ToShortDateString()
 
$updates = $wsus | Get-WsusUpdate -Approval Unapproved -Classification All -Status FailedOrNeeded
 
$updates | Select-Object @{Name="KB";Expression={$_.update.KnowledgebaseArticles}},@{Name="Title";Expression={$_.update.Title}},`
@{Name="Severity";Expression={$_.update.MsrcSeverity}},@{Name="Classification";Expression={$_.update.UpdateClassificationTitle}},`
@{Name="Creation Date";Expression={$_.update.CreationDate.ToShortDateString()}},@{Name="OS";Expression={$_.update.ProductTitles}},`
@{Name="Has Superseded";Expression={$_.update.HasSupersededUpdates}},@{Name="Is Superseded";Expression={$_.update.IsSuperseded}},`
@{Name="Aditional Info";Expression={$_.update.AdditionalInformationUrls}},@{Name="Is Latest Revision";Expression={$_.update.IsLatestRevision}},`
@{Name="Has Earlier Revision";Expression={$_.update.HasEarlierRevision}},@{Name="Is Approved";Expression={$_.update.IsApproved}} |`
Export-Csv -NoTypeInformation -Path E:\Approvals\$Filename


$Filename = (Get-Date -Format "MMyyyy") + "_Computers.csv"
$wsus = Get-WsusServer -Name $Env:COMPUTERNAME -PortNumber 8530

# Get Computer and Update Scopes
$computerscope = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
$updatescope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
 
$wsus.GetSummariesPerComputerTarget($updatescope,$computerscope) | Select-Object @{L='Computer';`
E={($wsus.GetComputerTarget([guid]$_.ComputerTargetId)).FullDomainName}},`
@{L='NeededCount';E={($_.DownloadedCount + $_.NotInstalledCount)}},DownloadedCount,NotApplicableCount,NotInstalledCount,InstalledCount,FailedCount |`
Export-Csv -NoTypeInformation -Path E:\Approvals\$Filename

$Filename = (Get-Date -Format "MMyyyy") + "_KBs.csv"
$wsus = Get-WsusServer -Name $Env:COMPUTERNAME -PortNumber 8530

# Get Computer and Update Scopes
$computerscope = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
$updatescope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
$updatescope.ApprovedStates = [Microsoft.UpdateServices.Administration.ApprovedStates]::NotApproved
$updatescope.IncludedInstallationStates = [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::NotInstalled
 
$wsus.GetSummariesPerUpdate($updatescope,$computerscope) | Select-Object @{L='KB';E={($wsus.GetUpdate([guid]$_.UpdateId)).KnowledgebaseArticles}},`
@{L='NeededCount';E={($_.DownloadedCount + $_.NotInstalledCount)}},DownloadedCount,NotApplicableCount,NotInstalledCount,InstalledCount,FailedCount |`
Export-Csv -NoTypeInformation -Path E:\Approvals\$Filename


# https://github.com/RamblingCookieMonster/PowerShell/blob/master/Join-Object.ps1

$list1 = $updates | Select-Object @{Name="KB";Expression={$_.update.KnowledgebaseArticles}},@{Name="Title";Expression={$_.update.Title}},`
@{Name="Severity";Expression={$_.update.MsrcSeverity}},@{Name="Classification";Expression={$_.update.UpdateClassificationTitle}},`
@{Name="Creation Date";Expression={$_.update.CreationDate.ToShortDateString()}},@{Name="OS";Expression={$_.update.ProductTitles}},`
@{Name="Has Superseded";Expression={$_.update.HasSupersededUpdates}},@{Name="Is Superseded";Expression={$_.update.IsSuperseded}},`
@{Name="Aditional Info";Expression={$_.update.AdditionalInformationUrls}},@{Name="Is Latest Revision";Expression={$_.update.IsLatestRevision}},`
@{Name="Has Earlier Revision";Expression={$_.update.HasEarlierRevision}},@{Name="Is Approved";Expression={$_.update.IsApproved}}
 
$list2 = $wsus.GetSummariesPerUpdate($updatescope,$computerscope) | Select-Object @{L='KB';E={($wsus.GetUpdate([guid]$_.UpdateId)).KnowledgebaseArticles}},`
@{L='NeededCount';E={($_.DownloadedCount + $_.NotInstalledCount)}},DownloadedCount,NotApplicableCount,NotInstalledCount,InstalledCount,FailedCount


Join-Object -Left $list1 -Right $list2 -LeftJoinProperty KB -RightJoinProperty KB