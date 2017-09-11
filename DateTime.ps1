function isToday ([datetime]$date) 
{[datetime]::Now.Date  -eq  $date.Date}

$fecha = [datetime]"01/29/2010"

get-childitem | where { isToday $fecha }

$cadena = "BAsura\Disabled"

if ( select-string -inputObject $cadena -pattern "Disabled" ) {
    write-host "SUCCESS"
}
