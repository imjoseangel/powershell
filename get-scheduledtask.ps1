Function Get-ScheduledTaskInfo
{	<#
	.Synopsis
	Quickly retrieve information about scheduled tasks
	.Description
	This function is designed to retrieve scheduled task information.  There is a parameter
	for accepting comma seperated server names or you can use the pipeline.  
	
	The pipeline only accepts a single field for input, so if you try to use Get-ADComputer you
	must make sure that you only pass on the Name field via the pipeline.  See Examples below.
	.Parameter ComputerNames
	Accepts an array of computer names.  Arrays are simply a list of names seperated by commas.
	Default value is set to read from a text file.  You will need to update the line:
	
	[array]$ComputerNames = $(Get-Content c:\utils\servers.txt)
	
	To match your environment and location of your file.
	.Example
	Get-ScheduledTaskInfo
	Will read the contents of c:\utils\servers.txt and retrieve all scheduled tasks from those
	computers.
	.Example
	Get-ScheduledTaskInfo -ComputerNames server1,server2,server3
	Will retrieve all scheduled tasks from server1, server2 and server3.
	.Example
	Get-ADComputer -Filter WS* | % {$_.Name} | Get-ScheduledTaskInfo
	You must have RSAT installed for this to work.  
	Will retrieve from Active Directory every computer whose name starts with "WS", pipe that into
	a ForEach and retrieve just the Name field and then pipe into Get-ScheduledTaskInfo.  This will
	in turn retrieve every task for every computer that starts with "WS" in your domain.
	
	** Be Careful ** While this won't cause any harm, it could take a long time depending on how many 
	machines you have that fit the filter parameters you specify.
	.Example
	Get-ScheduledTaskInfo | where { $_.Author -notlike "*Microsoft*" } | Out-Gridview
	Use Where to filter the return from Get-ScheduledTaskInfo.  This example will pull the contents of 
	c:\util\serverts.txt and pull all Non-Microsoft tasks and put it into a nice, searchable grid
	Window.
	.Link
	http://community.spiceworks.com/scripts/show/1586-get-scheduled-task-info
	#>
	Param(
		[array]$ComputerNames = $(Get-Content c:\utils\servers.txt)  #change this to fit your environment
	)
	Begin
	{	$Result = @()
	}
	Process
	{	If ($_)		#If pipeline information exists, use that
		{	$ComputerNames = $_
		}
		ForEach ($Computer in $ComputerNames)
		{	If (Test-Connection $Computer -Quiet)    #check if the computer is available
			{	$Result += schtasks.exe /query /s $Computer /V /FO CSV | ConvertFrom-Csv | Where { $_.TaskName -ne "TaskName" }
			}
		}
	}
	End
	{	Return $Result
	}
}
