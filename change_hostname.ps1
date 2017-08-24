$NewName=$Computer
$ComputerInfo = Get-WmiObject -Class Win32_ComputerSystem
$ComputerInfo.Rename($NewName)
Restart-Computer