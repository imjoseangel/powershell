<#
    .SYNOPSIS
    Script to Install AppDynamics Agent
    .DESCRIPTION
    Provides a way to install AppDynamics Agent automatically
    .INPUTS
    CSVFile
    msiInstaller
    Application
    HostServer
    AccountName
    AccessKey
    Port
    .PARAMETER CSVFile
    CSVFile with the format Computer,Path,Site,Tier
    .PARAMETER msiInstaller
    msi file to install
    .PARAMETER Application
    Application Name. Example: Self Service Beaufort
    .PARAMETER HostServer
    Specifies the Server Host Name. Default: sd-p-infapp25.ds.youforce.biz
    .PARAMETER AccountName
    Account Name to connect to the AppDynamics Host Server. Default: customer1
    .PARAMETER AccessKey
    Access Key to connect to the AppDynamics Host Server. Default: e0eb0081-4b09-47ea-a658-f03bb24a7cbf
    .PARAMETER Port
    Port of AppDynamics in Host Server. Default: 8090
    .EXAMPLE
    Install-Agent.ps1 -CSVFile c:\Temp\Acceptance.csv -msiInstaller c:\Temp\dotNetAgentSetup64-4.3.3.2 -Application "Self Service Beaufort"
    .NOTES
    You can create servers as follows:
    $ComputerName = Get-Content "$pwd\computers.txt"; Foreach ($Computer in $ComputerName) {.\Install-Agent.ps1 <Parameters> }
    .LINK
    http://www.mypage.com
#>

# Define Parameters

param 
( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$CSVFile,
        [Parameter(Mandatory=$True, Position=1)]
        [string]$msiInstaller,        
        [Parameter(Mandatory=$True, Position=2)]
        [string]$Application,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [string]$HostServer="server.com",
        [int]$Port=8090,
        [string]$AccountName="username",
        [string]$AccessKey="12345-12345-12345-12345-12345"


)

function motd {
    
    Clear-Host

    $logo = Get-Content "$pwd\logo.txt" -ErrorAction SilentlyContinue
    
    if ($logo) {
        Write-Output $logo   
    }
}
    
motd{}

# Check PSVersion

$psversion = 0
if ($PSVersionTable.PSVersion.Major -ge 5)
{
	$psversion = 5
	Write-Host "You are using PowerShell 5.0 or above."
}

if ($PSVersionTable.PSVersion.Major -eq 4)
{
	$psversion = 4
	Write-Host "You are using PowerShell 4.0."
}

if ($psversion -eq 0)
{
	Write-Host "The powershell version is unknown!"
	exit -1
}

# Import Module if exists, if not exit script

$ModuleExists = Test-Path "$pwd\appdynamics.psm1"

if (!($ModuleExists)) {

    Write-Warning -Message "Cannot find Module Appdynamics. Exiting..."
    Break
    
} else {

    try {
        Import-Module "$pwd\appdynamics.psm1"
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Warning "We failed to Import Module $FailedItem. The error message was $ErrorMessage"
        Return
    }
    
}

$CSVExists = Test-Path $CSVFile -ErrorAction SilentlyContinue

if (!($CSVExists)) {
    
        Write-Warning -Message "CSV File doesn't exist. Please check. Exiting..."
        Return
}

$CSV = Import-CSV $CSVFile
$CSVList = $CSV | Select-Object -Property Computer -Unique
$Computers = $CSVList.Computer

Foreach ($Computer in $Computers) {
    try {
        #Install the agent on remote servers. Restart IIS

        Install-Agent $msiInstaller -ComputerName $Computer -RestartIIS -RemoteShare e$\Temp\AppDynamics\ -RemotePath E:\Temp\AppDynamics\    
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Warning "We failed to Install Agent for Server $Computer. The error message was $ErrorMessage"
    }

    try {
        
        #Update basic configuration on remote servers. Restart IIS

        Update-Configuration -Host $HostServer -Port $Port -SSL:$false -Application $Application -AccountName $AccountName -AccessKey $AccessKey -ComputerName $Computer -RestartIIS    
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Warning "We failed to Update Configuration for Server $Computer. The error message was $ErrorMessage"
    }    
}

For ($Row=0; $Row -lt $CSV.Count; $Row++){
    # Set Variables

    $Computer = $CSV[$Row].Computer
    $Site = $CSV[$Row].Site
    $Path = $CSV[$Row].Path
    $Tier = $CSV[$Row].Tier
    
    #Instrument the Default Web Site remotely. Restart IIS
    try {
        Add-IISApplicationMonitoring @{ Site="$Site"; Path="$Path"; Tier="$Tier" } -ComputerName $Computer -RestartIIS        
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Warning "We failed to Update Configuration for Server $Computer. The error message was $ErrorMessage"
    }
}