<#
.SYNOPSIS
    Test connection in a loop.
.DESCRIPTION
    Test connections to an computer or an array of computers and output this in a logfile if you want.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Test-NetConnectionLoop -Destinations "Node01" 
    Test connections using ICMP-Pakets (Ping) to "Node01" with an intervall of 1s (default) one day long (default).
.EXAMPLE
    Test-NetConnectionLoop -Destinations "Node01", "Node02" -Intervall 500 -IntervallUnit ms -DurationInDays 1
    Test connections using ICMP-Pakets (Ping) to "Node01" and "Node02" with an intervall of 500ms one day long.
.EXAMPLE
    Test-NetConnectionLoop -Destinations "Node01", "Node02" -Port 3389 -DurationInDays 1
    Test connections with port 3389 (RDP) using TCP to "Node01" and "Node02" one day long.
#>

Function Test-NetConnectionLoop {
    [CmdletBinding(DefaultParameterSetName='ICMP')]
 
    param(
        [Parameter(Position=0, mandatory=$true)]
        [array] $Destinations,
 
        [Parameter(ParameterSetName="TCP", Position=1, mandatory=$false)]
        [int] $Port,
 
        [Parameter(Position=2, mandatory=$false)]
        [string] $Logfile,
 
        [Parameter(ParameterSetName="ICMP", Position=3, mandatory=$false)]
        [int] $Intervall = 1,
 
        [Parameter(ParameterSetName="ICMP", Position=4, mandatory=$false)]
        [ValidateSet("s", "ms")]
        [string] $IntervallUnit = "s",
 
        [Parameter(Position=5, mandatory=$false)]
        [int] $DurationInDays = 1
    )
 
    process {
        $EndDate = (Get-Date).AddDays($DurationInDays)
 
        while ((get-date) -le $EndDate) {
            foreach ($Destination in $Destinations) {
                If ($Port -lt 1) {
                    $Output = Test-Connection -ComputerName $Destination -Count 1 -WarningAction SilentlyContinue -AsJob
                    $JobContent = (Get-Job | Receive-Job)
                } Else {
                    $Output = Test-NetConnection -ComputerName $Destination -Port $Port -WarningAction SilentlyContinue
                }
 
                if (($Output.TcpTestSucceeded -eq $false) -or ($JobContent.ResponseTime -gt 4000)) {
                    $timestamp = get-date
                    $logtext = "$timestamp : Connection to $Destination -> FAIL"
                    If ($Logfile) {
                        Add-Content -Path $logfile -Value $logtext
                    }
                    Write-Host "$logtext"
                } else {
                    $timestamp = get-date
                    $logtext = "$timestamp : Connection to $Destination -> SUCCESS"
                    
                    If ($Logfile) {
                        Add-Content -Path $logfile -Value $logtext
                    }
                    Write-Host "$logtext"
                }
 
                If ($IntervallUnit -eq "s") {
                    Start-Sleep -Seconds $Intervall
                }
 
                If ($IntervallUnit -eq "ms") {
                    Start-Sleep -Milliseconds $Intervall
                }
 
                Get-Job | Remove-Job
            }
        }
    }
}

