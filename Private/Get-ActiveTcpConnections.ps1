Function Get-ActiveTcpConnections {
    [CmdletBinding()]
    [Alias()]
    [OutputType([string])]
    
    Param (

    )

    $networkObject = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()

    $networkObject.GetActiveTcpConnections() | ForEach-Object {
        $props = [PSCustomObject]@{
            Protocol          = 'TCP'
            'LocalAddress'   = $_.LocalEndPoint 
            'ForeignAddress' = Convert-NetStatRemoteEndpoint -Address $_.RemoteEndPoint.get_address().IPAddressToString -Port $_.RemoteEndPoint.get_Port()
            State             = $_.State
        }
        Write-Output $props
    }
}