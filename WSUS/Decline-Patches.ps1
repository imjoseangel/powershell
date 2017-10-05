# Decline Superseeded
# Option 1
$SupersededUpdates = $WsusServerAdminProxy.GetUpdates() | ?{$_.IsSuperseded }
$SupersededUpdates | %{$_.Decline()}
 
# Option 2
$unapproved = Get-WsusUpdate -Approval Unapproved
$unapproved | ? {$_.update.issuperseded -eq $True} | Deny-WsusUpdate  # Superseded by another update

# Decline Itanium
# Option 1
$ItaniumUpdates = $WsusServerAdminProxy.GetUpdates() | ?{-not $_.IsDeclined -and $_.Title -match "ia64|itanium|CHS IME"}
$ItaniumUpdates | %{$_.Decline()}
 
# Option 2
$unapproved = Get-WsusUpdate -Approval Unapproved
$unapproved | ? {$_.update.title -like "*itanium*"} | Deny-WsusUpdate # Itanium
$unapproved | ? {$_.update.title -like "*ia64*"} | Deny-WsusUpdate    # Itanium
$unapproved | ? {$_.update.title -like "*CHS IME*"} | Deny-WsusUpdate # Simplified Chinese IME