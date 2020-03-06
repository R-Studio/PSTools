<#
.SYNOPSIS
    Get all mountpoints and all UserProfileDisks (Roaming Profiles as a VHDX).
.DESCRIPTION
    This function is usefull to get how much free disk space is available in UserProfileDisks.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Get-MountPointsAndUserDisks
    Get all mountpoints and all UserProfileDisks of the local system.
#>

Function Get-MountPointsAndUserDisks {
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]    
        [string] $ComputerName
    )
 
    Get-WmiObject Win32_Volume -Filter "DriveType='3'" @PSBoundParameters | ForEach-Object {
        New-Object PSObject -Property @{
            Name = $_.Name
            Label = $_.Label
            FreeSpace_GB = ([Math]::Round($_.FreeSpace /1GB,2))
            TotalSize_GB = ([Math]::Round($_.Capacity /1GB,2))
        }
    }
}