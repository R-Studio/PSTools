<#
.SYNOPSIS
Disk Space Usage of all Files between a specified time period.
 
.DESCRIPTION
Disk Space Usage of all Files between a specified time period.
 
.NOTES
Author: Robin Hermann
 
.LINK
http://wiki.webperfect.ch
 
.EXAMPLE
Get-SumOfAllFiles -Path "C:\ProgramData\Veeam\Backup" -TimePeriodToNow -30
Disk space usage of all files under a specified path with a creation-time between now and 30 days in the past.
 
.EXAMPLE
Get-SumOfAllFiles -Path "\\<hostname>\c$\ProgramData\Veeam\Backup" -TimePeriodToNow -30 -Unit KB
Disk space usage of all files under a specified remote path with a creation-time between now and 30 days in the past in KB.
#>
 
 
Function Get-SumOfAllFiles {
    [CmdletBinding()]
 
    Param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
        [string] $Path,
        [Parameter(Mandatory=$false, Position=1)]
        [int] $TimePeriodToNow,
        [Parameter(Mandatory=$false, Position=2)]
        [string] $Unit
    )
 
    Process {
        $SumLastFilesSizes = Get-ChildItem -Path $Path -File -Recurse | Where-Object {$_.CreationTime -gt ((Get-Date).AddDays($TimePeriodToNow))} | Measure-Object -Sum Length
 
        If ($Unit -eq "GB") {
            $SumLastFilesSizesInGB = ((($SumLastFilesSizes).Sum)/1024/1024/1024)
            Write-Host "$SumLastFilesSizesInGB GB"
        } ElseIf ($Unit -eq "MB") {
            $SumLastFilesSizesInMB = ((($SumLastFilesSizes).Sum)/1024/1024)
            Write-Host "$SumLastFilesSizesInMB MB"
        } ElseIf ($Unit -eq "KB") {
            $SumLastFilesSizesInKB = ((($SumLastFilesSizes).Sum)/1024)
            Write-Host "$SumLastFilesSizesInKB KB"
        } ElseIf ($Unit -eq "B") {
            $SumLastFilesSizesInB = ($SumLastFilesSizes).Sum
            Write-Host "$SumLastFilesSizesInB Bytes"
        } Else {
            $SumLastFilesSizesInGB = ((($SumLastFilesSizes).Sum)/1024/1024/1024)
            Write-Host "$SumLastFilesSizesInGB GB"
        }
    }
}