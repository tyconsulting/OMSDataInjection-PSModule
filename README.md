# OMSDataInjection PowerShell Module

## Description
The OMSDataInjection PowerShell module provides abilities to inject custom data into Microsoft Operations Management Suite (OMS) using it's HTTP data Collector API. This module also provides an Azure Automation / SMA connection type called 'OMSWorkspace', so it can be used in automation runbooks.

## Install Instruction
### Install from PowerShell Gallery
Install-module OMSDataInjection

### Manually Install
Download this module from github, and place the OMSDataInjection module folder to 'C:\Program Files\WindowsPowerShell\Modules'

### Download from PowerShell Gallery
Find-Module OMSDataInjection | Save-Module -Force -Path 'C:\Temp'

## PowerShell functions
### New-OMSDataInjection
Injecting custom data into Microsoft Operations Management Suite (OMS) Log Analytics using its HTTP Data Collector API.

Use Get-Help New-OMSDataInjection -Full to access the help file for this function.

Injecting data using JSON formatted string by specifying the OMSWorkspace Azure Automation / SMA connection object (to be used in a runbook)

## Update History

### Version 1.3.0

* Added support for adding Azure Resource Id to the log entry

### Version 1.2.0

* Updated injection result error handling to reflect the change of the OMS HTTP Data Collector API response code for successful injection.
* Changed the UTCTimeGenerated input parameter from mandatory to optional. When it is not specified, the injection time will be used for the TimeGenerated field in OMS log entry.

### Version 1.1.1

* Updated the module to allow bulk injection.

### Version 1.0.1

* Initial release

## Additional information:

### PowerShell Gallery:
https://www.powershellgallery.com/packages/OMSDataInjection

### OMSDataInjection PowerShell module Blog Post:
http://blog.tyang.org/2016/08/31/powershell-modul…ta-collector-api/

### OMS Log Analytics HTTP Data Collector API Documentation
https://azure.microsoft.com/en-us/documentation/articles/log-analytics-data-collector-api/

### OMS Log Analytics HTTP Data Collector blog post from OMS Product Group
https://blogs.technet.microsoft.com/msoms/2016/08/30/http-data-collector-api-send-us-data-from-space-or-anywhere/
