# ---------------------------------
# Event 1644 Reader v1.04 by Ming Chen 6/16/2015, feel free to modify to fit your need.
# ---------------------------------
# Script requires Excel 2013 installed. 64bits Excel will allow generation of larger worksheet.
# This script will:
#    1. Scan all evtx in input directory for event 1644, exact 16 data fields from event 1644 and export to 1644-*.CSV.
#    2. Calls into Excel to import resulting 1644-*.CSV, create pivot tables for common ldap search analysis scenarios. Delete 1644-*.CSV afterward.
#
# To use the script:
#  1. Convert pre-2008 evt to evtx using later OS. (Please note, pre-2008 does not contain all 16 data fields. So some pivot tables might not display correctly.)
#  2. Follow on screen prompt to enter Path containing *.evtx and final xlsx.
#
# More info https://support.microsoft.com/en-us/kb/3060643
#
# ---------------------------------
# Known issue > "Not enough storage is available to complete this operation." in larger data set (around 15mb of csv.)
# ### Future version > break CSV into smaller chunks to reduce Excel memory needed to generate report
#
# Change log 1.04 change sort using SortAscendingExcel/SortDescendingExcel http://blogs.msdn.com/b/vsto/archive/2010/05/03/handling-sort-and-filter-events-in-excel-navneet-gupta.aspx
# Change log 1.03 > remark out Sort and DataBar to reduce memory usage, starting from line 81
# Change log 1.02 > change Cells to Item for default sort behavior


Function mcConvertClient ($Client)
{ # Extract IP or Port from client string [0] based on [1]
    $mcReturn='Unknown'
        [regex]$regexIPV6 = '(?<IP>\[[A-Fa-f0-9:%]{1,}\])\:(?<Port>([0-9]+))'
        [regex]$regexIPV4 =    '((?<IP>(\d{1,3}\.){3}\d{1,3})\:(?<Port>[0-9]+))|(?<IP>(\d{1,3}\.){3}\d{1,3})'
        [regex]$KnownClient = '(?<IP>([G-Z])\w+)'
        switch -regex ($Client[0])
        { # $client[1] is either IP or Port
            $regexIPV6 { $mcReturn = $matches.($client[1]) }
            $regexIPV4 { $mcReturn = $matches.($client[1]) }
            $KnownClient { $mcReturn = $matches.($client[1]) }
        }
    $mcReturn
}

#-----Function supporting Excel Import.
Function mcCleanUpExcelObj
{ #Clear out Excel ComObj at the end from https://theolddogscriptingblog.wordpress.com/2010/06/01/powershell-excel-cookbook-ver-2/
  [Management.Automation.ScopedItemOptions]$scopedOpt = 'ReadOnly, Constant'
  Get-Variable -Scope 1 | Where-Object {
   $_.Value.pstypenames -contains 'System.__ComObject' -and -not ($scopedOpt -band $_.Options)
  } | Remove-Variable -Scope 1 -Verbose:([Bool]$PSBoundParameters['Verbose'].IsPresent)
  [gc]::Collect()
}

Function mcSetPivotField($mcPivotFieldSetting)
{ #Set pivot field attributes per MSDN
    if ($mcPivotFieldSetting[1] -ne $null) { $mcPivotFieldSetting[0].Orientation  = $mcPivotFieldSetting[1]} # 1 Orientation { $xlRowField | $xlDataField }, in XlPivotFieldOrientation
    if ($mcPivotFieldSetting[2] -ne $null) { $mcPivotFieldSetting[0].NumberFormat = $mcPivotFieldSetting[2]} # 2 NumberFormat { $mcNumberF | $mcPercentF }
    if ($mcPivotFieldSetting[3] -ne $null) { $mcPivotFieldSetting[0].Function     = $mcPivotFieldSetting[3]} # 3 Function { $xlAverage | $xlSum | $xlCount }, in XlConsolidationFunction
    if ($mcPivotFieldSetting[4] -ne $null) { $mcPivotFieldSetting[0].Calculation  = $mcPivotFieldSetting[4]} # 4 Calculation { $xlPercentOfTotal | $xlPercentRunningTotal }, in XlPivotFieldCalculation
    if ($mcPivotFieldSetting[5] -ne $null) { $mcPivotFieldSetting[0].BaseField    = $mcPivotFieldSetting[5]} # 5 BaseField  <String>
    if ($mcPivotFieldSetting[6] -ne $null) { $mcPivotFieldSetting[0].Name         = $mcPivotFieldSetting[6]} # 6 Name <String>
    if ($mcPivotFieldSetting[7] -ne $null) { $mcPivotFieldSetting[0].Position     = $mcPivotFieldSetting[7]} # 7 Position
}

Function mcSetPivotTableFormat($mcPivotTable)
{ # Set pivotTable cosmetics and sheet name
    $mcPT=$mcPivotTable[0].PivotTables($mcPivotTable[1])
        $mcPT.HasAutoFormat = $False #2.turn of AutoColumnWidth
    for ($i=2; $i -lt 9; $i++)
    { #3. SetColumnWidth for Sheet($mcPivotTable[0]),PivotTable($mcPivotTable[1]),Column($mcPivotTable[2-8])
        if ($mcPivotTable[$i] -ne $null) { $mcPivotTable[0].columns.item(($i-1)).columnWidth = $mcPivotTable[$i]}
    }
    $mcPivotTable[0].Application.ActiveWindow.SplitRow = 3
    $mcPivotTable[0].Application.ActiveWindow.SplitColumn = 2
    $mcPivotTable[0].Application.ActiveWindow.FreezePanes = $true #1.Freeze R1C1
    $mcPivotTable[0].Cells.Item(1,1)="LDAPServer filter"
    $mcPivotTable[0].Cells.Item(3,1)=$mcPivotTable[9] #4 set TXT at R3C1 with PivotTableName$mcPivotTable[9]
    $mcPivotTable[0].Name=$mcPivotTable[10] #5 Set Sheet Name to $mcPivotTable[10]
        $mcRC = ($mcPivotTable[0].UsedRange.Cells).Rows.Count-1
    if ($mcPivotTable[11] -ne $null)
    { # $mcPivotTable[11] Set ColorScale
        $mColorScaleRange='$'+$mcPivotTable[11]+'$4:$'+$mcPivotTable[11]+'$'+$mcRC
        [Void]$mcPivotTable[0].Range($mColorScaleRange).FormatConditions.AddColorScale(3) #$mcPivotTable[11]=ColorScale
        $mcPivotTable[0].Range($mColorScaleRange).FormatConditions.item(1).ColorScaleCriteria.item(1).type = 1 #xlConditionValueLowestValue
        $mcPivotTable[0].Range($mColorScaleRange).FormatConditions.item(1).ColorScaleCriteria.item(1).FormatColor.Color = 8109667
        $mcPivotTable[0].Range($mColorScaleRange).FormatConditions.item(1).ColorScaleCriteria.item(2).FormatColor.Color = 8711167
        $mcPivotTable[0].Range($mColorScaleRange).FormatConditions.item(1).ColorScaleCriteria.item(3).type = 2 #xlConditionValueHighestValue
        $mcPivotTable[0].Range($mColorScaleRange).FormatConditions.item(1).ColorScaleCriteria.item(3).FormatColor.Color = 7039480
    }
#    if ($mcPivotTable[12] -ne $null)
#    { # $mcPivotTable[12] Set DataBar
#        $mcDataBarRange='$'+$mcPivotTable[12]+'$4:$'+$mcPivotTable[12]+'$'+$mcRC
#        [void]$mcPivotTable[0].Range($mcDataBarRange).FormatConditions.Delete()
#        [void]$mcPivotTable[0].Range($mcDataBarRange).FormatConditions.AddDatabar()    #$mcPivotTable[12]:Set DataBar
#    }
}

Function mcSortPivotFields($mcPF)
{ #Sort on $mcPF and collapse later pivot fields
    for ($i=2; $i -lt 5; $i++) { #collapse later pivot fields
        if ($mcPF[$i] -ne $null) { $mcPF[$i].showDetail = $false }
    }
#    [void]($mcPF[0].Cells.Item(4,2)).sort(($mcPF[0].Cells.Item(4, 2)), 2)
#    $mcPF[1].showDetail = $false
    $mcPF[0].Cells(4,2).Select() | Out-Null
    $mcExcel.CommandBars.ExecuteMso("SortDescendingExcel")
}

Function mcSetPivotTableHeaderColor($mcSheet)
{ #Set PiviotTable Header Color for easier reading
    $mcSheet[0].Range("A4:"+[char]($mcSheet[0].UsedRange.Cells.Columns.count+64)+[string](($mcSheet[0].UsedRange.Cells).Rows.count-1)).interior.Color = 16056319 #Set Level0 color
    for ($i=1; $i -lt 5; $i++) { #Set header(s) color
        if ($mcSheet[$i] -ne $null) { $mcSheet[0].Range(($mcSheet[$i]+"3")).interior.Colorindex = 37 }
    }
}

#----Main---------
cls
write-host "Event1644Reader: See https://support.microsoft.com/en-us/kb/3060643 for sample walk through and pivotTable tips."
    $mcScriptPath = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path
    $mcEventPath = Read-Host "Enter local, mapped or UNC path to Evtx(s). Be sure to remove trailing blank. For Example (c:\CaseData)`n Or press [Enter] if evtx is in the script folder.`n"
     if ($mcEventPath -eq "")
    { #If there is no Path entered, we will use the same directory as script.
        $mcEventPath= $mcScriptPath
            Write-Host "    Scanning event logs in $mcEventPath"
    }
# Convert evtx to csv.'
    Get-ChildItem -Path $mcEventPath | Where {$_.extension -eq '.evtx'} | ForEach ($_) { #Loop through *.evtx
        Write-Host ('Reading ',$_.Name)
        $mcEvents = Get-WinEvent -FilterHashtable @{Path=$mcEventPath+'\'+$_.Name; LogName="Directory Service"; id="1644" } -ErrorAction SilentlyContinue
        If ($mcEvents -ne $null)
        { #dump 1644 event to corresponding CSV
            $mcHeader = 0
            $mcOutFile = $mcEventPath+'\1644-'+$_.BaseName+'.csv'
                Write-Host ('    Event 1644 found, generating', $mcOutFile)
                $mc1644 = New-Object System.Object
            ForEach ($mcEvent in $mcEvents)
            { #Convert 1644 event to fields
                $mc1644 | Add-Member -MemberType NoteProperty -Name LDAPServer                -force -Value $mcEvent.MachineName
                $mc1644 | Add-Member -MemberType NoteProperty -Name TimeGenerated            -force -Value $mcEvent.TimeCreated
                $mc1644 | Add-Member -MemberType NoteProperty -Name ClientIP                 -force -Value (mcConvertClient($mcEvent.Properties[4].Value,'IP'))
                $mc1644 | Add-Member -MemberType NoteProperty -Name ClientPort                 -force -Value (mcConvertClient($mcEvent.Properties[4].Value,'Port'))
                $mc1644 | Add-Member -MemberType NoteProperty -Name StartingNode            -force -Value $mcEvent.Properties[0].Value
                $mc1644 | Add-Member -MemberType NoteProperty -Name Filter                -force -Value $mcEvent.Properties[1].Value
                $mc1644 | Add-Member -MemberType NoteProperty -Name SearchScope             -force -Value $mcEvent.Properties[5].Value
                $mc1644 | Add-Member -MemberType NoteProperty -Name AttributeSelection             -force -Value $mcEvent.Properties[6].Value
                $mc1644 | Add-Member -MemberType NoteProperty -Name ServerControls            -force -Value $mcEvent.Properties[7].Value
                $mc1644 | Add-Member -MemberType NoteProperty -Name VisitedEntries             -force -Value $mcEvent.Properties[2].Value
                $mc1644 | Add-Member -MemberType NoteProperty -Name ReturnedEntries             -force -Value $mcEvent.Properties[3].Value
                    $mc1644 | Add-Member -MemberType NoteProperty -Name UsedIndexes                -force -Value $mcEvent.Properties[8].Value # KB 2800945 or later has extra data fields.
                    $mc1644 | Add-Member -MemberType NoteProperty -Name PagesReferenced            -force -Value $mcEvent.Properties[9].Value
                    $mc1644 | Add-Member -MemberType NoteProperty -Name PagesReadFromDisk             -force -Value $mcEvent.Properties[10].Value
                    $mc1644 | Add-Member -MemberType NoteProperty -Name PagesPreReadFromDisk        -force -Value $mcEvent.Properties[11].Value
                    $mc1644 | Add-Member -MemberType NoteProperty -Name CleanPagesModified            -force -Value $mcEvent.Properties[12].Value
                    $mc1644 | Add-Member -MemberType NoteProperty -Name DirtyPagesModified            -force -Value $mcEvent.Properties[13].Value
                    $mc1644 | Add-Member -MemberType NoteProperty -Name SearchTimeMS            -force -Value $mcEvent.Properties[14].Value
                    $mc1644 | Add-Member -MemberType NoteProperty -Name AttributesPreventingOptimization    -force -Value $mcEvent.Properties[15].Value
                if ($mcHeader -eq 0)
                { # Create header for CSV output
                    ConvertTo-Csv $mc1644 -NoTypeInformation | Out-File $mcOutFile
                    $mcHeader = 1
                }
                else
                { # normal content for later 1644 events.
                    $mcTmp = (ConvertTo-Csv $mc1644 -NoTypeInformation)
                    write $mcTmp[1] | Out-File $mcOutFile -Append
                }
            }
        }
        else {
            Write-Host ('  No event 1644 found.')
        }
    }

#----Import csv to excel-----------------------------------------------------
    $mcFiles = Get-ChildItem -Path $mcEventPath | Where {$_.name -clike '1644-*.csv'} # Only look for 1644-****.csv created from earlier.
    If ($mcFiles -ne $null)
    { #Create a new Excel workbook if there are CSV in directory.
        Write-Host 'Import csv to excel.'
        $mcExcel = New-Object -ComObject excel.application
        $mcWorkbooks = $mcExcel.Workbooks.Add()
            $Sheet1 = $mcWorkbooks.worksheets.Item(1)
        $mcCurrentRow = 1
        ForEach ($mcFile in $mcFiles)
        { #Define Excel TXT connector and import/append
            $mcConnector = $Sheet1.QueryTables.add(("TEXT;" + $mcEventPath+'\'+$mcFile),$Sheet1.Range(('a'+($mcCurrentRow))))
            $Sheet1.QueryTables.item($mcConnector.name).TextFileCommaDelimiter = $True
            $Sheet1.QueryTables.item($mcConnector.name).TextFileParseType  = 1
            [void]$Sheet1.QueryTables.item($mcConnector.name).Refresh()
                if ($mcCurrentRow -ne 1) { [void]($Sheet1.Cells.Item($mcCurrentRow,1).entireRow).delete()} # Delete header on 2nd and later CSV.
                $mcCurrentRow = $Sheet1.UsedRange.EntireRow.Count+1
        }
        #----Customize XLS-----------------------------------------------------------
        Write-Host 'Customizing XLS.'
            $xlRowField = 1 #XlPivotFieldOrientation
            $xlPageField = 3 #XlPivotFieldOrientation
            $xlDataField = 4 #XlPivotFieldOrientation
            $xlAverage = -4106 #XlConsolidationFunction
            $xlSum = -4157 #XlConsolidationFunction
            $xlCount = -4112 #XlConsolidationFunction
            $xlPercentOfTotal = 8 #XlPivotFieldCalculation
            $xlPercentRunningTotal = 13 #XlPivotFieldCalculation
            $mcNumberF = "###,###,###,###,###"
            $mcPercentF = "#0.00%"
            $mcDateGroupFlags=($false, $true, $true, $true, $false, $false, $false) #https://msdn.microsoft.com/en-us/library/office/ff839808.aspx
        #Sheet1 - RawData
            $Sheet1.Range("A1").Autofilter() | Out-Null
            $Sheet1.Application.ActiveWindow.SplitRow = 1
            $Sheet1.Application.ActiveWindow.FreezePanes = $true
            $Sheet1.Columns.Item('J').numberformat = $Sheet1.Columns.Item('K').numberformat = $Sheet1.Columns.Item('M').numberformat = $Sheet1.Columns.Item('N').numberformat = $Sheet1.Columns.Item('O').numberformat = $Sheet1.Columns.Item('p').numberformat = $Sheet1.Columns.Item('Q').numberformat = $Sheet1.Columns.Item('R').numberformat = $mcNumberF
        #Sheet2 - PivotTable1
            $Sheet2 = $mcWorkbooks.Worksheets.add()
            $PivotTable1 = $mcWorkbooks.PivotCaches().Create(1,"Sheet1!R1C1:R$($Sheet1.UsedRange.Rows.count)C$($Sheet1.UsedRange.Columns.count)",5) # xlDatabase=1 xlPivotTableVersion15=5 Excel2013
            $PivotTable1.CreatePivotTable("Sheet2!R1C1") | Out-Null
                $mcPF00 = $Sheet2.PivotTables("PivotTable1").PivotFields("LDAPServer")
                    mcSetPivotField($mcPF00, $xlPageField, $null, $null, $null, $null, $null)
                $mcPF0 = $Sheet2.PivotTables("PivotTable1").PivotFields("StartingNode")
                    mcSetPivotField($mcPF0, $xlRowField, $null, $null, $null, $null, $null)
                $mcPF1 = $Sheet2.PivotTables("PivotTable1").PivotFields("Filter")
                    mcSetPivotField($mcPF1, $xlRowField, $null, $null, $null, $null, $null)
                $mcPF2 = $Sheet2.PivotTables("PivotTable1").PivotFields("ClientIP")
                    mcSetPivotField($mcPF2, $xlRowField, $null, $null, $null, $null, $null)
                $mcPF = $Sheet2.PivotTables("PivotTable1").PivotFields("TimeGenerated")
                    mcSetPivotField($mcPF, $xlRowField, $null, $null, $null, $null, $null)
                    $mcCells=$mcPF.DataRange.Item(4)
                    $mcCells.group($true,$true,1,$mcDateGroupFlags) | Out-Null
                $mcPF = $Sheet2.PivotTables("PivotTable1").PivotFields("ClientIP")
                    mcSetPivotField($mcPF, $xlDataField, $mcNumberF, $null, $null, $null, "Search Count",1)
                $mcPF = $Sheet2.PivotTables("PivotTable1").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF, $xlDataField, $mcNumberF, $xlAverage, $null, $null, "AvgSearchTime",2)
                $mcPF = $Sheet2.PivotTables("PivotTable1").PivotFields("ClientIP")
                    mcSetPivotField($mcPF, $xlDataField, $mcPercentF, $null, $xlPercentOfTotal, $null, "%GrandTotal",3)
                $mcPF = $Sheet2.PivotTables("PivotTable1").PivotFields("ClientIP")
                    mcSetPivotField($mcPF, $xlDataField, $mcPercentF, $null, $xlPercentRunningTotal, "StartingNode", "%RunningTotal",4)
            mcSetPivotTableFormat($Sheet2, "PivotTable1", 60, 12, 14, 12, 14, $null, $null,"StartingNode grouping", "2.TopIP-StartingNode", "D", "D")
            mcSortPivotFields($sheet2,$mcPF0,$mcPF1,$mcPF2)
            mcSetPivotTableHeaderColor($Sheet2, "B", "D", "E")
#Read-Host "sheet2"
        #Sheet3 - PivotTable2
            $Sheet3 = $mcWorkbooks.Worksheets.add()
            $PivotTable2 = $mcWorkbooks.PivotCaches().Create(1,"Sheet1!R1C1:R$($Sheet1.UsedRange.Rows.count)C$($Sheet1.UsedRange.Columns.count)",5) # xlDatabase=1 xlPivotTableVersion15=5 Excel2013
            $PivotTable2.CreatePivotTable("Sheet3!R1C1") | Out-Null
                $mcPF00 = $Sheet3.PivotTables("PivotTable2").PivotFields("LDAPServer")
                    mcSetPivotField($mcPF00, $xlPageField, $null, $null, $null, $null, $null)
                $mcPF0 = $Sheet3.PivotTables("PivotTable2").PivotFields("ClientIP")
                    mcSetPivotField($mcPF0, $xlRowField, $null, $null, $null, $null, $null)
                $mcPF1 = $Sheet3.PivotTables("PivotTable2").PivotFields("Filter")
                    mcSetPivotField($mcPF1, $xlRowField, $null, $null, $null, $null, $null)
                $mcPF2 = $Sheet3.PivotTables("PivotTable2").PivotFields("TimeGenerated")
                    mcSetPivotField($mcPF2, $xlRowField, $null, $null, $null, $null, $null)
                    $mcCells=$mcPF2.DataRange.Item(3)
                    $mcCells.group($true,$true,1,$mcDateGroupFlags) | Out-Null
                $mcPF = $Sheet3.PivotTables("PivotTable2").PivotFields("ClientIP")
                    mcSetPivotField($mcPF, $xlDataField, $mcNumberF, $null, $null, $null, "Search Count",1)
                $mcPF = $Sheet3.PivotTables("PivotTable2").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF, $xlDataField, $mcNumberF, $xlAverage, $null, $null, "AvgSearchTime (MS)",2)
                $mcPF = $Sheet3.PivotTables("PivotTable2").PivotFields("ClientIP")
                    mcSetPivotField($mcPF, $xlDataField, $mcPercentF, $null, $xlPercentOfTotal, $null, "%GrandTotal",3)
                $mcPF = $Sheet3.PivotTables("PivotTable2").PivotFields("ClientIP")
                    mcSetPivotField($mcPF, $xlDataField, $mcPercentF, $null, $xlPercentRunningTotal, "ClientIP", "%RunningTotal",4)
            mcSetPivotTableFormat($Sheet3, "PivotTable2", 60, 12, 19, 12, 14, $null, $null,"IP grouping", "3.TopIP", "D", "D")
            mcSortPivotFields($sheet3,$mcPF0,$mcPF1)
            mcSetPivotTableHeaderColor($Sheet3, "B", "D", "E")
#Read-Host 'sheet3'
        #Sheet4 - PivotTable3
            $Sheet4 = $mcWorkbooks.Worksheets.add()
            $PivotTable3 = $mcWorkbooks.PivotCaches().Create(1,"Sheet1!R1C1:R$($Sheet1.UsedRange.Rows.count)C$($Sheet1.UsedRange.Columns.count)",5) # xlDatabase=1 xlPivotTableVersion15=5 Excel2013
            $PivotTable3.CreatePivotTable("Sheet4!R1C1") | Out-Null
                $mcPF00 = $Sheet4.PivotTables("PivotTable3").PivotFields("LDAPServer")
                    mcSetPivotField($mcPF00, $xlPageField, $null, $null, $null, $null, $null)
                $mcPF0 = $Sheet4.PivotTables("PivotTable3").PivotFields("Filter")
                    mcSetPivotField($mcPF0, $xlRowField, $null, $null, $null, $null, $null)
                $mcPF1 = $Sheet4.PivotTables("PivotTable3").PivotFields("ClientIP")
                    mcSetPivotField($mcPF1, $xlRowField, $null, $null, $null, $null, $null)
                $mcPF = $Sheet4.PivotTables("PivotTable3").PivotFields("TimeGenerated")
                    mcSetPivotField($mcPF, $xlRowField, $null, $null, $null, $null, $null)
                    $mcCells=$mcPF.DataRange.Item(3)
                    $mcCells.group($true,$true,1,$mcDateGroupFlags) | Out-Null
                $mcPF = $Sheet4.PivotTables("PivotTable3").PivotFields("ClientIP")
                    mcSetPivotField($mcPF, $xlDataField, $mcNumberF, $null, $null, $null, "Search Count",1)
                $mcPF = $Sheet4.PivotTables("PivotTable3").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF, $xlDataField, $mcNumberF, $xlAverage, $null, $null, "AvgSearchTime (MS)",2)
                $mcPF = $Sheet4.PivotTables("PivotTable3").PivotFields("ClientIP")
                    mcSetPivotField($mcPF, $xlDataField, $mcPercentF, $null, $xlPercentOfTotal, $null, "%GrandTotal",3)
                $mcPF = $Sheet4.PivotTables("PivotTable3").PivotFields("ClientIP")
                    mcSetPivotField($mcPF, $xlDataField, $mcPercentF, $null, $xlPercentRunningTotal, "Filter", "%RunningTotal",4)
            mcSetPivotTableFormat($Sheet4, "PivotTable3", 60, 12, 19, 12, 14, $null, $null,"Filter grouping", "4.TopIP-Filters","D","D")
            mcSortPivotFields($sheet4,$mcPF0,$mcPF1)
            mcSetPivotTableHeaderColor($Sheet4, "B", "D", "E")
#Read-host 'sheet4'
        #Sheet5 - PivotTable4
            $Sheet5 = $mcWorkbooks.Worksheets.add()
            $PivotTable4 = $mcWorkbooks.PivotCaches().Create(1,"Sheet1!R1C1:R$($Sheet1.UsedRange.Rows.count)C$($Sheet1.UsedRange.Columns.count)",5) # xlDatabase=1 xlPivotTableVersion15=5 Excel2013
            $PivotTable4.CreatePivotTable("Sheet5!R1C1") | Out-Null
                $mcPF00 = $Sheet5.PivotTables("PivotTable4").PivotFields("LDAPServer")
                    mcSetPivotField($mcPF00, $xlPageField, $null, $null, $null, $null, $null)
                $mcPF0 = $Sheet5.PivotTables("PivotTable4").PivotFields("ClientIP")
                    mcSetPivotField($mcPF0, $xlRowField, $null, $null, $null, $null, $null)
                $mcPF1 = $Sheet5.PivotTables("PivotTable4").PivotFields("Filter")
                    mcSetPivotField($mcPF1, $xlRowField, $null, $null, $null, $null, $null)
                $mcPF = $Sheet5.PivotTables("PivotTable4").PivotFields("TimeGenerated")
                    mcSetPivotField($mcPF, $xlRowField, $null, $null, $null, $null, $null)
                    $mcCells=$mcPF.DataRange.Item(3)
                    $mcCells.group($true,$true,1,$mcDateGroupFlags) | Out-Null
                $mcPF = $Sheet5.PivotTables("PivotTable4").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF, $xlDataField, $mcNumberF, $xlSum, $null, $null, "Total SearchTime (MS)")
                $mcPF = $Sheet5.PivotTables("PivotTable4").PivotFields("ClientIP")
                    mcSetPivotField($mcPF, $xlDataField, $mcNumberF, $null, $null, $null, "Search Count")
                $mcPF = $Sheet5.PivotTables("PivotTable4").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF, $xlDataField, $mcNumberF, $xlAverage, $null, $null, "AvgSearchTime (MS)")
                $mcPF = $Sheet5.PivotTables("PivotTable4").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF, $xlDataField, $mcPercentF, $null, $xlPercentOfTotal, $null, "%GrandTotal (MS)")
                $mcPF = $Sheet5.PivotTables("PivotTable4").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF, $xlDataField, $mcPercentF, $null, $xlPercentRunningTotal, "ClientIP", "%RunningTotal (Ms)")
            mcSetPivotTableFormat($Sheet5, "PivotTable4", 50, 21, 12, 19, 17, 19, $null,"IP grouping", "5.TopTime-IP","E","E")
            mcSortPivotFields($sheet5,$mcPF0,$mcPF1)
            mcSetPivotTableHeaderColor($Sheet5, "B", "E", "F")
#Read-host 'sheet5'
        #Sheet6 - PivotTable5
            $Sheet6 = $mcWorkbooks.Worksheets.add()
            $PivotTable5 = $mcWorkbooks.PivotCaches().Create(1,"Sheet1!R1C1:R$($Sheet1.UsedRange.Rows.count)C$($Sheet1.UsedRange.Columns.count)",5) # xlDatabase=1 xlPivotTableVersion15=5 Excel2013
            $PivotTable5.CreatePivotTable("Sheet6!R1C1") | Out-Null
                $mcPF00 = $Sheet6.PivotTables("PivotTable5").PivotFields("LDAPServer")
                    mcSetPivotField($mcPF00, $xlPageField, $null, $null, $null, $null, $null)
                $mcPF0 = $Sheet6.PivotTables("PivotTable5").PivotFields("Filter")
                    mcSetPivotField($mcPF0, $xlRowField, $null, $null, $null, $null, $null)
                $mcPF1 = $Sheet6.PivotTables("PivotTable5").PivotFields("ClientIP")
                    mcSetPivotField($mcPF1, $xlRowField, $null, $null, $null, $null, $null)
                $mcPF = $Sheet6.PivotTables("PivotTable5").PivotFields("TimeGenerated")
                    mcSetPivotField($mcPF, $xlRowField, $null, $null, $null, $null, $null)
                    $mcCells=$mcPF.DataRange.Item(3)
                    $mcCells.group($true,$true,1,$mcDateGroupFlags) | Out-Null
                $mcPF = $Sheet6.PivotTables("PivotTable5").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF, $xlDataField, $mcNumberF, $xlSum, $null, $null, "Total SearchTime (MS)")
                $mcPF = $Sheet6.PivotTables("PivotTable5").PivotFields("ClientIP")
                    mcSetPivotField($mcPF, $xlDataField, $mcNumberF, $null, $null, $null, "Search Count")
                $mcPF = $Sheet6.PivotTables("PivotTable5").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF, $xlDataField, $mcNumberF, $xlAverage, $null, $null, "AvgSearchTime (MS)")
                $mcPF = $Sheet6.PivotTables("PivotTable5").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF, $xlDataField, $mcPercentF, $null, $xlPercentOfTotal, $null, "%GrandTotal (MS)")
                $mcPF = $Sheet6.PivotTables("PivotTable5").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF, $xlDataField, $mcPercentF, $null, $xlPercentRunningTotal, "Filter", "%RunningTotal (MS)")
            mcSetPivotTableFormat($Sheet6, "PivotTable5", 50, 21, 12, 19, 17, 19, $null,"Filter grouping", "6.TopTime-Filters","E","E")
            mcSortPivotFields($sheet6,$mcPF0,$mcPF1)
            mcSetPivotTableHeaderColor($Sheet6, "B", "E", "F")
#Read-host 'sheet6'
        #Sheet7 - PivotTable6
            $Sheet7 = $mcWorkbooks.Worksheets.add()
            $PivotTable6 = $mcWorkbooks.PivotCaches().Create(1,"Sheet1!R1C1:R$($Sheet1.UsedRange.Rows.count)C$($Sheet1.UsedRange.Columns.count)",5) # xlDatabase=1 xlPivotTableVersion15=5 Excel2013
            $PivotTable6.CreatePivotTable("Sheet7!R1C1") | Out-Null
                $mcPF00 = $Sheet7.PivotTables("PivotTable6").PivotFields("LDAPServer")
                    mcSetPivotField($mcPF00, $xlPageField, $null, $null, $null, $null, $null)
                $mcPF0 = $Sheet7.PivotTables("PivotTable6").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF0, $xlRowField, $null, $null, $null, $null, $null)
                    $mcPF0.DataRange.Item(1).group(0,$true,50) | Out-Null
                $mcPF1 = $Sheet7.PivotTables("PivotTable6").PivotFields("Filter")
                    mcSetPivotField($mcPF1, $xlRowField, $null, $null, $null, $null, $null)
                $mcPF2 = $Sheet7.PivotTables("PivotTable6").PivotFields("ClientIP")
                    mcSetPivotField($mcPF2, $xlRowField, $null, $null, $null, $null, $null)
                $mcPF = $Sheet7.PivotTables("PivotTable6").PivotFields("TimeGenerated")
                    mcSetPivotField($mcPF, $xlRowField, $null, $null, $null, $null, $null)
                    $mcCells=$mcPF.DataRange.Item(4)
                    $mcCells.group($true,$true,1,$mcDateGroupFlags) | Out-Null
                $mcPF = $Sheet7.PivotTables("PivotTable6").PivotFields("ClientIP")
                    mcSetPivotField($mcPF, $xlDataField, $mcNumberF, $null, $null, $null, "Search Count")
                $mcPF = $Sheet7.PivotTables("PivotTable6").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF, $xlDataField, $mcPercentF, $xlSum, $xlPercentOfTotal, $null, "%GrandTotal (MS)")
                $mcPF = $Sheet7.PivotTables("PivotTable6").PivotFields("SearchTimeMS")
                    mcSetPivotField($mcPF, $xlDataField, $mcPercentF, $xlSum, $xlPercentRunningTotal, "SearchTimeMS", "%RunningTotal (MS)")
            mcSetPivotTableFormat($Sheet7, "PivotTable6", 60, 12, 17, 19,$null, $null, $null, "SearchTime (MS) grouping", "7.TimeRanks",$null,"C")
            $mcPF0.showDetail = $mcPF1.showDetail = $mcPF2.showDetail = $false
            mcSetPivotTableHeaderColor($Sheet7, "C", "D")
#Read-host 'sheet7'
        #Sheet8 - PivotTable7
            $Sheet8 = $mcWorkbooks.Worksheets.add()
            $PivotTable7 = $mcWorkbooks.PivotCaches().Create(1,"Sheet1!R1C1:R$($Sheet1.UsedRange.Rows.count)C$($Sheet1.UsedRange.Columns.count)",5) # xlDatabase=1 xlPivotTableVersion15=5 Excel2013
            $PivotTable7.CreatePivotTable("Sheet8!R1C1") | Out-Null
            $Sheet8.name = "8.SandBox"
#Read-host 'sheet8'
        #Set Sheet1 name and sort sheet names in reverse
            $Sheet1.Name = "1.RawData"
        $Sheet2.Tab.ColorIndex = $Sheet3.Tab.ColorIndex = $Sheet4.Tab.ColorIndex = 35
        $Sheet5.Tab.ColorIndex = $Sheet6.Tab.ColorIndex = $Sheet7.Tab.ColorIndex = 36
        $sheet8.Tab.Color=8109667
        $mcWorkSheetNames = New-Object System.Collections.ArrayList
            foreach ($mcWorkSheet in $mcWorkbooks.Worksheets) { $mcWorkSheetNames.add($mcWorkSheet.Name) | Out-null }
            $mctmp = $mcWorkSheetNames.Sort() | Out-Null
            For ($i=0; $i -lt $mcWorkSheetNames.Count-1; $i++){ #Sort name.
                $mcTmp = $mcWorkSheetNames[$i]
                $mcBefore = $mcWorkbooks.Worksheets.Item($mcTmp)
                $mcAfter = $mcWorkbooks.Worksheets.Item($i+1)
                $mcBefore.Move($mcAfter)
            }
        $Sheet1.Activate()
        #SaveAsFile
        $mcFileName = Read-Host "Enter a FileName to save extracted event 1644 xlsx.`n"
        if ($mcFileName)
        {
            Write-Host "Saving file to $mcEventPath\$mcFileName.xlsx"
            $mcWorkbooks.SaveAs($mcEventPath+'\'+$mcFileName)
        }
        #Delete CSV?
            $mcCleanup = Read-Host "Delete generated 1644-*.csv? ([Enter]/[Y] to delete, [N] to keep csv)`n"
#$mcCleanup = 'n' #testing only
            if ($mcCleanup -ne 'N')
            { #Delete all 1644-*.csv
                Get-ChildItem -Path $mcEventPath | Where {$_.name -clike '1644-*.csv'} | foreach ($_) {
                    Remove-Item $mcEventPath'\'$_
                    write-host '    '$_ deleted.}
            }
        $mcExcel.visible = $true
        #mcCleanUpExcelObj
    } else {
        write-host '    No event 1644 found in specified directory.' $mcEventPath
    }
    cd $mcScriptPath
Write-Host 'Script completed.'
#################################################################################
