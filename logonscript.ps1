# ================
# DEFINE VARIABLES
# ================

clear

Write-EventLog -LogName 'Application' -Source 'EventSystem' -EntryType Information -EventId 400 -Message 'Logon Script - Creating Variables'
$Scripts = 'C:\Scripts'
$architecture=(Get-WmiObject Win32_OperatingSystem).OSArchitecture

# =====================
# RUNNING GLOBAL SCRIPT
# =====================

Write-EventLog -LogName 'Application' -Source 'EventSystem' -EntryType Information -EventId 400 -Message 'Logon Script - Running Global Script'
Write-Host '  #########################' -Fore Yellow
Write-Host ' # Running Global Script #' -Fore Yellow
Write-Host '#########################' `r`n -Fore Yellow

Write-Progress -id 1 -Activity Running -Status 'Progress' -PercentComplete 20

Try
{
    Start-Process $env:LOGONSERVER'\SYSVOL\emea.local\scripts\LS_AQNGlobal.vbs' -WindowStyle Hidden -WorkingDirectory $Scripts -ErrorAction Stop -Wait
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Host 'ERROR: Running Generic Script' `r`n -Fore Red
    Write-EventLog -LogName 'Application' -Source 'EventSystem' -EntryType Error -EventId 500 -Message "Error Running Generic Script. The error message was $ErrorMessage"
}
Finally
{
    Write-Host 'Global Script Finished' `r`n -Fore Green
    Write-EventLog -LogName 'Application' -Source 'EventSystem' -EntryType Information -EventId 400 -Message 'Logon Script - Global Script Finished'
}

# ====================
# RUNNING LOCAL SCRIPT
# ====================

Write-EventLog -LogName 'Application' -Source 'EventSystem' -EntryType Information -EventId 400 -Message 'Logon Script - Running Local Script'
Write-Host '  ########################' -Fore Yellow
Write-Host ' # Running Local Script #' -Fore Yellow
Write-Host '########################' `r`n -Fore Yellow

Write-Progress -id 1 -Activity Running -Status 'Progress' -PercentComplete 40

Try
{
    Start-Process $env:LOGONSERVER'\SYSVOL\emea.local\scripts\LS_AQNLocal.vbs' -WindowStyle Hidden -WorkingDirectory $Scripts -ErrorAction Stop -Wait
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Host 'ERROR: Running Local Script' `r`n -Fore Red
    Write-EventLog -LogName 'Application' -Source 'EventSystem' -EntryType Error -EventId 500 -Message "Error Running Local Script. The error message was $ErrorMessage"
}
Finally
{
    Write-Host 'Local Script Finished' `r`n -Fore Green
    Write-EventLog -LogName 'Application' -Source 'EventSystem' -EntryType Information -EventId 400 -Message 'Logon Script - Local Script Finished'
}

# =======================
# UPDATING AV DEFINITIONS
# =======================

Write-EventLog -LogName 'Application' -Source 'EventSystem' -EntryType Information -EventId 400 -Message 'Logon Script - Updating AV Definitions'
Write-Host '  ###########################' -Fore Yellow
Write-Host ' # Updating AV Definitions #' -Fore Yellow
Write-Host '###########################' `r`n -Fore Yellow

Write-Progress -id 1 -Activity Running -Status 'Progress' -PercentComplete 60

Try
{
if ($architecture -eq '64-bit')
{
    & ${env:ProgramFiles(x86)}'\McAfee\VirusScan Enterprise\mcupdate.exe' '/update' '/quiet' -WindowStyle Hidden -WorkingDirectory ${env:ProgramFiles(x86)}'\McAfee\VirusScan Enterprise' -ErrorAction Stop -Wait
}
else
{
    & ${env:ProgramFiles}'\McAfee\VirusScan Enterprise\mcupdate.exe' '/update' '/quiet' -WindowStyle Hidden -WorkingDirectory ${env:ProgramFiles(x86)}'\McAfee\VirusScan Enterprise' -ErrorAction Stop -Wait
}
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Host 'ERROR: Updating AV Definitions' `r`n -Fore Red
    Write-EventLog -LogName 'Application' -Source 'EventSystem' -EntryType Error -EventId 500 -Message "Error Updating AV Definitions. The error message was $ErrorMessage" 
}
Finally
{
    Write-Host 'AV Definitions Update Finished' `r`n -Fore Green
    Write-EventLog -LogName 'Application' -Source 'EventSystem' -EntryType Information -EventId 400 -Message 'Logon Script - AV Definitions Update Finished'
}

# ========================
# UPDATING DOMAIN POLICIES
# ========================

Write-EventLog -LogName 'Application' -Source 'EventSystem' -EntryType Information -EventId 400 -Message 'Logon Script - Updating Domain Policies'
Write-Host '  ############################' -Fore Yellow
Write-Host ' # Updating Domain Policies #' -Fore Yellow
Write-Host '############################' `r`n -Fore Yellow

Write-Progress -id 1 -Activity Running -Status 'Progress' -PercentComplete 80

Try
{
    Start-Process gpupdate.exe /force -WindowStyle Hidden -WorkingDirectory "$env:windir" -ErrorAction Stop -Wait
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Host 'ERROR: Updating Domain Policies' `r`n -Fore Red
    Write-EventLog -LogName 'Application' -Source 'EventSystem' -EntryType Error -EventId 500 -Message "Error Updating Domain Policies. The error message was $ErrorMessage"
}
Finally
{
    Write-Host 'Domain Policies Update Finished' `r`n -Fore Green
    Write-EventLog -LogName 'Application' -Source 'EventSystem' -EntryType Information -EventId 400 -Message 'Logon Script - Domain Policies Update Finished'
}

# =============
# ENDING SCRIPT
# =============

Start-Sleep -Seconds 1
Write-Progress -id 1 -Activity Running -Status 'Progress' -PercentComplete 100
exit