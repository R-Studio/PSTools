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
    [Parameter(Position=0,mandatory=$true)]
    [string] $ComputerName
    )
 
    process {
        $Volumes = (Get-Volume -CimSession $ComputerName).DriveLetter
 
        Foreach ($Volume in $Volumes) {
            $Volume = $Volume + ":"
 
            Get-WMIObject Win32_Logicaldisk -filter "deviceid='$Volume'" -ComputerName $ComputerName | Select-Object PSComputername,DeviceID,
            @{Name="SizeGB";Expression={$_.Size/1GB -as [int]}},
            @{Name="FreeGB";Expression={[math]::Round($_.Freespace/1GB,2)}}
        }
    }
}