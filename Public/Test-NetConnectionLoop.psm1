Function Test-ConnectionLoop {
    [CmdletBinding()]
 
    param(
    [Parameter(Position=0,mandatory=$true)]
    [array] $Destinations,
 
    [Parameter(Position=1,mandatory=$false)]
    [int] $Port,
 
    [Parameter(Position=2,mandatory=$false)]
    [string] $Logfile,
 
    [Parameter(Position=3,mandatory=$true)]
    [int] $Intervall,
 
    [Parameter(Position=4,mandatory=$true)]
    [string] $IntervallUnit,
 
    [Parameter(Position=5,mandatory=$true)]
    [int] $DurationInDays
    )
 
    process {
        $EndDate = (Get-Date).AddDays($DurationInDays)
 
        while ((get-date) -le $EndDate){
 
            foreach ($Destination in $Destinations){
                If ($Port -lt 1) {
                    $Output = Test-Connection -ComputerName $Destination -Count 1 -WarningAction SilentlyContinue -AsJob
                    $JobContent = (Get-Job | Receive-Job)
                } Else {
                    $Output = Test-NetConnection -ComputerName $Destination -Port $Port -WarningAction SilentlyContinue
                }
 
                if (($Output.TcpTestSucceeded -eq $false) -or ($JobContent.ResponseTime -gt 4000)) {
                    $timestamp = get-date
                    $logtext =  "$timestamp : Connection to $Destination -> FAIL"
                    If ($Logfile) {
                        Add-Content -Path $logfile -Value $logtext
                    }
                    Write-Host "$logtext"
                } else {
                    $timestamp = get-date
                    $logtext =  "$timestamp : Connection to $Destination -> SUCCESS"
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