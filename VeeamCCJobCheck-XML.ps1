<#
    .SYNOPSIS
    This script checks the status of all active Veeam Backup Cloud Connect jobs on a backup server.
    It collects detailed information and creates an XML file per backupjob as output.

    .INPUTS
    None

    .OUTPUTS
    The script creates a XML file formated for PRTG.

    .LINK
    https://raw.githubusercontent.com/tn-ict/Public/master/Disclaimer/DISCLAIMER

    .NOTES
    Author  : Andreas Bucher
    Version : 0.0.1
    Purpose : XML part of the PRTG-Sensor VeeamCCJobCheck

    .EXAMPLE
    Run this script with task scheduler use powershell.exe as program and the following parameters:
    -NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File "C:\Script\VeeamCCJobCheck-XML.ps1"
    This will place a file in C:\Temp\VeeamResults where it can be retreived by the PRTG sensor
#>
#----------------------------------------------------------[Declarations]----------------------------------------------------------
# Include
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# General parameters
$nl               = [Environment]::NewLine
$resultFolder     = "C:\Temp\VeeamResults"

# PRTG parameters
$WarningLevel = 24 # Warninglevel in hours for last backup session
$ErrorLevel   = 36 # Errorlevel in hours for last backup session

# Define JobResult object and parameters
$JobResult = [PSCustomObject]@{
    Name     = ""
    Desc     = ""
    Value    = 0
    Text     = ""
    Warning  = 0
    Error    = 0
    VMCount  = 0
    Quota    = 0
    Used     = 0
    Free     = 0
    FreePerc = 0
    LastJob  = (Get-Date)
}

#-----------------------------------------------------------[Functions]------------------------------------------------------------
# Export XML
function Set-XMLContent {
    param(
        $JobResult
    )

    # Create XML-Content
    $result= ""
    $result+= '<?xml version="1.0" encoding="UTF-8" ?>' + $nl
    $result+= "<prtg>" + $nl

    $result+=   "<Error>$($JobResult.Error)</Error>" + $nl
    $result+=   "<Text>$($JobResult.Text)</Text>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>Status</channel>" + $nl
    $result+=   "  <value>$($JobResult.Value)</value>" + $nl
    $result+=   "  <Warning>$($JobResult.Warning)</Warning>" + $nl
    $result+=   "  <LimitMaxWarning>2</LimitMaxWarning>" + $nl
    $result+=   "  <LimitMaxError>3</LimitMaxError>" + $nl
    $result+=   "  <LimitMode>1</LimitMode>" + $nl
    $result+=   "  <showChart>1</showChart>" + $nl
    $result+=   "  <showTable>1</showTable>" + $nl
    $result+=   "</result>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>Anzahl VMs</channel>" + $nl
    $result+=   "  <value>$($JobResult.VMCount)</value>" + $nl
    $result+=   "  <showChart>1</showChart>" + $nl
    $result+=   "  <showTable>1</showTable>" + $nl
    $result+=   "</result>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>Quota</channel>" + $nl
    $result+=   "  <value>$($JobResult.Quota)</value>" + $nl
    $result+=   "  <Float>1</Float>" + $nl
    $result+=   "  <DecimalMode>Auto</DecimalMode>" + $nl
    $result+=   "  <CustomUnit>GB</CustomUnit>" + $nl
    $result+=   "  <showChart>1</showChart>" + $nl
    $result+=   "  <showTable>1</showTable>" + $nl
    $result+=   "</result>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>Belegt</channel>" + $nl
    $result+=   "  <value>$($JobResult.Used)</value>" + $nl
    $result+=   "  <Float>1</Float>" + $nl
    $result+=   "  <DecimalMode>Auto</DecimalMode>" + $nl
    $result+=   "  <CustomUnit>GB</CustomUnit>" + $nl
    $result+=   "  <showChart>1</showChart>" + $nl
    $result+=   "  <showTable>1</showTable>" + $nl
    $result+=   "</result>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>Frei</channel>" + $nl
    $result+=   "  <value>$($JobResult.Free)</value>" + $nl
    $result+=   "  <Float>1</Float>" + $nl
    $result+=   "  <DecimalMode>Auto</DecimalMode>" + $nl
    $result+=   "  <CustomUnit>GB</CustomUnit>" + $nl
    $result+=   "  <showChart>1</showChart>" + $nl
    $result+=   "  <showTable>1</showTable>" + $nl
    $result+=   "</result>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>Frei %</channel>" + $nl
    $result+=   "  <value>$($JobResult.FreePerc)</value>" + $nl
    $result+=   "  <Float>1</Float>" + $nl
    $result+=   "  <DecimalMode>Auto</DecimalMode>" + $nl
    $result+=   "  <CustomUnit>%</CustomUnit>" + $nl
    $result+=   "  <showChart>1</showChart>" + $nl
    $result+=   "  <showTable>1</showTable>" + $nl
    $result+=   "  <LimitMinWarning>10</LimitMinWarning>" + $nl
    $result+=   "  <LimitWarningMsg>Noch 10% freier Speicher</LimitWarningMsg>" + $nl
    $result+=   "  <LimitMinError>5</LimitMinError>" + $nl
    $result+=   "  <LimitErrorMsg>Noch 5% freier Speicher</LimitErrorMsg>" + $nl
    $result+=   "  <LimitMode>1</LimitMode>" + $nl
    $result+=   "</result>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>Stunden seit letzem Job</channel>" + $nl
    $result+=   "  <value>$($JobResult.LastJob)</value>" + $nl
    $result+=   "  <CustomUnit>h</CustomUnit>" + $nl
    $result+=   "  <showChart>1</showChart>" + $nl
    $result+=   "  <showTable>1</showTable>" + $nl
    $result+=   "  <LimitMaxWarning>$WarningLevel</LimitMaxWarning>" + $nl
    $result+=   "  <LimitWarningMsg>Backup-Job älter als 24h</LimitWarningMsg>" + $nl
    $result+=   "  <LimitMaxError>$ErrorLevel</LimitMaxError>" + $nl
    $result+=   "  <LimitErrorMsg>Backup-Job älter als 36h</LimitErrorMsg>" + $nl
    $result+=   "  <LimitMode>1</LimitMode>" + $nl
    $result+=   "</result>" + $nl

    $result+= "</prtg>" + $nl

    # Write XML-File
    if(-not (test-path $resultFolder)){ New-Item -Path $resultFolder -ItemType Directory }
    $xmlFilePath = "$resultFolder\$($JobResult.Name).xml"
    $result | Out-File $xmlFilePath -Encoding utf8

}

# Check backupjob status
function Get-JobState {
    param(
        $Job
    )

    # Job details
    $JobResult.Name    = $Job.Name
    $JobResult.Desc    = $Job.Description
    $JobResult.VMCount = $Job.VMCount
    if (-not $Job.LastResult) {
        $JobResult.LastJob = 0
    }
    else {
        $JobResult.LastJob = [Math]::Round((New-TimeSpan -Start $Job.LastActive -End (Get-Date)).TotalHours,0)
    }
    
    # Get job results and define result parameters
    if     ($Job.LastResult -eq "Success") { $JobResult.Value = 1; $JobResult.Warning = 0; $JobResult.Error = 0; $JobResult.Text = "BackupJob $($JobResult.Name) - $($JobResult.Desc) erfolgreich" }
    elseif ($Job.LastResult -eq "Warning") { $JobResult.Value = 2; $JobResult.Warning = 1; $JobResult.Error = 0; $JobResult.Text = "BackupJob $($JobResult.Name) - $($JobResult.Desc) Warnung. Bitte prüfen" }
    elseif ($Job.LastResult -eq "Failed")  { $JobResult.Value = 3; $JobResult.Warning = 0; $JobResult.Error = 1; $JobResult.Text = "BackupJob $($JobResult.Name) - $($JobResult.Desc) fehlerhaft" }
    elseif (-not $Job.LastResult)          { $JobResult.Value = 2; $JobResult.Warning = 1; $JobResult.Error = 0; $JobResult.Text = "BackupJob $($JobResult.Name) - $($JobResult.Desc) läuft noch" }
    else                                   { $JobResult.Value = 3; $JobResult.Warning = 0; $JobResult.Error = 1; $JobResult.Text = "BackupJob $($JobResult.Name) - $($JobResult.Desc) unbekannter Fehler" }

    Return $JobResult
}

# Get session details
function Get-Resources {
    param (
        $Job
    )

    $JobResult.Quota    = 0
    $JobResult.Used     = 0
    $JobResult.Free     = 0
    $JobResult.FreePerc = 0

    if ($Job.Resources.RepositoryQuota)     {$JobResult.Quota    = [Math]::Round($Job.Resources.RepositoryQuota/1KB,1)}
    if ($Job.Resources.UsedSpace)           {$JobResult.Used     = [Math]::Round($Job.Resources.UsedSpace/1KB,1)}
    if ($Job.Resources.UsedSpace)           {$JobResult.Free     = [Math]::Round(($Job.Resources.RepositoryQuota - $Job.Resources.UsedSpace)/1KB,1)}
    if ($Job.Resources.UsedSpacePercentage) {$JobResult.FreePerc = [Math]::Round((100 - $Job.Resources.UsedSpacePercentage),1)}

    Return $JobResult

}
#-----------------------------------------------------------[Execute]------------------------------------------------------------
# Autouptade Script
# Get Backup Jobs 
$Tenants = Get-VBRCloudTenant | where-object { $_.Enabled -eq $true }

#### Get Backup Job details #####################################################################################################
foreach($item in $Tenants)  { 

    $JobResult = Get-JobState -Job $item
    $JobResult = Get-Resources -Job $item

    Set-XMLContent -JobResult $JobResult 

}