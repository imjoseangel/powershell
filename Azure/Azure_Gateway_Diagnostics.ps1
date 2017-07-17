#------------------------------------------------------------------------------  
#  
# Copyright © 2014 Microsoft Corporation.  All rights reserved.  
#  
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT  
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT  
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS  
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR   
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.  
#  
#------------------------------------------------------------------------------  
#  
# PowerShell Source Code  
#  
# NAME:  
#    Azure_Gateway_Diagnostics.ps1  
#  
# VERSION:  
#    2.0 
#  
#------------------------------------------------------------------------------ 
 
"------------------------------------------------------------------------------ " | Write-Host -ForegroundColor Yellow 
""  | Write-Host -ForegroundColor Yellow 
" Copyright © 2014 Microsoft Corporation.  All rights reserved. " | Write-Host -ForegroundColor Yellow 
""  | Write-Host -ForegroundColor Yellow 
" THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED `“AS IS`” WITHOUT " | Write-Host -ForegroundColor Yellow 
" WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT " | Write-Host -ForegroundColor Yellow 
" LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS " | Write-Host -ForegroundColor Yellow 
" FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR  " | Write-Host -ForegroundColor Yellow 
" RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER. " | Write-Host -ForegroundColor Yellow 
"------------------------------------------------------------------------------ " | Write-Host -ForegroundColor Yellow 
""  | Write-Host -ForegroundColor Yellow 
" PowerShell Source Code " | Write-Host -ForegroundColor Yellow 
""  | Write-Host -ForegroundColor Yellow 
" NAME: " | Write-Host -ForegroundColor Yellow 
"    Azure_Gateway_Diagnostics.ps1 " | Write-Host -ForegroundColor Yellow 
"" | Write-Host -ForegroundColor Yellow 
" VERSION: " | Write-Host -ForegroundColor Yellow 
"    2.0" | Write-Host -ForegroundColor Yellow 
""  | Write-Host -ForegroundColor Yellow 
"------------------------------------------------------------------------------ " | Write-Host -ForegroundColor Yellow 
"" | Write-Host -ForegroundColor Yellow 
"`n This script SAMPLE is provided and intended only to act as a SAMPLE ONLY," | Write-Host -ForegroundColor Yellow 
" and is NOT intended to serve as a solution to any known technical issue."  | Write-Host -ForegroundColor Yellow 
"`n By executing this SAMPLE AS-IS, you agree to assume all risks and responsibility associated."  | Write-Host -ForegroundColor Yellow 
 
$ErrorActionPreference = "SilentlyContinue" 
$ContinueAnswer = Read-Host "`n Do you wish to proceed at your own risk? (Y/N)" 
If ($ContinueAnswer -ne "Y") { Write-Host "`n Exiting." -ForegroundColor Red;Exit } 

#import module
Write-Host "`n Checking Azure PowerShell module" -ForegroundColor Cyan
Import-Module Azure

#check module version
$modver = (Get-Module azure).version
$PSMinor =$modver.Minor
$PSBuild =$modver.Build
If ($PSMinor -ne 5){ Write-Host "`n FAILED: Azure PowerShell update required`n`thttp://go.microsoft.com/fwlink/p/?linkid=320376`n" -fore red;Exit } Else { Write-Host "`tConfirmed" -fore Green }

#remove existing subs
If (Get-AzureSubscription) { Get-AzureSubscription | Remove-AzureSubscription -Force }

#auth
Write-Host "`n Authenticating to your Azure account" -ForegroundColor Cyan
Add-AzureAccount | Out-Null

#select sub
Write-Host "`n Listing available Azure subscriptions:" -ForegroundColor Cyan
If (Get-AzureSubscription) { Get-AzureSubscription | Select SubscriptionName,SubscriptionId | FT } Else { Write-Host "`n FAILED: No subscriptions found`n" -fore red;Exit }
$selSub = Read-Host "`n Select SubscriptionID"
If (!(Get-AzureSubscription -SubscriptionId $selSub -ErrorAction SilentlyContinue)){ Write-Host "`n FAILED: Invalid SubscriptionId`n" -fore red;Exit }
Select-AzureSubscription -SubscriptionId $selSub | Out-Null

#select storage
Write-Host "`n Listing available Storage Accounts:" -ForegroundColor Cyan
Get-AzureStorageAccount | Select StorageAccountName | FT
$san=Read-Host "`n Select Storage Account Name"
If (!(Get-AzureStorageAccount -StorageAccountName $san -ErrorAction SilentlyContinue)){ Write-Host "`n FAILED: Invalid Storage Account Name`n" -fore red;Exit }

#get storage context
$key=(Get-AzureStorageKey -StorageAccountName $san).primary
$cxt=New-AzureStorageContext -StorageAccountName $san -StorageAccountKey $key
If (!$cxt){ Write-Host "`n FAILED: Storage Key not obtained`n" -fore red;Exit }

#select container
Write-Host "`n Listing available Storage Account Containers:" -ForegroundColor Cyan
Get-AzureStorageContainer -Context $cxt | Select Name | FT
$container=Read-Host "`n Select Storage Container Name"
If (!(Get-AzureStorageContainer -Name $container -Context $cxt -ErrorAction SilentlyContinue)){ Write-Host "`n FAILED: Invalid Storage Container Name`n" -fore red;Exit }

#select VNET
Write-Host "`n Listing available Virtual Networks (having Gateways):" -ForegroundColor Cyan
Get-AzureVNetSite | Where GatewayProfile -ne $null | Select Name | FT
$vnet=Read-Host "`n Select Virtual Network Name"
If (!(Get-AzureVNetSite -VNetName $vnet -ErrorAction SilentlyContinue)){ Write-Host "`n FAILED: Invalid Virtual Network Name`n" -fore red;Exit }

#select duration
[int]$duration=Read-Host "`n Select Duration (seconds with 300 max)"
If (!($duration -gt 0 -and $duration -le 300)){ Write-Host "`n FAILED: Invalid Duration`n" -fore red;Exit }

#set output file
$outputfile="$Env:TEMP\AzureGatewayDiag.txt"

#start diags
Write-Host "`n Starting diagnostics for VNET $vnet`n" -ForegroundColor Cyan
$StartDiags=Start-AzureVNetGatewayDiagnostics -VNetName $vnet -CaptureDurationInSeconds $duration -ContainerName $container -StorageContext $cxt
If ($StartDiags.Status -eq "Successful") { Write-Host "`tSuccessfully started tracing" -fore green } Else { Write-Host "`tFAILED: $($StartDiags.Error)`n" -fore red;Exit }

#wait
Write-Host "`n Waiting $duration seconds" -ForegroundColor Cyan
Start-Sleep -Seconds $duration

#check status for up to 5 minutes
$State = "NotReady"
$Iterations = 1
While ($State -ne "Ready" -and $Iterations -lt 150)
{
     Write-Host "`n Checking status" -ForegroundColor Cyan
     $State = (Get-AzureVNetGatewayDiagnostics -VNetName $vnet).State
     Write-Host "`t$State"
     Start-Sleep -Seconds 2
	 $Iterations++
}

#get diags URL
$url = (Get-AzureVNetGatewayDiagnostics -VNetName $vnet).DiagnosticsUrl

#download output
Write-Host "`n Downloading data" -ForegroundColor Cyan
$wc = New-Object System.Net.WebClient
Try
{ $wc.DownloadFile($url, $outputFile) }
Catch [Exception]
{ Write-Host "`tFAILED: $_`n`n`tTry manually browsing: $url" -fore red;Exit }

#open output file
If (Test-Path $outputFile) { Invoke-Item $outputFile } Else { Write-Host "`tFAILED: Output file not found`n`n`tTry manually browsing: $url" -fore red }
Write-Host "`n Done`n`n" -ForegroundColor Cyan