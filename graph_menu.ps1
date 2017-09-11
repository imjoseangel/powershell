Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$server = 'localhost'
$systemroot = $env:SystemRoot

$Form = New-Object system.Windows.Forms.Form
$Form.Text = "RAET Services Menu"
$Form.BackColor = "#ffffff"
$Form.TopMost = $true
$Form.Icon = New-Object system.drawing.icon("C:\Users\JoseMar\Documents\Drafts\raet.ico")
$Form.Width = 375
$Form.Height = 275

$button1 = New-Object system.windows.Forms.Button
$button1.BackColor = "#dfdfdf"
$button1.Text = "Select Server"
$button1.Width = 125
$button1.Height = 30
$button1.location = new-object system.drawing.point(15,65)
$button1.Font = "Tahoma,9"
$Form.controls.Add($button1)

$button2 = New-Object system.windows.Forms.Button
$button2.BackColor = "#dfdfdf"
$button2.Text = "Services"
$button2.Width = 125
$button2.Height = 30
$button2.location = new-object system.drawing.point(15,100)
$button2.Font = "Tahoma,9"
$Form.controls.Add($button2)

$button3 = New-Object system.windows.Forms.Button
$button3.BackColor = "#dfdfdf"
$button3.Text = "Shared Folders"
$button3.Width = 125
$button3.Height = 30
$button3.location = new-object system.drawing.point(15,140)
$button3.Font = "Tahoma,9"
$Form.controls.Add($button3)

$button4 = New-Object system.windows.Forms.Button
$button4.BackColor = "#dfdfdf"
$button4.Text = "Perf Monitor"
$button4.Width = 125
$button4.Height = 30
$button4.location = new-object system.drawing.point(210,65)
$button4.Font = "Tahoma,9"
$Form.controls.Add($button4)

$button5 = New-Object system.windows.Forms.Button
$button5.BackColor = "#dfdfdf"
$button5.Text = "IIS"
$button5.Width = 125
$button5.Height = 30
$button5.location = new-object system.drawing.point(210,100)
$button5.Font = "Tahoma,9"
$Form.controls.Add($button5)

$button6 = New-Object system.windows.Forms.Button
$button6.BackColor = "#dfdfdf"
$button6.Text = "Certificates"
$button6.Width = 125
$button6.Height = 30
$button6.location = new-object system.drawing.point(210,140)
$button6.Font = "Tahoma,9"
$Form.controls.Add($button6)

$Label1 = New-Object system.windows.Forms.Label
$Label1.Text = "Server Name: "
$Label1.ForeColor = "#000000"
$Label1.AutoSize = $true
$Label1.Width = 25
$Label1.Height = 10
$Label1.location = new-object system.drawing.point(15,20)
$Label1.Font = "Calibri,10,style=Bold"
$Form.controls.Add($Label1)

$label2 = New-Object system.windows.Forms.Label
$label2.Text = $server
$label2.AutoSize = $true
$label2.ForeColor = "#8f0000"
$label2.Width = 25
$label2.Height = 10
$label2.location = new-object system.drawing.point(130,20)
$label2.Font = "Calibri,10"
$Form.controls.Add($label2)

$PictureBox1 = New-Object system.windows.Forms.PictureBox
$PictureBox1.Width = 130
$PictureBox1.ImageLocation = "C:\Users\JoseMar\Documents\Drafts\raet_logo.png"
$PictureBox1.Height = 80
$PictureBox1.Width = 130
$PictureBox1.Height = 80
$PictureBox1.location = new-object system.drawing.point(245,180)
$Form.controls.Add($PictureBox1)

$button1.Add_Click(
        {
            $global:server = [Microsoft.VisualBasic.Interaction]::InputBox("Enter a Server name", "Server", $server)
            $label2.Text = $server

        }
    )

$button2.Add_Click(
            {
                Start-Process -FilePath services.msc -ArgumentList /computer:$server
            }
        )

$button3.Add_Click(
            {
                Start-Process -FilePath fsmgmt.msc -ArgumentList /computer:$server
            }
        )

$button4.Add_Click(
            {
                Start-Process -FilePath perfmon.msc -ArgumentList /computer:$server
            }
        )

$button5.Add_Click(
            {
                Start-Process -FilePath $systemroot\system32\inetsrv\iis.msc  -ArgumentList /computer:$server
            }
        )

$button6.Add_Click(
            {
                Start-Process -FilePath certlm.msc  -ArgumentList /computer:$server
            }
        )

[void]$Form.ShowDialog()
$Form.Dispose()
