$command = {
    
        $disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number
    
        $letters = 69..73 | ForEach-Object { [char]$_ }
        $count = 0
        $labels = "data1","data2"
    
        foreach ($disk in $disks) {
            $driveLetter = $letters[$count].ToString()
            $disk | 
            Initialize-Disk -PartitionStyle MBR -PassThru |
            New-Partition -UseMaximumSize -DriveLetter $driveLetter |
            Format-Volume -FileSystem NTFS -NewFileSystemLabel $labels[$count] -Confirm:$false -Force
        $count++
        }
    
    }


Invoke-Command -ComputerName COMPUTER -ScriptBlock $command