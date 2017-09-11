

#------------------------------------------------------------------------------
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR 
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
#
# AUTHOR(s):
#     Eyal Doron (o365info.com)
#------------------------------------------------------------------------------
# Hope that you enjoy it ! 
# And May the force of PowerShell will be with you   :-)
# 07-2013    
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
$FormatEnumerationLimit = -1

#------------------------------------------------------------------------------
#$GM01 = Get-Mailbox -ResultSize Unlimited 
#$GM02 = Get-Mailbox -ResultSize Unlimited -Filter {(RecipientTypeDetails -eq 'UserMailbox')}
#------------------------------------------------------------------------------
# PowerShell console window Style
#------------------------------------------------------------------------------
$pshost = get-host
$pswindow = $pshost.ui.rawui

$newsize = $pswindow.buffersize
$newsize.height = 3000
$newsize.width = 150
$pswindow.buffersize = $newsize

$newsize = $pswindow.windowsize
$newsize.height = 50
$newsize.width = 150
$pswindow.windowsize = $newsize

#------------------------------------------------------------------------------
# HTML Style
#------------------------------------------------------------------------------

$htstyle = '<style>'
$htstyle = $htstyle + “body{font-family:segoe ui,arial;color:black; }” 
$htstyle = $htstyle + “H1{ color: white; background-color:#385623; font-weight:bold;width: 795px;margin-top:35px;margin-bottom:25px;font-size: 22px;padding:5px 15px 5px 10px; }” 
$htstyle = $htstyle + “table{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}” 
$htstyle = $htstyle + “th{border-width: 1px;padding: 5px;border-style: solid;border-color: #d1d3d4;background-color:#0072c6 ;color:white;}” 
$htstyle = $htstyle + “td{border-width: 1px;padding: 5px;border-style: solid;border-color: #d1d3d4;background-color:white}” 
$htstyle = $htstyle + “</style>” 

#------------------------------------------------------------------------------

#+++++++++++++++++++++++++++++++++++++++++++++++++++++
#   Retention Policy + Deleted items policy Script    
#+++++++++++++++++++++++++++++++++++++++++++++++++++++

clear-host

$Loop = $true
While ($Loop)
{
write-host 
write-host  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -ForegroundColor Magenta
write-host      Retention Policy + Deleted items policy Script           -ForegroundColor Yellow
write-host  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -ForegroundColor Magenta
write-host 
write-host '    Create Remote PowerShell session to Office 365 and Exchange online' -ForegroundColor green
write-host '    --------------------------------------------------------------' -ForegroundColor green
write-host '0)  Login to Office 365 and Exchange online' -ForegroundColor Yellow
write-host
write-host '    Section A:  Apply Retention Policy ' -ForegroundColor green
write-host '    --------------------------------------------------------------' -ForegroundColor green
write-host "1)  Apply Retention policy for a Mailbox - Choose the Retention Policy  "
write-host "2)  Apply Default Retention policy for a Mailbox "
write-host "3)  Apply the Default Retention Policy to ALL office 365 Mailboxes (BULK Mode) "
write-host
write-host '    Section B:  Remove Retention Policy ' -ForegroundColor green
write-host '    --------------------------------------------------------------' -ForegroundColor green
write-host "4)  Remove Retention Policy for a Mailbox (set to NULL)  "
write-host "5)  Remove Retention Policy for a Mailbox  Retention policy to ALL office 365 users Mailboxes (BULK Mode) "
write-host
write-host '    Section C: Display Retention Policy ' -ForegroundColor green
write-host '    --------------------------------------------------------------' -ForegroundColor green
write-host "6)  Display the Retention Policy applied to a user Mailbox "
write-host "7)  Display the Retention Policy applied to all Office 365 users Mailboxes "
write-host
write-host '    Section D: Default Retention Policy Tags settings' -ForegroundColor green
write-host '    --------------------------------------------------------------' -ForegroundColor green
write-host "8)  Set the number of days for Deleted items Tag "
write-host "9)  Disable Deleted items Tag "
write-host "10) Set the number of days for Junk Email Tag "
write-host
write-host '    Section E: create NEW Retention Policy Tags ' -ForegroundColor green
write-host '    --------------------------------------------------------------' -ForegroundColor green
write-host "11)  Create NEW tag for Sync Issues Folder "
write-host
write-host '    Section F: Managed Folder Assistant' -ForegroundColor green
write-host '    --------------------------------------------------------------' -ForegroundColor green
write-host "12) Run the Managed Folder Assistant for a specific Mailbox  "
write-host "13) Run the Managed Folder Assistant for all office 365 Mailboxes (BULK Mode)  "
write-host
write-host
write-host '    Section G: Managed Deleted items policy' -ForegroundColor green
write-host '    --------------------------------------------------------------' -ForegroundColor green
write-host '14) Set Deleted items policy for 30 days for spesfic user'
write-host '15) Set Deleted items policy for 30 days for ALL user (BULK)'
write-host '16) Display information about Deleted items policy for spesfic user'
write-host '17) Display information about Deleted items policy for ALL users '
write-host
write-host
write-host '    Section H:  Export data' -ForegroundColor green
write-host '    --------------------------------------------------------------' -ForegroundColor green
write-host '18) Export data about Retention policy'
write-host '19) Export data about Deleted items policy'
write-host
write-host '    --------------------------------------------------------------' -ForegroundColor green
write-host "20) Disconnect the Current PowerShell session" -ForegroundColor Red
write-host
write-host "21) Exit" -ForegroundColor Red
write-host

$opt = Read-Host "Select an option [0-21]"
write-host $opt
switch ($opt) 

{

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Step -00 Create a Remote PowerShell session to: Office 365 and Exchange online
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



0{

#Section 1: PowerShell Command


#——– Global Admin credentials ———————

$user = “admin@<your domain>.OnMicrosoft.com”

#——– Display authentication pop out windows ———————

$cred = Get-Credential -Credential $user

#——– Import office 365 Cmdlets  ———–

Import-Module MSOnline

#———— Establish Remote PowerShell Session to: office 365 ———————

Connect-MsolService -Credential $cred

#———— Establish Remote PowerShell Session to: Exchange Online ———————

$msoExchangeURL = “https://ps.outlook.com/powershell/”
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $cred -Authentication Basic -AllowRedirection 

#———— Create implicit remoting: import Exchange Online PowerShell cmdlets ———————

Import-PSSession $session


#Section 2:  Indication 

write-host 
if ($lastexitcode -eq 1)
{
	
write-host -ForegroundColor red "The command Failed :-(" 
write-host -ForegroundColor red "Try to connect again and check:" 
write-host -ForegroundColor red "1.Your credentials" 
write-host -ForegroundColor red "2.If the Office365 cmdlets installed " 
write-host -ForegroundColor red "3.The user name that you use have Global administrator Credentials " 
	
}
else

{
	
clear-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white  	"The command complete successfully !" 
write-host  -ForegroundColor white  	"You are now connected to office 365 and Exchange online"
write-host  -ForegroundColor white	    --------------------------------------------------------------------   
write-host  -ForegroundColor white  	"To activate a specific menu, type the menu number "
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                        
write-host
write-host
}

#———— End of Indication ———————

}


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Section A:  Apply Retention policy
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


1{


#####################################################################
# Apply Retention policy for a Mailbox - Choose the Retention Policy 
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Apply the Retention Policy that you choose for a Mailbox. '
write-host  -ForegroundColor white		--------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Set-Mailbox <Mailbox> -RetentionPolicy <Policy Name> '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host



# Section 2: user input



write-host -ForegroundColor Yellow	"You will need to Provide 2 parameters:"  
write-host
write-host -ForegroundColor Yellow	"Type the name the recipent Alias"  
write-host -ForegroundColor Yellow	"For example: John"
write-host
$Alias = Read-Host "Type the name the recipent Alias "
write-host
write-host
write-host
write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	List of existing Retention Policys
write-host ---------------------------------------------------------------------------

Get-RetentionPolicy | fl Name   | out-string

write-host ---------------------------------------------------------------------------
write-host
write-host -ForegroundColor Yellow	"2) Retention Policy name"  
write-host -ForegroundColor Yellow	"   For example: VIP Users"
write-host
$Rpolicy = Read-Host "Type the Retention Policy name "
write-host
write-host


# Section 3: PowerShell Command

Set-Mailbox $Alias -RetentionPolicy "$Rpolicy" 


# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"The Retention Policy named: " -nonewline; write-host "$Rpolicy".ToUpper() -ForegroundColor White 
write-host -ForegroundColor Yellow	"Is applied to: " -nonewline; write-host "$Alias".ToUpper() -ForegroundColor White -nonewline; write-host -ForegroundColor Yellow	" Mailbox"	  
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information

write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display information about the Retention Policy for: "$Alias".ToUpper() Mailbox
write-host ---------------------------------------------------------------------------

Get-Mailbox "$Alias" | fl RetentionPolicy  | out-string

write-host ---------------------------------------------------------------------------


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}




2{


#####################################################################
#  Apply Default Retention policy for a Mailbox
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Apply the default Retention Policy for a Mailbox '
write-host  -ForegroundColor white		--------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Set-Mailbox <Alias> -RetentionPolicy "Default MRM Policy" '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input


write-host -ForegroundColor Yellow	"You will need to Provide 1 parameter:"  
write-host
write-host -ForegroundColor Yellow	"Type the name the recipent Alias"  
write-host -ForegroundColor Yellow	"For example: John"
write-host
$Alias = Read-Host "Type the name the recipent Alias "
write-host


# Section 3: PowerShell Command

Set-Mailbox $Alias -RetentionPolicy "Default MRM Policy" 

# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"The Default Retention Policy (Default MRM Policy) is applied to: " -nonewline; write-host "$Alias".ToUpper() -ForegroundColor White -nonewline; write-host -ForegroundColor Yellow	" Mailbox"
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information

write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display information about the Retention Policy for: "$Alias".ToUpper() Mailbox
write-host ---------------------------------------------------------------------------

Get-Mailbox $Alias | fl RetentionPolicy  | out-string


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}



3{


#####################################################################
# Apply the Default Retention Policy to ALL office 365 Mailboxs (BULK Mode)
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Apply the Default Retention Policy to ALL office 365 Mailboxs (BULK Mode). '
write-host  -ForegroundColor white		--------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use are: '
write-host  -ForegroundColor Yellow  	'$UserMailboxes = Get-mailbox -Filter {(RecipientTypeDetails -eq 'UserMailbox')} '
write-host  -ForegroundColor Yellow  	'$UserMailboxes | Set-Mailbox –RetentionPolicy "Default MRM Policy" '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input



# Section 3: PowerShell Command

$UserMailboxes = Get-mailbox -Filter {(RecipientTypeDetails -eq 'UserMailbox')}
$UserMailboxes | Set-Mailbox –RetentionPolicy "Default MRM Policy"


$UserMailboxes = Get-mailbox -Filter {(RecipientTypeDetails -eq 'UserMailbox')}
$UserMailboxes | ForEach {Start-ManagedFolderAssistant $_.Identity}


# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"The Retention Policy named: " -nonewline; write-host "Default MRM Policy".ToUpper() -ForegroundColor White 
write-host -ForegroundColor Yellow	"Is applied to: ALL office 365 Mailboxs  " 
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information

write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display information about Retention Policy to ALL office 365 Mailboxs
write-host ---------------------------------------------------------------------------

Get-Mailbox -ResultSize Unlimited | where {$_.name -notlike '*DiscoverySearchMailbox*'} | select Alias, RetentionPolicy | out-string

write-host ---------------------------------------------------------------------------


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}





#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Section B:  Remove Retention policy
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


4{


#####################################################################
# Remove Retention Policy for a Mailbox (set to NULL)
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Remove Retention Policy for a Mailbox (set to NULL). '
write-host  -ForegroundColor white		--------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Set-Mailbox <Alias> -RetentionPolicy $null '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host

# Section 2: user input

write-host
write-host -ForegroundColor Yellow	"Type the name the recipent Alias"  
write-host -ForegroundColor Yellow	"For example: John"
write-host
$Alias = Read-Host "Type the name the recipent Alias "
write-host


# Section 3: PowerShell Command

Set-Mailbox $Alias -RetentionPolicy $null


# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"The Retention Policy for: " -nonewline; write-host "$Alias".ToUpper() -ForegroundColor White 
write-host -ForegroundColor Yellow	"Was set to NULL " 
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information

write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display information about the Retention Policy for: "$UserAlias".ToUpper() Mailbox
write-host ---------------------------------------------------------------------------

Get-Mailbox "$UserAlias" | fl RetentionPolicy  | out-string

write-host ---------------------------------------------------------------------------


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}



5{


#####################################################################
#Remove Retention Policy for a Mailbox  Retention policy to ALL office 365 Mailboxs (BULK Mode)
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Remove Retention Policy for ALL Office 365 Mailboxs (set to NULL). '
write-host  -ForegroundColor white		--------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use are: '
write-host  -ForegroundColor Yellow  	'$UserMailboxes = Get-mailbox -Filter {(RecipientTypeDetails -eq 'UserMailbox')} '
write-host  -ForegroundColor Yellow  	'$UserMailboxes | Set-Mailbox –RetentionPolicy $null ' 
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host



# Section 2: user input



# Section 3: PowerShell Command

$UserMailboxes = Get-mailbox -Filter {(RecipientTypeDetails -eq 'UserMailbox')}
$UserMailboxes | Set-Mailbox –RetentionPolicy $null


$UserMailboxes = Get-mailbox -Filter {(RecipientTypeDetails -eq 'UserMailbox')}
$UserMailboxes | ForEach {Start-ManagedFolderAssistant $_.Identity}


# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"The Retention Policy for ALL Office 365 user Mailboxes: " 
write-host -ForegroundColor Yellow	"Was set to NULL " 
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information

write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display information about Retention Policy to ALL office 365 Mailboxs
write-host ---------------------------------------------------------------------------

Get-Mailbox -ResultSize Unlimited | where {$_.name -notlike '*DiscoverySearchMailbox*'} | select Alias, RetentionPolicy | out-string

write-host ---------------------------------------------------------------------------


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}





#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#  Section C: Display Retention Policy
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




6{


#####################################################################
# Display the Retention Policy applied to a User Mailbox 
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Display the Retention Policy applied to a user Mailbox. '
write-host  -ForegroundColor white		--------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Get-Mailbox <Alias> | fl RetentionPolicy '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host



# Section 2: user input



write-host
write-host -ForegroundColor Yellow	"Type the name the recipent Alias"  
write-host -ForegroundColor Yellow	"For example: John"
write-host
$Alias = Read-Host "Type the name the recipent Alias "
write-host


# Section 3: PowerShell Command


# Section 4:  Indication 


# Section 4: Display Information

write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display information about the Retention Policy for: "$Alias".ToUpper() Mailbox
write-host ---------------------------------------------------------------------------

Get-Mailbox $Alias | fl RetentionPolicy  | out-string

write-host ---------------------------------------------------------------------------


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}







7{


#####################################################################
#Display the Retention Policy applied to all Office 365 users Mailboxs
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Display the Retention Policy applied to all Office 365 users Mailboxs. '
write-host  -ForegroundColor white		--------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use are: '
write-host  -ForegroundColor Yellow  	'Get-Mailbox -ResultSize Unlimited | where {$_.name -notlike '*DiscoverySearchMailbox*'} | select Alias, RetentionPolicy '
write-host  
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host



# Section 2: user input



# Section 3: PowerShell Command


# Section 4:  Indication 


# Section 4: Display Information

write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display information about Retention Policy to ALL office 365 Mailboxs
write-host ---------------------------------------------------------------------------

Get-Mailbox -ResultSize Unlimited | where {$_.name -notlike '*DiscoverySearchMailbox*'} | select Alias, RetentionPolicy | out-string

write-host ---------------------------------------------------------------------------


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}




#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Section D: Default Retention Policy Tags settings
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



8{


#####################################################################
# Set the number of days for Deleted items Tag
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Set the number of days for Deleted items Tag '
write-host  -ForegroundColor white  	'The default value for Deleted items tag: 30 Days '
write-host  -ForegroundColor white  	'(Additional PowerShell command will run the Managed Folder Assistant) '
write-host  -ForegroundColor white		--------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Set-RetentionPolicyTag "Deleted Items" -AgeLimitForRetention <Days> '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input


write-host -ForegroundColor Yellow	"You will need to Provide 1 parameter:"  
write-host
write-host -ForegroundColor Yellow	"1) Number of days"  
write-host -ForegroundColor Yellow	"   For example: 120"
write-host
$days = Read-Host "Type the Number of days "


# Section 3: PowerShell Command

Set-RetentionPolicyTag "Deleted Items" -AgeLimitForRetention $days

# Set-RetentionPolicyTag "Deleted Items" -AgeLimitForRetention <Days>

$UserMailboxes = Get-mailbox -Filter {(RecipientTypeDetails -eq 'UserMailbox')}
$UserMailboxes | ForEach {Start-ManagedFolderAssistant $_.Identity}




# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"Deleted items Tag is: " -nonewline; write-host "$days".ToUpper() -ForegroundColor White -nonewline; write-host -ForegroundColor Yellow	" Days"
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information

write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display information about Deleted items Tag
write-host ---------------------------------------------------------------------------

Get-RetentionPolicyTag  "Deleted Items"   | fl Name , Type, Description , AgeLimitForRetention  | out-string


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}




9{


#####################################################################
# Disable Deleted items Tag
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Disable Deleted items Tag '
write-host  -ForegroundColor white  	'(Additional PowerShell command will run the Managed Folder Assistant) '
write-host  -ForegroundColor white		--------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Set-RetentionPolicyTag "Deleted Items" -RetentionEnabled $false '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input



# Section 3: PowerShell Command

Set-RetentionPolicyTag "Deleted Items" -RetentionEnabled $false
 


$UserMailboxes = Get-mailbox -Filter {(RecipientTypeDetails -eq 'UserMailbox')}
$UserMailboxes | ForEach {Start-ManagedFolderAssistant $_.Identity}




# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"Deleted items Tag is Disabled " 
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information

write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display information about Deleted items Tag
write-host ---------------------------------------------------------------------------

Get-RetentionPolicyTag  "Deleted Items"   | fl Name , Type, Description , AgeLimitForRetention ,RetentionEnabled | out-string


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}




10{


#####################################################################
# Set the number of days for Junk Email Tag
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Set the number of days for Junk Email Tag '
write-host  -ForegroundColor white  	'The default value for Deleted items tag: 30 Days '
write-host  -ForegroundColor white  	'(Additional PowerShell command will run the Managed Folder Assistant) '
write-host  -ForegroundColor white		--------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Set-RetentionPolicyTag "Junk Email" -AgeLimitForRetention <Days> '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input


write-host -ForegroundColor Yellow	"You will need to Provide 1 parameter:"  
write-host
write-host -ForegroundColor Yellow	"1) Number of days"  
write-host -ForegroundColor Yellow	"   For example: 120"
write-host
$days = Read-Host "Type the Number of days "


# Section 3: PowerShell Command

Set-RetentionPolicyTag "Junk Email" -AgeLimitForRetention $days

# Set-RetentionPolicyTag "Junk Email" -AgeLimitForRetention <Days>

$UserMailboxes = Get-mailbox -Filter {(RecipientTypeDetails -eq 'UserMailbox')}
$UserMailboxes | ForEach {Start-ManagedFolderAssistant $_.Identity}


# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"Deleted items Tag is: " -nonewline; write-host "$days".ToUpper() -ForegroundColor White -nonewline; write-host -ForegroundColor Yellow	" Days"
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information

write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display information about Deleted items Tag
write-host ---------------------------------------------------------------------------

Get-RetentionPolicyTag  "Deleted Items"   | fl Name , Type, Description , AgeLimitForRetention  | out-string


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}



#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Section E: create NEW Retention Policy Tags
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<





11{


#####################################################################
# Create NEW tag for Sync Issues Folder
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Create NEW tag for Sync Issues Folder '
write-host  -ForegroundColor white  	'Set the Number of Days Value: 30 Days '
write-host  -ForegroundColor white  	'(Additional PowerShell command will run the Managed Folder Assistant) '
write-host  -ForegroundColor white		--------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'New-RetentionPolicyTag -Name <Tag name> -Type 'SyncIssues' -AgeLimitForRetention <days> -RetentionAction 'DeleteAndAllowRecovery' -RetentionEnabled $true '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input


write-host -ForegroundColor Yellow	"You will need to Provide 2 parameter:"  
write-host
write-host -ForegroundColor Yellow	"1) The name for the Tag"  
write-host -ForegroundColor Yellow	"   For example: Sync Issues"
write-host
$TagName = Read-Host "Type the name for the Tag "
write-host
write-host -ForegroundColor Yellow	"1) The name for the Tag"  
write-host -ForegroundColor Yellow	"   For example: Sync Issues"
write-host
$days = Read-Host "Type the name for the Tag "

# Section 3: PowerShell Command

New-RetentionPolicyTag -Name $TagName -Type 'SyncIssues' -AgeLimitForRetention $days -RetentionAction 'DeleteAndAllowRecovery' -RetentionEnabled $true


# New-RetentionPolicyTag -Name <Tag name> -Type 'SyncIssues' -AgeLimitForRetention <Days> -RetentionAction 'DeleteAndAllowRecovery' -RetentionEnabled $true

$UserMailboxes = Get-mailbox -Filter {(RecipientTypeDetails -eq 'UserMailbox')}
$UserMailboxes | ForEach {Start-ManagedFolderAssistant $_.Identity}




# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"a new Tag Named: " -nonewline; write-host "$TagName".ToUpper() -ForegroundColor White -nonewline; write-host -ForegroundColor Yellow	" was created"
write-host -ForegroundColor Yellow	"The number of days value is:: " -nonewline; write-host "$days".ToUpper() -ForegroundColor White 
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information



write-host
write-host ---------------------------------------------------------------------------
write-host -ForegroundColor white	Display information about: "$TagName".ToUpper() 
write-host ---------------------------------------------------------------------------

Get-RetentionPolicyTag  $TagName   | fl Name , Type, Description , AgeLimitForRetention  | out-string | out-string

write-host ---------------------------------------------------------------------------



#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}




#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Section F: Managed Folder Assistant
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




12{


#####################################################################
# Run the Managed Folder Assistant for a specific Mailbox
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Run the Managed Folder Assistant for a spesfic Mailbox. '
write-host  -ForegroundColor white  	'The Managed Folder Assistant runs at regular intervals,  '
write-host  -ForegroundColor white  	'And process the Retention settings applied to a Mailbox.  '
write-host  -ForegroundColor white  	'If you change a retention tag or apply a different retention policy to a Mailbox, '
write-host  -ForegroundColor white  	'you can wait for the next scheduled running of the Managed Folder Assistant, '
write-host  -ForegroundColor white  	'or "Activate" the Managed Folder Assistant, '
write-host  -ForegroundColor white  	'for Enforcing the update on the Mailbox.  '
write-host  -ForegroundColor white		--------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Start-ManagedFolderAssistant  <Alias> '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input


write-host
write-host -ForegroundColor Yellow	"Type the name the recipent Alias"  
write-host -ForegroundColor Yellow	"For example: John"
write-host
$Alias = Read-Host "Type the name the recipent Alias "
write-host

# Section 3: PowerShell Command

Start-ManagedFolderAssistant  $Alias




# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"The Managed Folder Assistant run for: " -nonewline; write-host "$Alias".ToUpper() -ForegroundColor White -nonewline; write-host -ForegroundColor Yellow	" Mailbox"
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information



#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}







13{


#####################################################################
#Run the Managed Folder Assistant for all office 365 Mailboxes (BULK Mode)
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Run the Managed Folder Assistant for all office 365 Mailboxs. '
write-host  -ForegroundColor white  	'The Managed Folder Assistant runs at regular intervals,  '
write-host  -ForegroundColor white  	'And process the Retention settings applied to a Mailbox.  '
write-host  -ForegroundColor white  	'If you change a retention tag or apply a different retention policy to a Mailbox, '
write-host  -ForegroundColor white  	'you can wait for the next scheduled running of the Managed Folder Assistant, '
write-host  -ForegroundColor white  	'or "Activate" the Managed Folder Assistant, '
write-host  -ForegroundColor white  	'for Enforcing the update on ALL Office 365 Mailboxs.  '
write-host  -ForegroundColor white		--------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'$UserMailboxes = Get-mailbox -Filter {(RecipientTypeDetails -eq 'UserMailbox')} '
write-host  -ForegroundColor Yellow  	'$UserMailboxes | ForEach {Start-ManagedFolderAssistant $_.Identity} '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host


# Section 2: user input



# Section 3: PowerShell Command

$UserMailboxes = Get-mailbox -Filter {(RecipientTypeDetails -eq 'UserMailbox')}
$UserMailboxes | ForEach {Start-ManagedFolderAssistant $_.Identity}


# Start-ManagedFolderAssistant –Identity <MailBox>



# Section 4:  Indication 

write-host
write-host

if ($lastexitcode -eq 1)
{
	write-host "The command Failed :-(" -ForegroundColor red
}
else
{
write-host -------------------------------------------------------------
write-host -ForegroundColor Yellow	"The command complete successfully !" 
write-host
write-host -ForegroundColor Yellow	"The Managed Folder Assistant run for all office 365 Mailboxes (BULK Mode) " 
write-host -------------------------------------------------------------
}

#———— End of Indication ———————

# Section 4: Display Information



#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}






#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Section G:  Deleted items policy
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



14{


#####################################################################
#   Set Deleted items policy for 30 days for specific user
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Set Deleted items policy for 30 days for spesfic user  '

write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Get-Mailbox <Alias> |Set-Mailbox -SingleItemRecoveryEnabled $True -RetainDeletedItemsFor 30  '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host
write-host
write-host

# Section 2: user input


write-host
write-host -ForegroundColor Yellow	"Type the name the recipent Alias"  
write-host -ForegroundColor Yellow	"For example: John"
write-host
$Alias = Read-Host "Type the name the recipent Alias "
write-host


# Step 1 : Display information before change


# Section 3: PowerShell Command

write-host
write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	Display information about Deleted items policy for: "$Alias".ToUpper() Mailbox
write-host  -ForegroundColor white		----------------------------------------------------------------------------
write-host
write-host

Get-Mailbox $Alias |fl alias,RetainDeletedItemsFor | out-string

write-host
write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  

# Section 3: PowerShell Command

write-host
write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	Display information Display information for: "$Alias".ToUpper() Mailbox
write-host  -ForegroundColor white		----------------------------------------------------------------------------
write-host
write-host

Get-Mailbox $Alias |Set-Mailbox -SingleItemRecoveryEnabled $True -RetainDeletedItemsFor 30 | out-string

write-host
write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  


# Step 3 : Display information after update 


# Section 3: PowerShell Command

write-host
write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	Display information about Deleted items policy for: "$Alias".ToUpper() Mailbox
write-host  -ForegroundColor white		----------------------------------------------------------------------------
write-host
write-host

Get-Mailbox $Alias |fl alias,RetainDeletedItemsFor | out-string

write-host
write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}



15{


#####################################################################
#  Set Deleted items policy for 30 days for ALL user (BULK)
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Set Deleted items policy for 30 days for ALL user (BULK)  '

write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Get-User -ResultSize Unlimited |Set-Mailbox -SingleItemRecoveryEnabled $True -RetainDeletedItemsFor 30  '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host
write-host
write-host

# Section 2: user input


# Step 1 : Display information before change


# Section 3: PowerShell Command


# Section 3: PowerShell Command

write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
Get-Mailbox -ResultSize Unlimited |Set-Mailbox -SingleItemRecoveryEnabled $True -RetainDeletedItemsFor 30  | out-string

write-host
write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  


# Section 4: export info



# Step 3 : Display information after update 


# Section 3: PowerShell Command

write-host
write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	Display information about Deleted items policy for: "$Alias".ToUpper() Mailbox
write-host  -ForegroundColor white		----------------------------------------------------------------------------
write-host
write-host

Get-Mailbox -ResultSize Unlimited |fl alias,RetainDeletedItemsFor | out-string

write-host
write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  




#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}



16{


#####################################################################
#  Display information about Deleted items policy for specific user
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Display information about Deleted items policy for spesfic user  '

write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Get-Mailbox <Alias> |FL alias,RetainDeletedItemsFor  '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host
write-host
write-host

# Section 2: user input


write-host
write-host -ForegroundColor Yellow	"Type the name the recipient Alias"  
write-host -ForegroundColor Yellow	"For example: John"
write-host
$Alias = Read-Host "Type the name the recipient Alias "
write-host


# Step 1 : Display information before change


# Section 3: PowerShell Command

write-host
write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	Display information about Deleted items policy for: "$Alias".ToUpper() Mailbox
write-host  -ForegroundColor white		----------------------------------------------------------------------------
write-host
write-host

Get-Mailbox $Alias |FL alias,RetainDeletedItemsFor | out-string

write-host
write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}







17{


#####################################################################
# Display information about Deleted items policy for ALL user
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Display information about Deleted items policy for ALL users  '

write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Get-Mailbox |FL alias,RetainDeletedItemsFor  '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host
write-host
write-host

# Section 2: user input


write-host
write-host -ForegroundColor Yellow	"Type the name the recipient Alias"  
write-host -ForegroundColor Yellow	"For example: John"
write-host
$Alias = Read-Host "Type the name the recipient Alias "
write-host


# Step 1 : Display information before change


# Section 3: PowerShell Command

write-host
write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	Display information about Deleted items policy for ALL users
write-host  -ForegroundColor white		----------------------------------------------------------------------------
write-host
write-host

Get-Mailbox |FL alias,RetainDeletedItemsFor | out-string

write-host
write-host
write-host  -ForegroundColor white		----------------------------------------------------------------------------  


#Section 5: End the Command
write-host
write-host
Read-Host "Press Enter to continue..."
write-host
write-host

}



#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#  Section H:  Export data
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



18{


#----------------------------------------------------------
$A1 =   "C:\INFO\1. Retention Policy "
$A11 =  "C:\INFO\1. Retention Policy\Reports "


if (!(Test-Path -path $A11))
{
New-Item $A11 -type directory
}


#----------------------------------------------------------


#####################################################################
#  Export data about Retention Policy
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Export data about Retention Policy  '
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Get-Mailbox -ResultSize Unlimited |select alias,RetentionPolicy  '
write-host  -ForegroundColor white		---------------------------------------------------------------------------- 
write-host  -ForegroundColor white  	'The export command will create a folder named: INFO in c:\ drive '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host
write-host
write-host

# Section 2: user input






#----------------------------------------------------------
# 1.Exchange Online objects - Mailbox
#----------------------------------------------------------


###TXT####
Get-Mailbox -ResultSize Unlimited | where {$_.name -notlike '*DiscoverySearchMailbox*'} |FL alias,RetentionPolicy  >$A1\"RetentionPolicy.txt"
##########


###CSV####
Get-Mailbox -ResultSize Unlimited | where {$_.name -notlike '*DiscoverySearchMailbox*'} |select alias,RetentionPolicy | Export-CSV $A11\"RetentionPolicy.CSV" –NoTypeInformation
##########


###HTML####
Get-Mailbox -ResultSize Unlimited | where {$_.name -notlike '*DiscoverySearchMailbox*'} |select alias,RetentionPolicy | ConvertTo-Html -head $htstyle -Body  "<H1> List of Retention Policy</H1>"  | Out-File $A11\"RetentionPolicy.HTML"
##########

#----------------------------------------------------------

}




19{


#----------------------------------------------------------

$A2 =   "C:\INFO\2. Deleted items policy "
$A21 =  "C:\INFO\2. Deleted items policy\Reports "


if (!(Test-Path -path $A21))
{
New-Item $A21 -type directory
}

#----------------------------------------------------------





#####################################################################
#  Export data about Deleted items policy
#####################################################################

# Section 1: information 

clear-host

write-host
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
write-host  -ForegroundColor white		Information                                                                                          
write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
write-host  -ForegroundColor white  	'This option will: '
write-host  -ForegroundColor white  	'Export data about Deleted items policy  '
write-host  -ForegroundColor white		----------------------------------------------------------------------------  
write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
write-host  -ForegroundColor Yellow  	'Get-Mailbox -ResultSize Unlimited |select alias,RetainDeletedItemsFor  '
write-host  -ForegroundColor white		---------------------------------------------------------------------------- 
write-host  -ForegroundColor white  	'The export command will create a folder named: INFO in C:\ drive '
write-host
write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
write-host
write-host
write-host
write-host

# Section 2: user input

#----------------------------------------------------------
# 1.Exchange Online objects - Mailbox
#----------------------------------------------------------


###TXT####
Get-Mailbox -ResultSize Unlimited | where {$_.name -notlike '*DiscoverySearchMailbox*'} |FL  alias,RetainDeletedItemsFor  >$A2\"Deleted items policy.txt"
##########


###CSV####
Get-Mailbox -ResultSize Unlimited | where {$_.name -notlike '*DiscoverySearchMailbox*'} |select alias,RetainDeletedItemsFor | Export-CSV $A21\"Deleted items policy.CSV" –NoTypeInformation
##########


###HTML####
Get-Mailbox -ResultSize Unlimited | where {$_.name -notlike '*DiscoverySearchMailbox*'} |select alias,RetainDeletedItemsFor | ConvertTo-Html -head $htstyle -Body  "<H1> List of Deleted items policy</H1>"  | Out-File $A21\"Deleted items policy.HTML"
##########

#----------------------------------------------------------


}




 
#+++++++++++++++++++
#  Finish  
##++++++++++++++++++
 
 
20{

##########################################
# Disconnect PowerShell session  
##########################################


Get-PSsession | Remove-PSsession

#Function Disconnect-ExchangeOnline {Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange"} | Remove-PSSession}
#Disconnect-ExchangeOnline -confirm



#———— Indication ———————
write-host 
if ($lastexitcode -eq 1)
{
	
	
	write-host "The command Failed :-(" -ForegroundColor red
	
	
}
else

{
	write-host "The command complete successfully !" -ForegroundColor Yellow
	write-host "The remote PowerShell session to Exchange online was disconnected" -ForegroundColor Yellow
	
}

#———— End of Indication ———————



}

21{

##########################################
# Exit 
##########################################


$Loop = $true
Exit
}

}


}