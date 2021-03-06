Function Get-PowershellRelease {
    #Using this to get rid of the nasty output Invoke-WebRequest gives you in PowerShell
    $progress = $ProgressPreference
    $ProgressPreference = "SilentlyContinue"
    $JSON = Invoke-WebRequest "https://api.github.com/repos/powershell/powershell/releases"
    If ($psversiontable.GitCommitId) {
        If ($JSON.tag_name -ne $psversiontable.GitCommitId) {
            Write-Output "New version of PowerShell available!"
            $JSON.body
        } Else {
            "Powershell is currently up to date!"
        }
        $ProgressPreference = $progress
    }
}
