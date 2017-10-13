$apps = get-webapplication


foreach($app in $apps)
{
$application=$app.Attributes[1].Value;
$siteName = (Get-WebApplication -name $application).GetParentElement()['name']

write-output ("Application $application belongs to site $sitename")
$hostname=hostname

$data= @"
$hostname, $sitename, $application
"@ 

$data | add-content c:\temp\csvdata3.csv
}


Then run the following script that will invoke the previous

$computers="Computer1", "Computer2"
foreach ($computer in $computers){
Invoke-Command -FilePath "$pwdScript.ps1" -ComputerName $computer


$csvdata= invoke-command -computername $computer {get-content c:\temp\csvdata3.csv}

$csvdata | add-content c:\temp\csvdatanew.csv}
