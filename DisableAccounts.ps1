# DisableAccounts
# Disables all accounts that have today's date in the description field

# include AD library
Add-PSSnapin Quest.Activeroles.ADManagement

# True if the parameter date is today
function isToday ([datetime]$date) {
	[datetime]::Now.Date -eq  $date.Date
}

# Get all AD Users
$Users = get-QADUser 

# Loop through all users
$Users | ForEach { 
            # Only the users in the "Disabled" OUs
            if ( select-string -inputObject $_.parentContainer -pattern "Disabled" ) {  
                # Only the users with description date
                if ( $_.description.length -gt 1 ) {
					$DisableDate = [datetime]$_.description
					if ( isToday $DisableDate ) { Disable-QADUser $_.samAccountName } 
                }
            }
         } 