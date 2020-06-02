<#
.SYNOPSIS
    Disable Windows 10 Telemetry Services/Tasks
.DESCRIPTION
    Disable Windows 10 Telemetry Services/Tasks
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
    Source: https://4sysops.com/archives/disable-windows-10-telemetry-with-a-powershell-script/
.EXAMPLE
    Disable-TelemetryOnWin10
    Disable Windows 10 Telemetry Services/Tasks on the local client
#>

Function Disable-TelemetryOnWin10 {
    process {
        #region Registry-Keys
        # Disabling Advertising ID
        $RegKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        $Value = "Enabled"
        $SvcName = "Advertising ID"
        $CheckValue = 1
        $SetData = 0
        Set-RegKey -RegKey $RegKey -Value $Value -SvcName $SvcName -CheckValue $CheckValue -SetData $SetData

        #Telemetry Disable
        $RegKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        $Value = "AllowTelemetry"
        $SvcName = "Telemetry"
        $CheckValue = 1
        $SetData = 0
        Set-RegKey -RegKey $RegKey -Value $Value -SvcName $SvcName -CheckValue $CheckValue -SetData $SetData 

        #SmartScreen Disable
        $RegKey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost\EnableWebContentEvaluation"
        $Value = "Enabled"
        $SvcName = "Smart Screen"
        $CheckValue = 1
        $SetData = 0
        Set-RegKey -RegKey $RegKey -Value $Value -SvcName $SvcName -CheckValue $CheckValue -SetData $SetData
        #endregion


        #Disabling DiagTrack Services
        Write-Host "Disabling DiagTrack Services" -ForegroundColor Green 
        Get-Service -Name DiagTrack | Set-Service -StartupType Disabled | Stop-Service
        Get-Service -Name dmwappushservice | Set-Service -StartupType Disabled | Stop-Service
        Write-Host "DiagTrack Services are disabled" -ForegroundColor Green 


        #Disabling telemetry scheduled tasks
        Write-Host "Disabling telemetry scheduled tasks" -ForegroundColor Green
        $ErrorActionPreference = 'Stop'
        $tasks = "SmartScreenSpecific", "ProgramDataUpdater", "Microsoft Compatibility Appraiser", "AitAgent", "Proxy", "Consolidator",
        "KernelCeipTask", "BthSQM", "CreateObjectTask", "Microsoft-Windows-DiskDiagnosticDataCollector", "WinSAT",
        "GatherNetworkInfo", "FamilySafetyMonitor", "FamilySafetyRefresh", "SQM data sender", "OfficeTelemetryAgentFallBack",
        "OfficeTelemetryAgentLogOn"

        $tasks | ForEach-Object {
            try {
                Get-ScheduledTask -TaskName $_ | Disable-ScheduledTask
            }
            catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] { 
                "task $($_.TargetObject) is not found"
            }
        }
    }
}