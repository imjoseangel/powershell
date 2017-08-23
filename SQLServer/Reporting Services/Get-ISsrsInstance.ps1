<#
	.SYNOPSIS
		Get-ISsrsInstance
	.DESCRIPTION
		Retrieve SQL Server Reporting Service Instance information using WMI
	.PARAMETER computer
		Computer name
	.EXAMPLE
		.\Get-ISsrsInstance -computer Server01
	.INPUTS
	.OUTPUTS
		Instance Properties
	.NOTES
	.LINK
#>

param
(
	[string]$serverInstance = "$(Read-Host 'Server Instance' [e.g. server01\sql2012])"
)

begin {
	[void][reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
}
process {
	try {
		Write-Verbose "Retrieve SQL Server Reporting Service Instance information using WMI..."

		$serverName = $serverInstance.Split("\")[0]
		if ($serverInstance.Contains("\")) {
			$instance = $serverInstance.Split("\")[1]
		} else {
			$instance = "MSSQLSERVER"
		}

		$smoServer = new-object Microsoft.SqlServer.Management.Smo.Server $serverInstance
		$ver = $smoServer.Information.VersionMajor 

		$isSQLSupported = $false
		if ($ver -eq 9) {
			$namespace = 'root\Microsoft\SqlServer\ReportServer\v9'
			$isSQLSupported = $true
		} elseif ($ver -eq 10) {
			$namespace = 'root\Microsoft\SqlServer\ReportServer\RS_' + $instance + '\v10'
			$isSQLSupported = $true
		} elseif ($ver -eq 11) {
			$namespace = 'root\Microsoft\SqlServer\ReportServer\RS_' + $instance + '\v11'
			$isSQLSupported = $true
		} elseif ($ver -eq 12) {
			$namespace = 'root\Microsoft\SqlServer\ReportServer\RS_' + $instance + '\v12'
			$isSQLSupported = $true
		} elseif ($ver -eq 13) {
			$namespace = 'root\Microsoft\SqlServer\ReportServer\RS_' + $instance + '\v13'
			$isSQLSupported = $true
		}

		# Create a WMI namespace for SQL Server
		if ($isSQLSupported) {
			$SSRSInstances = Get-WmiObject -Class MSReportServer_Instance -Namespace $namespace -ComputerName $serverName
		} else {
			Write-Error "SQL Server version not supported"
		}
		
		Write-Output $SSRSInstances
	}
	catch [Exception] {
		Write-Error $Error[0]
		$err = $_.Exception
		while ( $err.InnerException ) {
			$err = $err.InnerException
			Write-Output $err.Message
		}
	}
}