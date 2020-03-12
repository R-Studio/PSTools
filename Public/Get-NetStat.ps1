<#
.SYNOPSIS
    Get information about TCP & UDP connections.
.DESCRIPTION
    This function a recreation of the "netstat.exe" functionality in PowerShell.
.NOTES
    Original Author: Josh Rickard (MSAdministrator)
    Author: Robin Hermann
.LINK
    https://github.com/MSAdministrator/PSNetStat
.EXAMPLE
    Get-NetStat
    Get information about TCP & UDP connections.
.EXAMPLE
    Get-NetStat -ListeningProtocol UDP
    Get information about all UDP connections.
.EXAMPLE
    Get-NetStat -AllConnections
    Get information about all TCP & UDP connections.
#>

function Get-NetStat {
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    
    Param (
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=0)]
        [switch]$AllConnections,

        [ValidateSet('TCP', 'UDP')]
        $ListeningProtocol
    )

    if ($ListeningProtocol) {
        switch($ListeningProtocol) {
            'TCP'   { Get-ActiveTcpListeners | Write-Output }
            'UDP'   { Get-ActiveUdpListeners | Write-Output }
            default { Get-ActiveTcpListeners | Write-Output
                      Get-ActiveUdpListeners | Write-Output }
        }
    } elseif ($AllConnections.IsPresent) {
        Get-ActiveTcpListeners | Write-Output
        Get-ActiveUdpListeners | Write-Output
        Get-ActiveTcpConnections | Write-Output
    } else {
        Get-ActiveTcpConnections | Write-Output
    }
}