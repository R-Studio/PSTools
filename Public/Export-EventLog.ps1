<#
.SYNOPSIS
    Export traditional Windows Eventlogs.
.DESCRIPTION
    Export traditional Windows Eventlogs to an .EVT file.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Export-EventLog -LogName System -Destinaton "C:\Temp" -ComputerName "HOST01"
    This example exports the EventLog "System" to "C:\Temp" on the host "HOST01"
#>

function Export-EventLog {
    param (
        [Parameter(Mandatory=$true, Position=0, HelpMessage="Add Name of the Logfile (System, Application, etc) -> Only traditional Windows Eventlogs are supported")]
        [string]$LogName,

        [Parameter(Mandatory=$true, Position=0, HelpMessage="Add Path, needs to end with a backslash")]
        [string]$Destination,

        [Parameter(Mandatory=$false, Position=0)]
        [string]$ComputerName = $env:COMPUTERNAME
    )

    process{
        $ExportFileName = $LogName + "-"+ $ComputerName + "-" + (Get-Date -Format ddMMyyyy) + ".evt"
        $logFile = Get-WmiObject Win32_NTEventlogFile -ComputerName $ComputerName | Where-Object {$_.LogfileName -eq $LogName}
        $logFile.backupeventlog($Destination + $ExportFileName) | Out-Null

        Write-Host "SUCCESS: The EventLog $LogName is exported to $Destination on $ComputerName" -ForegroundColor Green
        Write-Host "SUCCESS: Open Explorer with the path to the exported file..." -ForegroundColor Gray

        $FormatedDestination = $Destination -replace ":", "$"
        Invoke-Item \\$ComputerName\$FormatedDestination
    }
}



