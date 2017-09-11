$DataStamp = get-date -Format yyyyMMddTHHmmss
$logFile = '{0}-{1}.log' -f $file.fullname,$DataStamp
$AD_SetupFile="C:\temp\SetupConfig.xml" 
$INSTALLDIR="D:\AppDynamics" 
$DOTNETAGENTFOLDER="D:\AppDynamicsData"
$MSIArguments = @(
    "/i"
    ('"{0}"' -f $file.fullname)
    "/q"
    "/norestart"
    "/lv"
    $logFile
    "AD_SetupFile=$AD_SetupFile"
    "INSTALLDIR=$INSTALLDIR"
    "DOTNETAGENTFOLDER=$DOTNETAGENTFOLDER"
)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 


