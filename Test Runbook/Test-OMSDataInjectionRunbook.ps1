#requires -Version 3 -Modules OMSDataInjection
$LogName = 'OMSTestData'
$UTCTimeStampField = 'LogTime'
$Now = [Datetime]::UtcNow
$ISONOw = "{0:yyyy-MM-ddThh:mm:ssZ}" -f $now
#OMS connection object
$OMSConnectionName = 'OMSConnection'
$OMSConnection = Get-AutomationConnection -Name $OMSConnectionName

#region Test PS object input
$ObjProperties = @{
  Computer = $env:COMPUTERNAME
  Username = $env:USERNAME
  Message  = 'This is a test message injected by the OMSDataInjection module via an Azure Automation runbook. Input data type: PSObject'
  LogTime  = $Now
}
$OMSDataObject = New-Object -TypeName PSObject -Property $ObjProperties

#Inject data
Write-Output "Injecting PSobject data into OMS"
$InjectData = New-OMSDataInjection -OMSConnection $OMSConnection -LogType $LogName -UTCTimeStampField $UTCTimeStampField -OMSDataObject $OMSDataObject -Verbose
#endregion

#region test JSON input
$OMSDataJSON = @"
{
    "Username":  "administrator",
    "Message":  "This is a test message injected by the OMSDataInjection module via an Azure Automation runbook. Input data type: JSON",
    "LogTime":  "$ISONOw",
    "Computer":  "$env:COMPUTERNAME"
}
"@
Write-Output "Injecting JSON data into OMS"
$InjectData = New-OMSDataInjection -OMSConnection $OMSConnection -LogType $LogName -UTCTimeStampField $UTCTimeStampField -OMSDataJSON $OMSDataJSON -verbose
#endregion
