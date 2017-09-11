$computersToQuery = ("aqntec01","aqntec08","aqntec02")

$softwareInventory = @{}
foreach ($computer in $computersToQuery) {
   $psinfoOutput = ./psinfo.exe -s Applications \\$computer

   $foundSoftwareInventory = 0
   $computerName = ""
   foreach ($item in $psinfoOutput) {
      if ($foundSoftwareInventory -eq 1) {
         # Force the results to a string
         # Remove any single quotes which interfere with T-SQL statements
         # Load the result into a hash whereby removing any duplicates
         [string]$softwareInventory[$computerName][$item.Replace("'","")] = ""
      }

      if ($item -like "System information for *") {
         $computerName = $item.Split("\")[2].TrimEnd(":")
      } elseif ($item -eq "Applications:") {
         $foundSoftwareInventory = 1
         $softwareInventory[$computerName] = @{}
      }
   }
}

foreach ($computer in $softwareInventory.Keys) {
   foreach ($softwareItem in $softwareInventory[$computer].Keys) {
      $computer + ":" + $softwareItem
   }
}