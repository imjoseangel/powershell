################################################################################################################################################################
# Script accepts 2 parameters from the command line
#
# Office365Username - Mandatory - Administrator login ID for the tenant we are querying
# Office365Password - Mandatory - Administrator login password for the tenant we are querying
#
#
# To run the script
#
# .\Get-DistributionGroupMembers.ps1 -Office365Username admin@xxxxxx.onmicrosoft.com -Office365Password Password123 
#
#
# Author: 				Alan Byrne
# Version: 				1.0
# Last Modified Date: 	10/10/2012
# Last Modified By: 	Alan Byrne
################################################################################################################################################################

#Accept input parameters
Param(
	[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
    [string] $Office365Username,
	[Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
    [string] $Office365Password
)

#Constant Variables
$OutputFile = "DistributionGroupMembers.csv"   #The CSV Output file that is created, change for your purposes
$arrDLMembers = @{}

#Main
Function Main {

	#Remove all existing Powershell sessions
	Get-PSSession | Remove-PSSession
	
	#Call ConnectTo-ExchangeOnline function with correct credentials
	ConnectTo-ExchangeOnline -Office365AdminUsername $Office365Username -Office365AdminPassword $Office365Password			
	
	#Prepare Output file with headers
	Out-File -FilePath $OutputFile -InputObject "PrimarySMTPAddress,MemberOf" -Encoding UTF8
	
	#Get all Distribution Groups from Office 365
	$objDistributionGroups = Get-DistributionGroup -ResultSize Unlimited
	
	#Iterate through all groups, one at a time	
	Foreach ($objDistributionGroup in $objDistributionGroups)
	{	
		
		write-host "Processing $($objDistributionGroup.DisplayName)..."
	
		#Get members of this group
		$objDGMembers = Get-DistributionGroupMember -Identity $($objDistributionGroup.PrimarySmtpAddress)
		
		write-host "Found $($objDGMembers.Count) members..."
		
		#Iterate through each member
		Foreach ($objMember in $objDGMembers)
		{
			write-host "Processing member: $($objMember.PrimarySmtpAddress)"
			
			#If it is a nested DG, ignore it
			if ($($objMember.RecipientType) -like "*DistributionGroup*")
			{
				write-host "`tMember is another DL"
			}
			else
			{
				write-host "`tMember is a user..."
						
				#See if we already have this member in our hash table
				if($arrDLMembers.ContainsKey($objMember.PrimarySMTPAddress))
				{
					#We have this person already, so we append this DG to their list
					write-host "`tUser IS already in our array..."
					$arrDLMembers[$($objMember.PrimarySMTPAddress)] += ";$($objDistributionGroup.DisplayName)"
				}
				else											  
				{
					#This is a new user, add them to the hash table
					write-host "`tUser IS NOT already in our array..."
					$arrDLMembers.Add($($objMember.PrimarySMTPAddress), $($objDistributionGroup.DisplayName))
				}
			}
		}
	}
	
	#Write the data to file
	foreach ($User in $arrDLMembers.keys)
	{
		Out-File -FilePath $OutputFile -InputObject "$User,$($arrDLMembers.$User)" -Encoding UTF8 -append
		write-host "$User,$($arrDLMembers.$User)"
	}
	
	#Clean up session
	Get-PSSession | Remove-PSSession
}

###############################################################################
#
# Function ConnectTo-ExchangeOnline
#
# PURPOSE
#    Connects to Exchange Online Remote PowerShell using the tenant credentials
#
# INPUT
#    Tenant Admin username and password.
#
# RETURN
#    None.
#
###############################################################################
function ConnectTo-ExchangeOnline
{   
	Param( 
		[Parameter(
		Mandatory=$true,
		Position=0)]
		[String]$Office365AdminUsername,
		[Parameter(
		Mandatory=$true,
		Position=1)]
		[String]$Office365AdminPassword

    )
		
	#Encrypt password for transmission to Office365
	$SecureOffice365Password = ConvertTo-SecureString -AsPlainText $Office365AdminPassword -Force    
	
	#Build credentials object
	$Office365Credentials  = New-Object System.Management.Automation.PSCredential $Office365AdminUsername, $SecureOffice365Password
	
	#Create remote Powershell session
	$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $Office365credentials -Authentication Basic –AllowRedirection    	

	#Import the session
    Import-PSSession $Session -AllowClobber | Out-Null
}


# Start script
. Main