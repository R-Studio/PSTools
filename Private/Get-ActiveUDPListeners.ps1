Function Get-ActiveUdpListeners {
    [CmdletBinding()]
    [Alias()]
    [OutputType([string])]

    Param (
        
    )

    $networkObject = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()

    $networkObject.GetActiveUdpListeners() | ForEach-Object {
        $props = [PSCustomObject]@{
            Protocol          = 'UDP'
            'LocalAddress'   = "$($_.get_Address().IPAddressToString):$($_.get_Port())"
            'ForeignAddress' = Convert-NetStatRemoteEndpoint -Address $_.get_address().IPAddressToString -Port $_.get_Port()
            State             = 'LISTENING'
        }
        Write-Output $props
    }
}