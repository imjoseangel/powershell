$AdminCredentials = Get-Credential "AQUANIMA\joseangel.munoz"
$select = Get-ADUser  -Server 180.209.16.71 -Credential $AdminCredentials -filter "Country -eq 'ES'" -Properties GivenName,Surname,MobilePhone,OfficePhone
$select | export-csv c:\spain.csv