#=======================================================================#
#
# Author:                Collin Chaffin
# Last Modified:        11/01/2014 10:00 PM
# Filename:                SyncADDomain.psm1
#
#
# Changelog:
#
#    v 1.0.0.1    :    11/01/2014    :    Initial release
#
# Notes:
#
#    This module emulates the repadmin /syncall to force AD replication
#    across all sites and domain controllers.  At the time I wrote this I
#    could not find any example or suitable replacement to calling the
#    repadmin binary
#
#=======================================================================#

function Sync-ADDomain
{
    <#
        .SYNOPSIS
            Emulates the repadmin /syncall to force AD replication

        .DESCRIPTION
            Author:          Collin Chaffin
            Description:    This function emulates the repadmin /syncall to
                            force AD replication across all sites and domain
                            controllers.  At the time I wrote this I could not
                            find any example or suitable replacement to calling
                            the repadmin binary

        .EXAMPLE
            C:\> Sync-ADDomain
            Forcing Replication on WIN2008R2-DC1.lab.local
            Forcing Replication on WIN2008R2-DC2.lab.local
            Forcing Replication on WIN2008R2-DC3.lab.local

        .EXAMPLE
            C:\> Sync-ADDomain -WhatIf
            What if: Performing operation "Forcing Replication" on Target "WIN2008R2-DC1.lab.local".
            What if: Performing operation "Forcing Replication" on Target "WIN2008R2-DC2.lab.local".
            What if: Performing operation "Forcing Replication" on Target "WIN2008R2-DC3.lab.local".
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
    )
    BEGIN
    {
        Write-Debug "Sync-ADDomain function started."

        try
        {
            # Set up the AD object and retrieve operator's current AD domain
            $adDomain = $env:userdnsdomain
            Write-Debug "Detected operators AD domain as $($adDomain)"
            $objADContext = new-object System.DirectoryServices.ActiveDirectory.DirectoryContext("Domain", $adDomain)
            $domainControllers = [System.DirectoryServices.ActiveDirectory.DomainController]::findall($objADContext)
        }
        catch
        {
            #Throw terminating error
            Throw $("ERROR OCCURRED DETERMINING USERDNSDOMAIN AND RETRIEVING LIST OF DOMAIN CONTROLLERS " + $_.Exception.Message)
        }
    }
    PROCESS
    {

        try
        {
            # Cycle through all domain controllers emulating a repadmin /syncall
            foreach ($domainController in $domainControllers)
            {
                if ($PSCmdlet.ShouldProcess($domainController,"Forcing Replication"))
                {
                    Write-Host "Forcing Replication on $domainController" -ForegroundColor Cyan
                    $domainController.SyncReplicaFromAllServers(([ADSI]"").distinguishedName,'CrossSite')
                }
            }
        }
        catch
        {
            #Throw terminating error
            Throw $("ERROR OCCURRED FORCING DIRECTORY SYNCHRONIZATION " + $_.Exception.Message)
        }

    }
    END
    {
        Write-Debug "Sync-ADDomain function completed successfully."
    }
}

Sync-ADDomain
