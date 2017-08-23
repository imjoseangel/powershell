# Find out if the current user identity is elevated (has admin rights)
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

for($i = 1; $i -le 5; $i++){
  $u =  "".PadLeft($i,"u")
  $unum =  "u$i"
  $d =  $u.Replace("u","../")
  Invoke-Expression "function $u { push-location $d }"
  Invoke-Expression "function $unum { push-location $d }"
}

function cd...  { cd ..\.. }
function cd.... { cd ..\..\.. }

Set-Alias touch Set-ModifiedTime
Set-Alias rm Remove-ItemSafely -Option AllScope

$www = $env:www

function sudo()
{
    if ($args.Length -eq 1)
    {
        start-process $args[0] -verb "runAs"
    }
    if ($args.Length -gt 1)
    {
        start-process $args[0] -ArgumentList $args[1..$args.Length] -verb "runAs"
    }
}

function Search-AllTextFiles {
    param(
        [parameter(Mandatory=$true,position=0)]$Pattern, 
        [switch]$CaseSensitive,
        [switch]$SimpleMatch
    );

    Get-ChildItem . * -Recurse -Exclude ('*.dll','*.pdf','*.pdb','*.zip','*.exe','*.jpg','*.gif','*.png','*.ico','*.svg','*.bmp','*.psd','*.cache','*.doc','*.docx','*.xls','*.xlsx','*.dat','*.mdf','*.nupkg','*.snk','*.ttf','*.eot','*.woff','*.tdf','*.gen','*.cfs','*.map','*.min.js','*.data') | Select-String -Pattern:$pattern -SimpleMatch:$SimpleMatch -CaseSensitive:$CaseSensitive
}

function uptime {
	Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime';
	EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}

function reload-powershell-profile {
	& $profile
}

function get-windows-build {
	[Environment]::OSVersion
}

function get-path {
	($Env:Path).Split(";")
}

function df {
	get-volume
}

function grep($regex, $dir) {
	if ( $dir ) {
		ls $dir | select-string $regex
		return
	}
	$input | select-string $regex
}

function which($name) {
	Get-Command $name | Select-Object -ExpandProperty Definition
}

function pgrep($name) {
	ps $name
}

function prompt 
{ 
    if ($isAdmin) 
    {
        "[" + (Get-Location) + "] # " 
    }
    else 
    {
        "[" + (Get-Location) + "] $ "
    }
}
function pkill($name) {
	ps $name -ErrorAction SilentlyContinue | kill
}
function motd {

Write-Host " "
Write-Host "Your Logo Here"
Write-Host " "


}
motd{}

Set-Location C:\Users\$Env:UserName\Documents\Source
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

$PSScriptAnalyzerMod = Get-Module -ListAvailable -name PSScriptAnalyzer
if ($PSScriptAnalyzerMod) {
    Import-Module -Name PSScriptAnalyzer
}

$AzureRMMod = Get-Module -ListAvailable -name AzureRM
if ($AzureRMMod) {
    Import-Module -Name AzureRM
}

# My Scripts

$psdir="C:\Users\JoseMar\Documents\WindowsPowerShell\Scripts\Autoload"  

# Load all 'Autoload' scripts

Get-ChildItem "${psdir}\*.ps1" | %{.$_} 
Write-Output "Custom PowerShell Environment Loaded" 
