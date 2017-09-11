<#
    .SYNOPSIS
    Script to install msu remotelly
    .DESCRIPTION
    This script provides a way to install msu packages remotelly
    .INPUTS
    ComputerName
    W2K8R2KB
    W2K12R2KB
    Credential
    .EXAMPLE
    msuinstall.ps1 -ComputerName <Computer Name> -W2K8R2KB <W2K8R2-KB012345.msu>  -W2K12R2KB <W2K12R2-KB012345.msu> -Credential <admin@domain.com>
    You can run several servers as follows:
    $ComputerName = Get-Content "$pwd\serverlist.txt"; Foreach ($Computer in $ComputerName) {.\msuinstall.ps1 -ComputerName $Computer -W2K8R2KB KB3191566 -W2K12R2KB KB3191564 -Credential $youfcred}
    .LINK
    http://www.domain.com
#>


# Define Parameters
param 
( 
        [Parameter(Mandatory=$True,Position=1)]
        [string]$ComputerName,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$W2K8R2KB,
        [Parameter(Mandatory=$True,Position=3)]
        [string]$W2K12R2KB,
        [Parameter(Mandatory=$True,Position=4)]
        [string]$W2K12KB,
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty 
)

# Logo
function motd {

}

motd{}

Write-Output "Starting Computer: $ComputerName"

# Variables
$WindowsTemp = "C:\Windows\Temp"

# Credentials

# You can generate the vault as follows:
# Read-host -assecurestring | convertfrom-securestring | out-file "$pwd\user"

#$valueyouf = Get-Content "$pwd\user" | convertto-securestring
#$youfcred = new-object -typename System.Management.Automation.PSCredential -argumentlist "user",$valueyouf

# Tests if Computer Exists
try {
    $ComputerExists = Test-Connection -ComputerName $ComputerName -BufferSize 16 -Count 1 -ErrorAction 0 -quiet
}
catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Warning "We failed to Test Connection. The error message was $ErrorMessage"
    Return
}

If(!($ComputerExists)) {
    Write-Warning "We failed to ping $ComputerName."
    Return
}

# Tests if WinRM is enabled
try {
    $WinRMEnabled = Test-WSMan -ComputerName $ComputerName -ErrorAction 0
}
catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Warning "We failed to Test WinRM. The error message was $ErrorMessage"
    Return
}

If(!($WinRMEnabled)) {
    Write-Warning "We failed to reach WinRM at $ComputerName."
    Return
}

# Use to Mount $WindowsTemp\ Locally under the name RemoteTemp
# Now using New-PSSession

try {
    # New-PSDrive -name RemoteTemp -PSProvider FileSystem -Root \\$ComputerName\c$\Windows\Temp -Credential $Credential -ErrorAction Stop
    $Session = New-PSSession -ComputerName $ComputerName -Credential $Credential
}
catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Warning "We failed to create session $FailedItem. The error message was $ErrorMessage"
    Return
}

$OS = Get-WmiObject -class Win32_OperatingSystem -ComputerName $ComputerName -Credential $Credential -ErrorAction Stop
$OSDescription = $OS.Caption

switch -Wildcard ($OSDescription)
{
    "*Windows Server 2008 R2*" {

        $Hotfix = Get-HotFix -ComputerName $ComputerName -Credential $Credential | Where-Object HotfixID -Like $W2K8R2KB | Select-Object -property "HotFixID"

        if ($Hotfix) {
            "HotFix " + $W2K8R2KB + " already installed."
                } else {

                    # Tests if Temp Exists
                    $TempExists = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Test-Path $Using:WindowsTemp\$Using:W2K8R2KB} -ErrorAction Stop

                    # If Temp doesn't exists, create it
                    if (!($TempExists)) {
                        Write-Information "Creating Temp File"
                        try {
                            $createtemp = { New-Item -ItemType Directory $Using:WindowsTemp\$Using:W2K8R2KB -ErrorAction Stop }
                            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock $createtemp -ErrorAction Stop
                            }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            Write-Warning "We failed to read directory $FailedItem. The error message was $ErrorMessage"
                            Return
                                }
                            } else {
                            Write-Information -MessageData "Directory already created" -Tags "Message" -InformationAction Continue 
                        } # EndIF


                    $FileExists = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Test-Path $Using:WindowsTemp\$Using:W2K8R2KB\W2K8R2-$Using:W2K8R2KB-x64.msu} -ErrorAction Stop
                    if (!($FileExists)) {
                        Write-Information "Copying msu File"
                        try {
                            Copy-Item -Path "$pwd\W2K8R2-$W2K8R2KB-x64.msu" -Destination $WindowsTemp\$W2K8R2KB -ToSession $Session -ErrorAction Stop
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            Write-Warning "We failed to copy file $FailedItem. The error message was $ErrorMessage"
                            Return
                            }
                        } else {
                        Write-Information -MessageData "File already copied" -Tags "Message" -InformationAction Continue 
                    } # EndIF

                        try {
                            $msuextract = { Start-Process -FilePath 'wusa.exe' -ArgumentList "$Using:WindowsTemp\$Using:W2K8R2KB\W2K8R2-$Using:W2K8R2KB-x64.msu /extract:$Using:WindowsTemp\$Using:W2K8R2KB" -Wait -PassThru }
                            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock $msuextract -AsJob -ErrorAction Stop
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            Write-Warning "We failed to extract file $FailedItem. The error message was $ErrorMessage"
                            Return
                        }

                        try {
                            While (!(Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Test-Path $Using:WindowsTemp\$Using:W2K8R2KB\*.xml})) {Start-Sleep -Seconds 1}

                                $xmlquery = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-ChildItem -Path $Using:WindowsTemp\$Using:W2K8R2KB\*.xml | Select-Object Name}
                                $xmlname = $xmlquery.Name
                                Write-Output "Installing from XML: " $xmlname

                            $cabinstall={ Start-Process -FilePath 'dism.exe' -ArgumentList "/Online /Apply-Unattend:$Using:WindowsTemp\$Using:W2K8R2KB\$Using:xmlname /Quiet /NoRestart" -Wait -PassThru }
                            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock $cabinstall -AsJob -ErrorAction Stop
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            Write-Warning "We failed to install file $FailedItem. The error message was $ErrorMessage"
                            Return
                        }
            }
        }

    "*Windows Server 2012 R2*" {

        $Hotfix = Get-HotFix -ComputerName $ComputerName -Credential $Credential | Where-Object HotfixID -Like $W2K12R2KB | Select-Object -property "HotFixID"

        if ($Hotfix) {
            "HotFix " + $W2K12R2KB + " already installed."
                } else {

                    # Tests if Temp Exists
                    $TempExists = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Test-Path $Using:WindowsTemp\$Using:W2K12R2KB} -ErrorAction Stop

                    # If Temp doesn't exists, create it
                    if (!($TempExists)) {
                        Write-Information "Creating Temp File"
                        try {
                            $createtemp = { New-Item -ItemType Directory $Using:WindowsTemp\$Using:W2K12R2KB -ErrorAction Stop }
                            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock $createtemp -ErrorAction Stop
                            
                            }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            Write-Warning "We failed to read directory $FailedItem. The error message was $ErrorMessage"
                            Return
                                }
                            } else {
                            Write-Information -MessageData "Directory already created" -Tags "Message" -InformationAction Continue 
                        } # EndIF


                    $FileExists = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Test-Path $Using:WindowsTemp\$Using:W2K12R2KB\W2K12R2-$Using:W2K12R2KB-x64.msu} -ErrorAction Stop
                    if (!($FileExists)) {
                        Write-Information "Copying msu File"
                        try {
                            Copy-Item -Path "$pwd\W2K12R2-$W2K12R2KB-x64.msu" -Destination $WindowsTemp\$W2K12R2KB -ToSession $Session -ErrorAction Stop
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            Write-Warning "We failed to copy file $FailedItem. The error message was $ErrorMessage"
                            Return
                            }
                        } else {
                        Write-Information -MessageData "File already copied" -Tags "Message" -InformationAction Continue 
                    } # EndIF

                        try {
                            $msuextract = { Start-Process -FilePath 'wusa.exe' -ArgumentList "$Using:WindowsTemp\$Using:W2K12R2KB\W2K12R2-$Using:W2K12R2KB-x64.msu /extract:$Using:WindowsTemp\$Using:W2K12R2KB" -Wait -PassThru }
                            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock $msuextract -AsJob -ErrorAction Stop
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            Write-Warning "We failed to extract file $FailedItem. The error message was $ErrorMessage"
                            Return
                        }

                        try {
                            While (!(Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Test-Path $Using:WindowsTemp\$Using:W2K12R2KB\*.xml})) {Start-Sleep -Seconds 1}

                                $xmlquery = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-ChildItem -Path $Using:WindowsTemp\$Using:W2K12R2KB\*.xml | Select-Object Name}
                                $xmlname = $xmlquery.Name
                                Write-Output "Installing from XML: " $xmlname

                            $cabinstall={ Start-Process -FilePath 'dism.exe' -ArgumentList "/Online /Apply-Unattend:$Using:WindowsTemp\$Using:W2K12R2KB\$Using:xmlname /Quiet /NoRestart" -Wait -PassThru }
                            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock $cabinstall -AsJob -ErrorAction Stop
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            Write-Warning "We failed to install file $FailedItem. The error message was $ErrorMessage"
                            Return
                        }
            }
        }

"*Windows Server 2012 Datacenter*" {

        $Hotfix = Get-HotFix -ComputerName $ComputerName -Credential $Credential | Where-Object HotfixID -Like $W2K12KB | Select-Object -property "HotFixID"

        if ($Hotfix) {
            "HotFix " + $W2K12KB + " already installed."
                } else {

                    # Tests if Temp Exists
                    $TempExists = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Test-Path $Using:WindowsTemp\$Using:W2K12KB} -ErrorAction Stop

                    # If Temp doesn't exists, create it
                    if (!($TempExists)) {
                        Write-Information "Creating Temp File"
                        try {
                            $createtemp = { New-Item -ItemType Directory $Using:WindowsTemp\$Using:W2K12KB -ErrorAction Stop }
                            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock $createtemp -ErrorAction Stop
                            
                            }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            Write-Warning "We failed to read directory $FailedItem. The error message was $ErrorMessage"
                            Return
                                }
                            } else {
                            Write-Information -MessageData "Directory already created" -Tags "Message" -InformationAction Continue 
                        } # EndIF


                    $FileExists = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Test-Path $Using:WindowsTemp\$Using:W2K12KB\W2K12-$Using:W2K12KB-x64.msu} -ErrorAction Stop
                    if (!($FileExists)) {
                        Write-Information "Copying msu File"
                        try {
                            Copy-Item -Path "$pwd\W2K12-$W2K12KB-x64.msu" -Destination $WindowsTemp\$W2K12KB -ToSession $Session -ErrorAction Stop
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            Write-Warning "We failed to copy file $FailedItem. The error message was $ErrorMessage"
                            Return
                            }
                        } else {
                        Write-Information -MessageData "File already copied" -Tags "Message" -InformationAction Continue 
                    } # EndIF

                        try {
                            $msuextract = { Start-Process -FilePath 'wusa.exe' -ArgumentList "$Using:WindowsTemp\$Using:W2K12KB\W2K12-$Using:W2K12KB-x64.msu /extract:$Using:WindowsTemp\$Using:W2K12KB" -Wait -PassThru }
                            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock $msuextract -AsJob -ErrorAction Stop
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            Write-Warning "We failed to extract file $FailedItem. The error message was $ErrorMessage"
                            Return
                        }

                        try {
                            While (!(Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Test-Path $Using:WindowsTemp\$Using:W2K12KB\*.xml})) {Start-Sleep -Seconds 1}

                                $xmlquery = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-ChildItem -Path $Using:WindowsTemp\$Using:W2K12KB\*.xml | Select-Object Name}
                                $xmlname = $xmlquery.Name
                                Write-Output "Installing from XML: " $xmlname

                            $cabinstall={ Start-Process -FilePath 'dism.exe' -ArgumentList "/Online /Apply-Unattend:$Using:WindowsTemp\$Using:W2K12KB\$Using:xmlname /Quiet /NoRestart" -Wait -PassThru }
                            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock $cabinstall -AsJob -ErrorAction Stop
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $FailedItem = $_.Exception.ItemName
                            Write-Warning "We failed to install file $FailedItem. The error message was $ErrorMessage"
                            Return
                        }
            }
        }

    default {Write-Output "The System OS could not be determined"}
}

try {
    Remove-PSSession -Session $Session
}
catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Warning "We failed to unmount directory $FailedItem. The error message was $ErrorMessage"
    Return
}