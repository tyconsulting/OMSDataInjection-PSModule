# .EXTERNALHELP OMSDataInjection.psm1-Help.xml
Function New-OMSDataInjection
{
  Param(
    [Parameter(ParameterSetName = 'InjectByPSObjectWithConnection', Mandatory = $true,HelpMessage = 'Please specify the OMSWorkSpace Azure Automation Connection object')]
    [Parameter(ParameterSetName = 'InjectByJSONStringWithConnection', Mandatory = $true,HelpMessage = 'Please specify the OMSWorkSpace Azure Automation Connection object')]
    [ValidateNotNullOrEmpty()]
    [Alias('Connection','c')][Object]$OMSConnection,
    
    [Parameter(ParameterSetName = 'InjectByPSObjectWithIndividualParameters', Position = 0, Mandatory = $true,HelpMessage = 'Please specify the OMS Workspace Id')]
    [Parameter(ParameterSetName = 'InjectByJSONStringWithIndividualParameters', Position = 0, Mandatory = $true,HelpMessage = 'Please specify the OMS Workspace Id')]
    [ValidateNotNullOrEmpty()]
    [Alias('WorkSpaceId')][String]$OMSWorkSpaceId,
    
    [Parameter(ParameterSetName = 'InjectByPSObjectWithIndividualParameters', Mandatory = $true,HelpMessage = 'Please specify the OMS Primary Key')]
    [Parameter(ParameterSetName = 'InjectByJSONStringWithIndividualParameters', Mandatory = $true,HelpMessage = 'Please specify the OMS Primary Key')]
    [ValidateNotNullOrEmpty()]
    [String]$PrimaryKey,
    
    [Parameter(ParameterSetName = 'InjectByPSObjectWithIndividualParameters', Mandatory = $false,HelpMessage = 'Please specify the OMS Secondary Key')]
    [Parameter(ParameterSetName = 'InjectByJSONStringWithIndividualParameters', Mandatory = $false,HelpMessage = 'Please specify the OMS Secondary Key')]
    [ValidateNotNullOrEmpty()]
    [String]$SecondaryKey,
    
    [Parameter(Mandatory = $true,HelpMessage = 'Please specify the OMS log type')]
    [ValidateNotNullOrEmpty()]
    [String]$LogType,
    
    [Parameter(Mandatory = $true,HelpMessage = 'Please specify the time stamp field')]
    [ValidateNotNullOrEmpty()]
    [Alias('TimeStampField')][String]$UTCTimeStampField,
    
    [Parameter(ParameterSetName = 'InjectByPSObjectWithIndividualParameters', Mandatory = $true,HelpMessage = 'Please specify the PSObject containing OMS data')]
    [Parameter(ParameterSetName = 'InjectByPSObjectWithConnection', Mandatory = $true,HelpMessage = 'Please specify the PSObject containing OMS data')]
    [ValidateNotNullOrEmpty()]
    [PSObject]$OMSDataObject,
    
    [Parameter(ParameterSetName = 'InjectByJSONStringWithConnection', Mandatory = $true,HelpMessage = 'Please specify the JSON format string containing OMS data')]
    [Parameter(ParameterSetName = 'InjectByJSONStringWithIndividualParameters', Mandatory = $true,HelpMessage = 'Please specify the JSON format string containing OMS data')]
    [ValidateNotNullOrEmpty()]
    [String]$OMSDataJSON
    
  )
  
  Write-Verbose 'Validate JSON format if JSON format string is specified'
  If ($PSBoundParameters.ContainsKey('OMSDataJSON'))
  {
    try {
      $OMSDataObject = ConvertFrom-Json -InputObject $OMSDataJSON 
    } Catch {
      Throw 'The input data is not in valid JSON format. InnerException: $($_.Exception.InnerException)'
      Exit -1
    }
  }
  Write-Verbose 'Valid JSON data provided.'
  
  Write-Verbose 'Validate If the PS object or the JSON input input contains the Time Stamp field'
  If ($OMSDataObject.$UTCTimeStampField -eq $null)
  {
    If ($OMSDataJSON -eq $Null)
    {
      Throw "The input object `$OMSDataObject does not contain a property for the specified Time Stamp Field '$UTCTimeStampField'."
    } else {
      Throw "The input JSON string `$OMSDataJSON does not contain a property for the specified Time Stamp Field '$UTCTimeStampField'."
    }
    
    Exit -1
  }
  Write-Verbose "'$UTCTimeStampField' is contained in the input JSON/PSObject parameter."
  Write-Verbose "'$UTCTimeStampField' value: '$($OMSDataObject.$UTCTimeStampField)'."
  If ($OMSDataObject.$UTCTimeStampField.GetType().FullName -ieq 'system.datetime')
  {
    $OMSDataObject.$UTCTimeStampField = $OMSDataObject.$UTCTimeStampField.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
  } else {
    #Validate if the Time stamp specified contains a valid datetime value
    Try 
    {
      $timestamp = ([datetime]::Parse($OMSDataObject.$UTCTimeStampField)).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
      $OMSDataObject.$UTCTimeStampField = $timestamp
    } Catch {
      Throw "The $UTCTimeStampField does not contain valid date time"
      Exit -1
    }
  }

  #Inject activity into OMS
  If ($PSBoundParameters.ContainsKey('OMSWorkSpaceId'))
  {
    $OMSConnection = @{
      'OMSWorkspaceId' = $OMSWorkSpaceId
      'PrimaryKey' = $PrimaryKey
      'SecondaryKey' = $SecondaryKey
    }
  }
  
  $OMSLogBody = ConvertTo-Json -InputObject $OMSDataObject
  $LogType = $LogType
  Publish-OMSData -OMSConnection $OMSConnection -body $OMSLogBody -LogType $LogType
}

#region private functions
Function New-Signature
{
  Param (
    [String]$OMSWorkspaceId,
    [string]$sharedKey,
    [string]$rfc1123date,
    [int]$contentLength,
    [string]$method,
    [string]$contentType,
    [string]$resource
  )
  $xHeaders = 'x-ms-date:' + $rfc1123date
  $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

  $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
  $keyBytes = [Convert]::FromBase64String($sharedKey)

  $sha256 = New-Object -TypeName System.Security.Cryptography.HMACSHA256
  $sha256.Key = $keyBytes
  $calculatedHash = $sha256.ComputeHash($bytesToHash)
  $encodedHash = [Convert]::ToBase64String($calculatedHash)
  $authorization = 'SharedKey {0}:{1}' -f $OMSWorkspaceId, $encodedHash
  $authorization
}
Function Publish-OMSData
{
  Param (
    [Object]$OMSConnection,
    [string]$body,
    [string]$LogType
  )
  $OMSWorkspaceId = $OMSConnection.OMSWorkspaceId
  $PrimaryKey = $OMSConnection.PrimaryKey
  $SecondaryKey = $OMSConnection.SecondaryKey
  
  $TimeStampField = 'LogTime'
  $method = 'POST'
  $contentType = 'application/json'
  $resource = '/api/logs'
  $rfc1123date = [DateTime]::UtcNow.ToString('r')
  $contentLength = $body.Length
  
  $uri = 'https://' + $OMSWorkspaceId + '.ods.opinsights.azure.com' + $resource + '?api-version=2016-04-01'
  $PrimarySignature = New-Signature -OMSWorkspaceId $OMSWorkspaceId -sharedKey $PrimaryKey -rfc1123date $rfc1123date -contentLength $contentLength -method $method -contentType $contentType -resource $resource
  $PrimaryHeaders = @{
    'Authorization'      = $PrimarySignature
    'Log-Type'           = $LogType
    'x-ms-date'          = $rfc1123date
    'time-generated-field' = $TimeStampField
  }
  If ($SecondaryKey.length -ne 0)
  {
      $SecondarySignature = New-Signature -OMSWorkspaceId $OMSWorkspaceId -sharedKey $PrimaryKey -rfc1123date $rfc1123date -contentLength $contentLength -method $method -contentType $contentType -resource $resource
      $SecondaryHeaders = @{
        'Authorization'      = $SecondarySignature
        'Log-Type'           = $LogType
        'x-ms-date'          = $rfc1123date
        'time-generated-field' = $TimeStampField
      }
  }
  If ($SecondaryKey.length -eq 0)
  {
    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $PrimaryHeaders -Body $body -UseBasicParsing
  } else {
    #If secondary key specified, will attempt to use if if an exception is thrown with the primary key
    try {
      $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $PrimaryHeaders -Body $body -UseBasicParsing
    } catch {
      Write-Verbose 'The primary key specified in the HybridWorkerOMS connection object is not valid. Re-trying sending request using the secondary key...'
      $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $SecondaryHeaders -Body $body -UseBasicParsing
    }
  } 
    
  if ($response.StatusCode -eq 202)
  {
    Write-Verbose 'OMS data injection accepted!'
  }
}
#endregion
