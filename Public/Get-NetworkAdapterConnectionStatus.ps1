<#
.SYNOPSIS
    Get NIC status.
.DESCRIPTION
    Get NIC status with more details then in the built-in windows command.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Get-NetworkAdapterConnectionStatus
    Get NIC status locally.
.EXAMPLE
    Get-NetworkAdapterConnectionStatus -ComputerName <Hostname>
    Get NIC status remotely.
#>

Function Get-NetworkAdapterConnectionStatus {
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]        
        [string]$ComputerName
    )
 
    $statushash = @{
        0 = "Disconnected"
        1 = "Connecting"
        2 = "Connected"
        3 = "Disconnecting"
        4 = "Hardware not present"
        5 = "Hardware disabled"
        6 = "Hardware malfunction"
        7 = "Media Disconnected"
        8 = "Authenticating"
        9 = "Authentication Succeeded"
        10 = "Authentication Failed"
        11 = "Invalid Address"
        12 = "Credentials Required"
    }
 
    $networks = Get-WmiObject -Class Win32_NetworkAdapter @PSBoundParameters
    $networkName = @{name="NetworkName";Expression={$_.Name}}
    $networkStatus = @{name="Networkstatus";Expression={$statushash[[int32]$($_.NetConnectionStatus)]}}
 
    foreach ($network in $networks) {
        $network | Select-Object $networkName, $Networkstatus
    }
}