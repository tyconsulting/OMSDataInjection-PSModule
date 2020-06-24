#requires -Version 3 -Modules OMSDataInjection

$LogName = 'OMSTestData'
$UTCTimeStampField = 'LogTime'
$Now = [Datetime]::UtcNow
$ISONow = "{0:yyyy-MM-ddThh:mm:ssZ}" -f $now
#Change the OMSWorkspaceId
$OMSWorkSpaceId = Read-Host -Prompt 'Enter the workspace Id'
$PrimaryKey = Read-Host -Prompt 'Enter the primary key'
$SecondaryKey = Read-Host -Prompt 'Enter the secondary key'
$AzureResourceId = Read-Host -Prompt 'Enter optional Azure resource Id to be associated to the log'

#region Test PS object input
$ObjProperties = @{
  Computer = $env:COMPUTERNAME
  Username = $env:USERNAME
  Message  = 'This is a test message injected by the OMSDataInjection module. Input data type: PSObject'
  LogTime  = $Now
}
$OMSDataObject = New-Object -TypeName PSObject -Property $ObjProperties

#Inject data
Write-Output "Injecting PSobject data into OMS"
$params = @{
  'OMSWorkSpaceId' = $OMSWorkSpaceId
  'PrimaryKey' = $PrimaryKey
  'LogType' = $LogName
  'UTCTimeStampField' = 'LogTime'
  'OMSDataObject' = $OMSDataObject
}
If ($SecondaryKey.Length -gt 0)
{
  $params.Add('SecondaryKey', $SecondaryKey)
}
if ($AzureResourceId.length -gt 0)
{
  $params.Add('AzureResourceId', $AzureResourceId)
}
Write-output $params
$InjectData = New-OMSDataInjection @params -Verbose
#endregion

#region test JSON input
#Placing the Log Analytics Workspace ID and primary key into a hashtable
$OMSConnection = @{
  OMSWorkSpaceId = $OMSWorkSpaceId
  PrimaryKey = $PrimaryKey
}
$OMSDataJSON = @"
{
    "Username":  "$env:USERNAME",
    "Message":  "This is a test message injected by the OMSDataInjection module. Input data type: JSON",
    "LogTime":  "$ISONow",
    "Computer":  "$env:COMPUTERNAME"
}
"@
Write-Output "Injecting JSON data into OMS"

$InjectData = New-OMSDataInjection -OMSConnection $OMSConnection -LogType $LogName -UTCTimeStampField 'LogTime' -OMSDataJSON $OMSDataJSON -verbose
#endregion
