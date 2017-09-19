Get-Process | Select-Object -Property Name, @{N="MB"; E= {$_.VM / 1gb -as [int]}} | Sort-Object -Property MB -Descending | Select-Object -First 10

# Another way is:

Update-TypeData -TypeName System.Diagnostics.Process -MemberType ScriptProperty -MemberName MB -Value {$this.VM / 1gb -as [int]}
Get-Process | Select-Object -Property Name, MB | Sort-Object -Property MB -Descending | Select-Object -First 10