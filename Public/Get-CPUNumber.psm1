<#
.SYNOPSIS
Get the number of CPU's, Cores, logical Processors. 
 
.DESCRIPTION
Get the number of CPU's, Cores, logical Processors.
 
.NOTES
Author: Robin Hermann
 
.LINK
http://wiki.webperfect.ch
 
.EXAMPLE
Get-CPUNumber
Get the CPU infos locally.

.EXAMPLE
Get-CPUNumber -ComputerName <Hostname>
Get the CPU infos remotely.
#>

Function Get-CPUNumber {
    param (
        [String]$ComputerName = $env:COMPUTERNAME
    )

    process{
        $CPUProperty = "NumberOfCores","NumberOfLogicalProcessors"
        $NumberOfCPUs = (Get-WmiObject -class win32_processor -computername $ComputerName).Count
        If ($null -eq $NumberOfCPUs) {
            $NumberOfCPUs = 1
        }

        $NumberOfCores = (Get-WmiObject -class win32_processor -computername $ComputerName -Property $CPUProperty).NumberOfCores | Select-Object -First 1
        $NumberOfLPs = (Get-WmiObject -class win32_processor -computername $ComputerName -Property $CPUProperty).NumberOfLogicalProcessors | Select-Object -First 1
        $TotalNumberOfLPs = $NumberOfCPUs * $NumberOfLPs

        $obj1 = new-object PSObject -Property @{
            "Number of CPUs"="$NumberOfCPUs";
            "Number of Cores/CPU"="$NumberOfCores";
            "Number of logical Processors/CPU"="$NumberOfLPs";
            "Total number of logical Processors"="$TotalNumberOfLPs"
        }
        $obj1 | Select-Object "Number Of CPUs", "Number of Cores/CPU", "Number of logical Processors/CPU", "Total number of logical Processors" | Format-List
    }
}