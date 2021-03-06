#region Synchronized Collections
$uiHash = [hashtable]::Synchronized(@{})
$jobs = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))
$jobCleanup = [hashtable]::Synchronized(@{})
$Global:updateAudit = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))
$Global:installAudit = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))
$Global:servicesAudit = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))
$Global:installedUpdates = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))
#endregion

#region Startup Checks and configurations

#Validate user is an Administrator
Write-Verbose "Checking Administrator credentials"
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You are not running this as an Administrator!`nRe-running script and will prompt for administrator credentials."
    Start-Process -Verb "Runas" -File PowerShell.exe -Argument "-STA -noprofile -file $($myinvocation.mycommand.definition)"
    Break
}

#Ensure that we are running the GUI from the correct location
Set-Location $(Split-Path $MyInvocation.MyCommand.Path)
$Global:Path = $(Split-Path $MyInvocation.MyCommand.Path)
Write-Debug "Current location: $Path"

#Determine if this instance of PowerShell can run WPF 
Write-Verbose "Checking the apartment state"
If ($host.Runspace.ApartmentState -ne "STA") {
    Write-Warning "This script must be run in PowerShell started using -STA switch!`nScript will attempt to open PowerShell in STA and run re-run script."
    Start-Process -File PowerShell.exe -Argument "-STA -noprofile -WindowStyle hidden -file $($myinvocation.mycommand.definition)"
    Break
}

#Load Required Assemblies
Add-Type –assemblyName PresentationFramework
Add-Type –assemblyName PresentationCore
Add-Type –assemblyName WindowsBase
Add-Type –assemblyName Microsoft.VisualBasic
Add-Type –assemblyName System.Windows.Forms

#endregion

#Add Approvals to GUI
Function Get-Approved {
    $server = Get-WsusServer -Name $Env:COMPUTERNAME -PortNumber 8530
    $updates = $server | Get-WsusUpdate -Approval Approved -Classification All -Status FailedOrNeeded
    $list = $updates | Select-Object @{Name="Title";Expression={$_.update.Title}},@{Name="Severity";Expression={$_.update.MsrcSeverity}},`
    @{Name="KB";Expression={$_.update.KnowledgebaseArticles}},@{Name="Classification";Expression={$_.update.UpdateClassificationTitle}},`
    @{Name="Creation Date";Expression={$_.update.CreationDate.ToShortDateString()}},@{Name="OS";Expression={$_.update.ProductTitles}}
    $uiHash.Listview.ItemsSource = $list
}

#Add Declined to GUI
Function Get-Declined {
    $server = Get-WsusServer -Name $Env:COMPUTERNAME -PortNumber 8530
    $updates = $server | Get-WsusUpdate -Approval Declined -Classification All -Status Any
    $list = $updates | Select-Object @{Name="Title";Expression={$_.update.Title}},@{Name="Severity";Expression={$_.update.MsrcSeverity}},`
    @{Name="KB";Expression={$_.update.KnowledgebaseArticles}},@{Name="Classification";Expression={$_.update.UpdateClassificationTitle}},`
    @{Name="Creation Date";Expression={$_.update.CreationDate.ToShortDateString()}},@{Name="OS";Expression={$_.update.ProductTitles}}
    $uiHash.Listview.ItemsSource = $list
}

#Build the GUI
[xml]$xaml = @"
<Window
xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
x:Name='Window' Title='Powershell WSUS Utility' WindowStartupLocation = 'CenterScreen' 
Width = '880' Height = '575' ShowInTaskbar = 'True'>
<Window.Background>
    <LinearGradientBrush StartPoint='0,0' EndPoint='0,1'>
        <LinearGradientBrush.GradientStops> <GradientStop Color='#C4CBD8' Offset='0' /> <GradientStop Color='#E6EAF5' Offset='0.2' /> 
        <GradientStop Color='#CFD7E2' Offset='0.9' /> <GradientStop Color='#C4CBD8' Offset='1' /> </LinearGradientBrush.GradientStops>
    </LinearGradientBrush>
</Window.Background> 
<Window.Resources>        
    <DataTemplate x:Key="HeaderTemplate">
        <DockPanel>
            <TextBlock FontSize="10" Foreground="Green" FontWeight="Bold" >
                <TextBlock.Text>
                    <Binding/>
                </TextBlock.Text>
            </TextBlock>
        </DockPanel>
    </DataTemplate>            
</Window.Resources>    
<Grid x:Name = 'Grid' ShowGridLines = 'false'>
    <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
    </Grid.ColumnDefinitions>
    <Grid.RowDefinitions>
        <RowDefinition Height = 'Auto'/>
        <RowDefinition Height = 'Auto'/>
        <RowDefinition Height = '*'/>
        <RowDefinition Height = 'Auto'/>
        <RowDefinition Height = 'Auto'/>
        <RowDefinition Height = 'Auto'/>
    </Grid.RowDefinitions>    
    <Menu Width = 'Auto' HorizontalAlignment = 'Stretch' Grid.Row = '0'>
    <Menu.Background>
        <LinearGradientBrush StartPoint='0,0' EndPoint='0,1'>
            <LinearGradientBrush.GradientStops> <GradientStop Color='#C4CBD8' Offset='0' /> <GradientStop Color='#E6EAF5' Offset='0.2' /> 
            <GradientStop Color='#CFD7E2' Offset='0.9' /> <GradientStop Color='#C4CBD8' Offset='1' /> </LinearGradientBrush.GradientStops>
        </LinearGradientBrush>
    </Menu.Background>
        <MenuItem x:Name = 'FileMenu' Header = '_File'>
            <MenuItem x:Name = 'RunMenu' Header = '_Run' ToolTip = 'Initiate Run operation' InputGestureText ='F5'> </MenuItem>
            <MenuItem x:Name = 'GenerateReportMenu' Header = 'Generate R_eport' ToolTip = 'Generate Report' InputGestureText ='F8'/>
            <Separator />            
            <MenuItem x:Name = 'OptionMenu' Header = '_Options' ToolTip = 'Open up options window.' InputGestureText ='Ctrl+O'/>
            <Separator />
            <MenuItem x:Name = 'ExitMenu' Header = 'E_xit' ToolTip = 'Exits the utility.' InputGestureText ='Ctrl+E'/>
        </MenuItem>
        <MenuItem x:Name = 'EditMenu' Header = '_Edit'>
            <MenuItem x:Name = 'SelectAllMenu' Header = 'Select _All' ToolTip = 'Selects all rows.' InputGestureText ='Ctrl+A'/>               
            <Separator />
            <MenuItem x:Name = 'ClearErrorMenu' Header = 'Clear ErrorLog' ToolTip = 'Clears error log.'> </MenuItem>                
            <MenuItem x:Name = 'ClearAllMenu' Header = 'Clear All' ToolTip = 'Clears everything on the WSUS utility.'/>
        </MenuItem>
        <MenuItem x:Name = 'ActionMenu' Header = '_Action'>
            <MenuItem x:Name = 'PatchesListReportMenu' Header = 'Create Patches List Report' 
            ToolTip = 'Creates a CSV file listing the current Patches List.'/>
            <Separator/>
            <MenuItem x:Name = 'ViewErrorMenu' Header = 'View ErrorLog' ToolTip = 'Views error log.'/>            
        </MenuItem>            
        <MenuItem x:Name = 'HelpMenu' Header = '_Help'>
            <MenuItem x:Name = 'AboutMenu' Header = '_About' ToolTip = 'Show the current version and other information.'> </MenuItem>
            <MenuItem x:Name = 'HelpFileMenu' Header = 'WSUS Utility _Help' 
            ToolTip = 'Displays a help file to use the WSUS Utility.' InputGestureText ='F1'> </MenuItem>
        </MenuItem>            
    </Menu>
    <Grid Grid.Row = '2' Grid.Column = '0' ShowGridLines = 'false'>  
        <Grid.Resources>
            <Style x:Key="AlternatingRowStyle" TargetType="{x:Type Control}" >
                <Setter Property="Background" Value="LightGray"/>
                <Setter Property="Foreground" Value="Black"/>
                <Style.Triggers>
                    <Trigger Property="ItemsControl.AlternationIndex" Value="1">                            
                        <Setter Property="Background" Value="White"/>
                        <Setter Property="Foreground" Value="Black"/>                                
                    </Trigger>                            
                </Style.Triggers>
            </Style>                    
        </Grid.Resources>                  
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="10"/>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="10"/>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="10"/>
            <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height = 'Auto'/>
            <RowDefinition Height = 'Auto'/>
            <RowDefinition Height = '*'/>
            <RowDefinition Height = '*'/>
            <RowDefinition Height = 'Auto'/>
            <RowDefinition Height = 'Auto'/>
            <RowDefinition Height = 'Auto'/>
        </Grid.RowDefinitions> 
        <GroupBox Header = "Patches List" Grid.Column = '0' Grid.Row = '2' Grid.ColumnSpan = '11' Grid.RowSpan = '3'>
            <Grid Width = 'Auto' Height = 'Auto' ShowGridLines = 'false'>
            <ListView x:Name = 'Listview' AllowDrop = 'True' AlternationCount="2" ItemContainerStyle="{StaticResource AlternatingRowStyle}"
            ToolTip = 'Server List that displays all information regarding statuses of servers and patches.'>
                <ListView.View>
                    <GridView x:Name = 'GridView' AllowsColumnReorder = 'True' ColumnHeaderTemplate="{StaticResource HeaderTemplate}">
                    <GridViewColumn x:Name = 'TitleColumn' Width = '200' DisplayMemberBinding = '{Binding Path = Title}' Header='Title'/>
                    <GridViewColumn x:Name = 'SeverityColumn' Width = '112' DisplayMemberBinding = '{Binding Path = Severity}' Header='Severity'/>
                    <GridViewColumn x:Name = 'KBColumn' Width = '112' DisplayMemberBinding = '{Binding Path = KB}' Header='KB' />
                    <GridViewColumn x:Name = 'ClassificationColumn' Width = '112' DisplayMemberBinding = '{Binding Path = Classification}' Header='Classification' />
                    <GridViewColumn x:Name = 'CreationDateColumn' Width = '112' DisplayMemberBinding = '{Binding Path = Creation Date}' Header='Creation Date' />
                    <GridViewColumn x:Name = 'OSColumn' Width = '200' DisplayMemberBinding = '{Binding Path = OS}' Header='OS' />
                    </GridView>
                </ListView.View>
                <ListView.ContextMenu>
                    <ContextMenu x:Name = 'ListViewContextMenu'>
                        <MenuItem x:Name = 'GetApprovedMenu' Header = 'Get Approved' InputGestureText ='Ctrl+A'/>               
                        <MenuItem x:Name = 'GetDeclinedMenu' Header = 'Get Declined' InputGestureText ='Ctrl+D'/>
                        <Separator />
                        <MenuItem x:Name = 'WindowsUpdateServiceMenu' Header = 'Windows Update Service' > 
                            <MenuItem x:Name = 'WUStopServiceMenu' Header = 'Stop Service' />
                            <MenuItem x:Name = 'WUStartServiceMenu' Header = 'Start Service' />
                            <MenuItem x:Name = 'WURestartServiceMenu' Header = 'Restart Service' />
                        </MenuItem>                            
                        <MenuItem x:Name = 'WindowsUpdateLogMenu' Header = 'WindowsUpdateLog' > 
                            <MenuItem x:Name = 'EntireLogMenu' Header = 'View Entire Log'/>
                            <MenuItem x:Name = 'Last25LogMenu' Header = 'View Last 25' />
                            <MenuItem x:Name = 'Last50LogMenu' Header = 'View Last 50'/>
                            <MenuItem x:Name = 'Last100LogMenu' Header = 'View Last 100'/>
                        </MenuItem>
                    </ContextMenu>
                </ListView.ContextMenu>            
            </ListView>                
            </Grid>
        </GroupBox>                                    
    </Grid>        
    <ProgressBar x:Name = 'ProgressBar' Grid.Row = '3' Height = '20' ToolTip = 'Displays progress of current action via a graphical progress bar.'/>   
    <TextBox x:Name = 'StatusTextBox' Grid.Row = '4' ToolTip = 'Displays current status of operation'> Waiting for Action... </TextBox>                           
</Grid>   
</Window>
"@ 

#region Load XAML into PowerShell
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$uiHash.Window=[Windows.Markup.XamlReader]::Load( $reader )
#endregion
 
#region Background runspace to clean up jobs
$jobCleanup.Flag = $True
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"          
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("uiHash",$uiHash)          
$newRunspace.SessionStateProxy.SetVariable("jobCleanup",$jobCleanup)     
$newRunspace.SessionStateProxy.SetVariable("jobs",$jobs) 
$jobCleanup.PowerShell = [PowerShell]::Create().AddScript({
    #Routine to handle completed runspaces
    Do {    
        Foreach($runspace in $jobs) {
            If ($runspace.Runspace.isCompleted) {
                $runspace.powershell.EndInvoke($runspace.Runspace) | Out-Null
                $runspace.powershell.dispose()
                $runspace.Runspace = $null
                $runspace.powershell = $null               
            } 
        }
        #Clean out unused runspace jobs
        $temphash = $jobs.clone()
        $temphash | Where {
            $_.runspace -eq $Null
        } | ForEach {
            Write-Verbose ("Removing {0}" -f $_.computer)
            $jobs.remove($_)
        }        
        Start-Sleep -Seconds 1     
    } while ($jobCleanup.Flag)
})
$jobCleanup.PowerShell.Runspace = $newRunspace
$jobCleanup.Thread = $jobCleanup.PowerShell.BeginInvoke()  
#endregion

#region Connect to all controls
$uiHash.GenerateReportMenu = $uiHash.Window.FindName("GenerateReportMenu")
$uiHash.ClearAuditReportMenu = $uiHash.Window.FindName("ClearAuditReportMenu")
$uiHash.ClearInstallReportMenu = $uiHash.Window.FindName("ClearInstallReportMenu")
$uiHash.SelectAllMenu = $uiHash.Window.FindName("SelectAllMenu")
$uiHash.OptionMenu = $uiHash.Window.FindName("OptionMenu")
$uiHash.WUStopServiceMenu = $uiHash.Window.FindName("WUStopServiceMenu")
$uiHash.WUStartServiceMenu = $uiHash.Window.FindName("WUStartServiceMenu")
$uiHash.WURestartServiceMenu = $uiHash.Window.FindName("WURestartServiceMenu")
$uiHash.WindowsUpdateServiceMenu = $uiHash.Window.FindName("WindowsUpdateServiceMenu")
$uiHash.GenerateReportButton = $uiHash.Window.FindName("GenerateReportButton")
$uiHash.ReportComboBox = $uiHash.Window.FindName("ReportComboBox")
$uiHash.StartImage = $uiHash.Window.FindName("StartImage")
$uiHash.CancelImage = $uiHash.Window.FindName("CancelImage")
$uiHash.RunOptionComboBox = $uiHash.Window.FindName("RunOptionComboBox")
$uiHash.ClearErrorMenu = $uiHash.Window.FindName("ClearErrorMenu")
$uiHash.ViewErrorMenu = $uiHash.Window.FindName("ViewErrorMenu")
$uiHash.EntireLogMenu = $uiHash.Window.FindName("EntireLogMenu")
$uiHash.Last25LogMenu = $uiHash.Window.FindName("Last25LogMenu")
$uiHash.Last50LogMenu = $uiHash.Window.FindName("Last50LogMenu")
$uiHash.Last100LogMenu = $uiHash.Window.FindName("Last100LogMenu")
$uiHash.ResetDataMenu = $uiHash.Window.FindName("ResetDataMenu")
$uiHash.ResetAuthorizationMenu = $uiHash.Window.FindName("ResetAuthorizationMenu")
$uiHash.ClearServerListNotesMenu = $uiHash.Window.FindName("ClearServerListNotesMenu")
$uiHash.ServerListReportMenu = $uiHash.Window.FindName("ServerListReportMenu")
$uiHash.OfflineHostsMenu = $uiHash.Window.FindName("OfflineHostsMenu")
$uiHash.HostListMenu = $uiHash.Window.FindName("HostListMenu")
$uiHash.InstalledUpdatesMenu = $uiHash.Window.FindName("InstalledUpdatesMenu")
$uiHash.DetectNowMenu = $uiHash.Window.FindName("DetectNowMenu")
$uiHash.WindowsUpdateLogMenu = $uiHash.Window.FindName("WindowsUpdateLogMenu")
$uiHash.WUAUCLTMenu = $uiHash.Window.FindName("WUAUCLTMenu")
$uiHash.GUIInstalledUpdatesMenu = $uiHash.Window.FindName("GUIInstalledUpdatesMenu")
$uiHash.GetApprovedMenu = $uiHash.Window.FindName("GetApprovedMenu")
$uiHash.GetDeclinedMenu = $uiHash.Window.FindName("GetDeclinedMenu")
$uiHash.ListviewContextMenu = $uiHash.Window.FindName("ListViewContextMenu")
$uiHash.ExitMenu = $uiHash.Window.FindName("ExitMenu")
$uiHash.ClearInstalledUpdateMenu = $uiHash.Window.FindName("ClearInstalledUpdateMenu")
$uiHash.RunMenu = $uiHash.Window.FindName('RunMenu')
$uiHash.ClearAllMenu = $uiHash.Window.FindName("ClearAllMenu")
$uiHash.ClearServerListMenu = $uiHash.Window.FindName("ClearServerListMenu")
$uiHash.AboutMenu = $uiHash.Window.FindName("AboutMenu")
$uiHash.HelpFileMenu = $uiHash.Window.FindName("HelpFileMenu")
$uiHash.Listview = $uiHash.Window.FindName("Listview")
$uiHash.LoadFileButton = $uiHash.Window.FindName("LoadFileButton")
$uiHash.BrowseFileButton = $uiHash.Window.FindName("BrowseFileButton")
$uiHash.LoadADButton = $uiHash.Window.FindName("LoadADButton")
$uiHash.StatusTextBox = $uiHash.Window.FindName("StatusTextBox")
$uiHash.ProgressBar = $uiHash.Window.FindName("ProgressBar")
$uiHash.RunButton = $uiHash.Window.FindName("RunButton")
$uiHash.CancelButton = $uiHash.Window.FindName("CancelButton")
$uiHash.GridView = $uiHash.Window.FindName("GridView")
#endregion

#region Event Handlers

#GetApproved Menu
$uiHash.GetApprovedMenu.Add_Click({
    Get-Approved
})

#GetDeclined Menu
$uiHash.GetDeclinedMenu.Add_Click({
    Get-Declined
})  

#Restart Service
$uiHash.WURestartServiceMenu.Add_Click({
    If ($uiHash.Listview.Items.count -gt 0) {
        $Servers = $uiHash.Listview.SelectedItems | Select -ExpandProperty Computer
        [Float]$uiHash.ProgressBar.Maximum = $servers.count
        $uiHash.Listview.ItemsSource | ForEach {$_.Notes = $Null}
        $uiHash.RunButton.IsEnabled = $False
        $uiHash.StartImage.Source = "$pwd\Images\Start_locked.jpg"
        $uiHash.CancelButton.IsEnabled = $True
        $uiHash.CancelImage.Source = "$pwd\Images\Stop.jpg"
        $uiHash.StatusTextBox.Foreground = "Black"
        $uiHash.StatusTextBox.Text = "Restarting WSUS Client service on selected servers"            
        $uiHash.StartTime = (Get-Date)        
        [Float]$uiHash.ProgressBar.Value = 0
        $scriptBlock = {
            Param (
                $Computer,
                $uiHash,
                $Path
            )               
            $uiHash.ListView.Dispatcher.Invoke("Normal",[action]{ 
                $uiHash.Listview.Items.EditItem($Computer)
                $computer.Notes = "Restarting Update Client Service"
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh() 
            })                
            Set-Location $Path
            Try {
                $updateClient = Get-Service -ComputerName $computer.computer -Name wuauserv -ErrorAction Stop
                Restart-Service -inputObject $updateClient -ErrorAction Stop
                $result = $True
            } Catch {
                $updateClient = $_.Exception.Message
            }
            $uiHash.ListView.Dispatcher.Invoke("Background",[action]{                    
                $uiHash.Listview.Items.EditItem($Computer)
                If ($result) {
                    $Computer.Notes = "Service Restarted"
                } Else {
                    $computer.notes = ("Issue Occurred: {0}" -f $updateClient)
                } 
                $uiHash.Listview.Items.CommitEdit()
                $uiHash.Listview.Items.Refresh()
            })
            $uiHash.ProgressBar.Dispatcher.Invoke("Background",[action]{   
                $uiHash.ProgressBar.value++  
            })
            $uiHash.Window.Dispatcher.Invoke("Background",[action]{           
                #Check to see if find job
                If ($uiHash.ProgressBar.value -eq $uiHash.ProgressBar.Maximum) { 
                    $End = New-Timespan $uihash.StartTime (Get-Date)                                             
                    $uiHash.StatusTextBox.Text = ("Completed in {0}" -f $end)
                    $uiHash.RunButton.IsEnabled = $True
                    $uiHash.StartImage.Source = "$pwd\Images\Start.jpg"
                    $uiHash.CancelButton.IsEnabled = $False
                    $uiHash.CancelImage.Source = "$pwd\Images\Stop_locked.jpg"                    
                }
            })  
                
        }

        Write-Verbose ("Creating runspace pool and session states")
        $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $runspaceHash.runspacepool = [runspacefactory]::CreateRunspacePool(1, $maxConcurrentJobs, $sessionstate, $Host)
        $runspaceHash.runspacepool.Open()   

        ForEach ($Computer in $selectedItems) {
            $uiHash.Listview.Items.EditItem($Computer)
            $computer.Notes = "Pending Restart Service"
            $uiHash.Listview.Items.CommitEdit()
            $uiHash.Listview.Items.Refresh()
            #Create the powershell instance and supply the scriptblock with the other parameters 
            $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer).AddArgument($uiHash).AddArgument($Path)
           
            #Add the runspace into the powershell instance
            $powershell.RunspacePool = $runspaceHash.runspacepool
           
            #Create a temporary collection for each runspace
            $temp = "" | Select-Object PowerShell,Runspace,Computer
            $Temp.Computer = $Computer.computer
            $temp.PowerShell = $powershell
           
            #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
            $temp.Runspace = $powershell.BeginInvoke()
            Write-Verbose ("Adding {0} collection" -f $temp.Computer)
            $jobs.Add($temp) | Out-Null
        } 
    
    }    
})
#endregion

#Exit Menu
$uiHash.ExitMenu.Add_Click({
    $uiHash.Window.Close()
})
#endregion

#Start the GUI
$uiHash.Window.ShowDialog() | Out-Null