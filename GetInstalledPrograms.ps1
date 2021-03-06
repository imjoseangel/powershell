if ($args.Length -lt 1) {
    write-host ""
    write-host "Usage: GetInstalledPrograms <IP Address>"
    write-host ""
    return
} 

$wmi = $args[0]

# param([string]$wmi = "wmi")

function Get-InstalledPrograms($computer = '.') {
	$programs_installed = @{};
	$win32_product = @(get-wmiobject -class 'Win32_Product' -computer $computer);
	foreach ($product in $win32_product) {
		$name = $product.Name;
		$version = $product.Version;
		if ($name -ne $null) {
			$programs_installed.$name = $version;
		}
	}
	return $programs_installed;
}

$programs = Get-InstalledPrograms $wmi
$programs