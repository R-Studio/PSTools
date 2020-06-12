<#
.SYNOPSIS
    Get free disk space of all volumes with driveletter on a remote system.
.DESCRIPTION
    Get free disk space of all volumes with driveletter on a remote system.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Get-FreeDiskSpace -ComputerName <Hostname>
    Get free disk space of all volumes with driveletter on a remote system.
#>

Function Get-FreeDiskSpace {
    [CmdletBinding()]
 
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
        [string]$ComputerName
    )
 
    process {
        If (!$ComputerName) {
            $Volumes = (Get-Volume).DriveLetter
        } else {
            $Volumes = (Get-Volume -CimSession $PSBoundParameters.Values).DriveLetter
        }
 
        Foreach ($Volume in $Volumes) {
            $Volume = $Volume + ":"
 
            Get-WMIObject Win32_Logicaldisk -filter "deviceid='$Volume'" @PSBoundParameters | Select-Object PSComputername,DeviceID,
            @{Name="SizeGB";Expression={$_.Size/1GB -as [int]}},
            @{Name="FreeGB";Expression={[math]::Round($_.Freespace/1GB,2)}}
        }
    }
}