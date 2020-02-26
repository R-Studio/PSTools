Function Set-DNSPTRRecord {
    [CmdletBinding()]
    #$ErrorActionPreference = "SilentlyContinue" 
 
    param (
        [Parameter(Position=0,mandatory=$true,HelpMessage="Type Forward lookup zone name in format - DOMAIN.NAME")]
        [string]$ForwardZone,
        [Parameter(Position=1,mandatory=$true,HelpMessage="Reverse lookup zone name in format - 1.16.172.in-addr.arpa")]
        [string]$ReverseZone
    )
 
    process {
        $DomainController = Get-ADDomainController | Select-Object -ExpandProperty Name 
        $Records = Get-DnsServerResourceRecord -ComputerName $DomainController -ZoneName $ForwardZone -RRType A | Where-Object {$_.HostName -notlike "*DnsZones*" -and $_.HostName -notlike "*@*"} | Select RecordData,Hostname 
 
        foreach ($Record in $Records) { 
            $Domain = ($env:USERDNSDOMAIN.ToString().ToLower())
            $IPAddress = $($Record.RecordData.IPv4Address).ToString() 
            $SplitedIP = $IPAddress.Split(".")[3] 
            $IPstring = $SplitedIP.ToString() 
            $HostName = $($Record.HostName).ToString() 
            $FQDN = "$HostName."+"$Domain" 
            Add-DnsServerResourceRecordPtr -Name $IPstring -ZoneName $ReverseZone -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName $FQDN -ComputerName $DomainController
        } 
    }
}