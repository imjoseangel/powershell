# Read-host -assecurestring | convertfrom-securestring | out-file C:\cred.txt
$password = Get-Content C:\cred.txt | ConvertTo-SecureString
$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist "AQUANIMA\Administrator",$password
$wmiOS = Get-WmiObject -Class Win32_OperatingSystem -Credential $credential -ComputerName $server
$server = $args[0]
$wmiOS = Get-WmiObject Win32_OperatingSystem -Credential $credential -ComputerName $server                                                                                                                      
$OS = $wmiOS.caption                                                                                                                                                                                            
Write-Host -Fore Red $server "- " -NoNewline; Write-Host -Fore YELLOW $OS