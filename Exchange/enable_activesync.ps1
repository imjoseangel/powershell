Get-ActiveSyncDeviceStatistics -Mailbox HKRAETZ -GetMailboxLog:$true -NotificationEmailAddresses guillermo.lazcano@beamglobal.com

Set-CasMailbox -identity HKRAETZ -ActiveSyncDebugLogging:$false

$txt = "Holger.Kraetz@BeamGlobal.com"
Get-MobileDeviceStatistics -Mailbox $txt | fl DeviceOS, DeviceId, *Access*
Get-CASMailbox $txt | fl *Device*, DisplayName, *SmtpAddress, *Partnership, Name, Guid, SamAcc* 


$txt = "Holger.Kraetz@BeamGlobal.com"
Get-MobileDeviceStatistics -Mailbox $txt | fl 

Get-MobileDevice -Identity "namprd07.prod.outlook.com/Microsoft Exchange Hosted Organizations/BGSW1.onmicrosoft.com/Holger Kraetz/ExchangeActiveSyncDevices/iPhone§ApplF17LTTCGFFG8" | fl *device*

Get-ActiveSyncOrganizationSettings

Set-CasMailbox Holger.Kraetz@BeamGlobal.com -ActiveSyncAllowedDeviceids ApplF17LTTCGFFG8

Get-MobileDevice -Identity "namprd07.prod.outlook.com/Microsoft Exchange Hosted Organizations/BGSW1.onmicrosoft.com/Holger Kraetz/ExchangeActiveSyncDevices/iPhone§ApplF17LTTCGFFG8" | fl *device*