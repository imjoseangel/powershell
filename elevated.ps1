& {
 $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
 $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
 $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 $IsAdmin=$prp.IsInRole($adm)
 if ($IsAdmin)
 {
  (get-host).UI.RawUI.Backgroundcolor="DarkRed"
  clear-host
 }
}
