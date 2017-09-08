# Code from http://sharepointjack.com/

ADD-TYPE -AssemblyName System.Speech
$speak = new-object System.Speech.Synthesis.SpeechSynthesizer
$speak.speakAsync("Hello from powershell!") > null
 
 
 
#Example use in real world code..
 
#Loop through 1000 users
foreach ($userId in $massiveListOfUsers)
{
    $result = Check-user -id $userId
    if ($result -eq $false)
    {
         write-host "OH NO THIS USER IS MISSING"
         write-host $userId
         $speak.speakAsync("Can't find $($userId.FirstName) $($userId.LastName)") > $null
    }
}
