Import-Module 'C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1'

ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath 'C:\Users\josea\Desktop\Plantilla Windows 2003 R2 x64 SP\Plantilla Windows 2003 R2 x64 SP.vmdk' -DestinationLiteralPath C:\Users\josea\Desktop\ -VhdType FixedHardDisk -VhdFormat vhd