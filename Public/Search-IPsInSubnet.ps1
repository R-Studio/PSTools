
<#
.SYNOPSIS
    Search/Scan an IP, hostname or subnet.
.DESCRIPTION
    Search/Scan an IP, hostname or subnet. (It is a little bit like an IP-Scanner)
.NOTES
    Author: Robin Hermann
    Based on the function "Test-OnlineFast" from PSConf.
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Search-IPsinSubnet -Subnet <"192.168.1.">
    Search/Scan your subnet "192.168.1.x".
.EXAMPLE
    Search-IPsinSubnet -ComputerName <"hostname">
    Search/Scan your host.
#>

Function Search-IPsinSubnet {
    param(
        # make parameter pipeline-aware
        [Parameter(ParameterSetName='Subnet', Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [string]$Subnet,

        [Parameter(ParameterSetName='Single', Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [string[]]$ComputerName,

        [int]$TimeoutMS = 1000
    )

    begin {
        # use this to collect computer names that were sent via pipeline
        [Collections.ArrayList]$bucket = @()
    
        # choose only the subnet
        If ($Subnet) {
            $Subnet = [regex]::matches($Subnet, '(\d{1,3}\.\d{1,3}\.\d{1,3})').captures.groups[0].value
        }

        # hash table with error code to text translation
        $StatusCode_MappingTable = @{
            0 = 'Success'
            11001 = 'Buffer Too Small'
            11002 = 'Destination Net Unreachable'
            11003 = 'Destination Host Unreachable'
            11004 = 'Destination Protocol Unreachable'
            11005 = 'Destination Port Unreachable'
            11006 = 'No Resources'
            11007 = 'Bad Option'
            11008 = 'Hardware Error'
            11009 = 'Packet Too Big'
            11010 = 'Request Timed Out'
            11011 = 'Bad Request'
            11012 = 'Bad Route'
            11013 = 'TimeToLive Expired Transit'
            11014 = 'TimeToLive Expired Reassembly'
            11015 = 'Parameter Problem'
            11016 = 'Source Quench'
            11017 = 'Option Too Big'
            11018 = 'Bad Destination'
            11032 = 'Negotiating IPSEC'
            11050 = 'General Failure'
        }
    
        # hash table with calculated property that translates
        # numeric return value into friendly text

        $statusFriendlyText = @{
            # name of column
            Name = 'Status'
            # code to calculate content of column
            Expression = { 
                # take status code and use it as index into
                # the hash table with friendly names
                # make sure the key is of same data type (int)
                $StatusCode_MappingTable[([int]$_.StatusCode)]
            }
        }

        # calculated property that returns $true when status -eq 0
        $IsOnline = @{
            Name = 'Online'
            Expression = {$_.StatusCode -eq 0}
        }

        # do DNS resolution when system responds to ping
        $DNSName = @{
            Name = 'DNSName'
            Expression = {
                if ($_.StatusCode -eq 0) { 
                    if ($_.Address -like '*.*.*.*') {
                        [Net.DNS]::GetHostByAddress($_.Address).HostName
                    } else {
                        [Net.DNS]::GetHostByName($_.Address).HostName
                    }
                }
            }
        }
        # do MAC (ARP) resolution when system responds to ping
        $MAC = @{
            Name = 'MAC'
            Expression = {
                if ($_.StatusCode -eq 0) {
                    (Get-NetNeighbor -IPAddress $_.Address -AddressFamily IPv4).LinkLayerAddress -replace "-", ":"
                }
            }
        }
    }
    
    process {
        # iteration through the subnet
        If ($Subnet) {$ComputerName =  1..254 | ForEach-Object {$Subnet + "." + $_}}

        # add each computer name to the bucket
        # we either receive a string array via parameter, or the process block runs multiple times when computer names are piped    
        $ComputerName | ForEach-Object {$null = $bucket.Add($_)}
    }
    
    end {
        # convert list of computers [array] into a WMI query string
        $query = $bucket -join "' or Address='"
        
        # add metadata to property names for a greater table view (cosmetics)
        $TableSize = @{Expression={$_.Address}; Name="Address"; Width=15},
                     @{Expression={$_.Online}; Name="Online"; Width=7},
                     @{Expression={$_.DNSName}; Name="DNSName"; Width=25},
                     @{Expression={$_.Status}; Name="Status"; Width=35},
                     @{Expression={$_.MAC}; Name="MAC"; Width=20}

        Get-CimInstance -Class Win32_PingStatus -Filter "(Address='$query') and timeout=$TimeoutMS" |
        Select-Object -Property Address, $IsOnline, $DNSName, $statusFriendlyText, $MAC | 
        Format-Table -Property $TableSize
    }
}