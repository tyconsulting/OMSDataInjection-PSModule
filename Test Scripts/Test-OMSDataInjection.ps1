#requires -Version 2 -Modules OMSDataInjection
$LogName = 'OMSTestData'
$UTCTimeStampField = 'LogTime'
#Change the OMSWorkspaceId
$OMSWorkSpaceId = 'f778ff56-49a4-40e4-9c73-dd1dc47a0d73'
$PrimaryKey = Read-Host -Prompt 'Enter the primary key'
#region Test PS object input
$ObjProperties = @{
  Computer = $env:COMPUTERNAME
  Username = $env:USERNAME
  Message  = 'This is a test message injected by the OMSDataInjection module. Input data type: PSObject'
  LogTime  = [Datetime]::UtcNow
}
$OMSDataObject = New-Object -TypeName PSObject -Property $ObjProperties

$OMSDataObject | Format-List *
#Inject data
$InjectData = New-OMSDataInjection -OMSWorkSpaceId $OMSWorkSpaceId -PrimaryKey $PrimaryKey -LogType $LogName -UTCTimeStampField 'LogTime' -OMSDataObject $OMSDataObject -Verbose
#endregion

#region test JSON input
#Change the OMSWorkspaceId, primary key and secondary key in the hashtable
$OMSConnection = @{
  OMSWorkSpaceId = 'f778ff56-49a4-40e4-9c73-dd1dc47a0d73'
  PrimaryKey = '<primary key>'
  SecondaryKey = '<secondary key>'
}
$OMSDataJSON = @"
{
    "Username":  "administrator",
    "Message":  "This is a test message injected by the OMSDataInjection module. Input data type: JSON",
    "LogTime":  "Tuesday, 28 June 2016 9:08:15 PM",
    "Computer":  "SERVER01"
}
"@
$InjectData = New-OMSDataInjection -OMSConnection $OMSConnection -LogType $LogName -UTCTimeStampField 'LogTime' -OMSDataJSON $OMSDataJSON -verbose
#endregion