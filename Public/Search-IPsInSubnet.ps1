<#
.SYNOPSIS
    Search/Scan an IP, hostname or subnet.
.DESCRIPTION
    Search/Scan an IP, hostname or subnet. (It is a little bit like an IP-Scanner)
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Search-IPsinSubnet -Network <"192.168.1.0">
    Search/Scan your Network "192.168.1.x".
#>


Function Search-IPsinSubnet {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [string]$Network,

        [int]$TimeoutMS = 1000
    )

    process{
        # Gather network address (must end in .0)
        #$network = read-host "Enter network address";
        $Networkcheck = $network.substring($network.length-2)
        
        if ($Networkcheck -eq ".0") {
            # Drop the .0 from the network address
            $Network = $Network.Substring(0,$Network.length-1)
        
            # Create Runspace Pool with 500 threads
            $pool = [RunspaceFactory]::CreateRunspacePool(1, 500)
            $pool.ApartmentState = "MTA"
            $pool.open()
            $runspaces = @()
            
            # The script you want run against each host
            $scriptblock = {
                # Take the IP address as a parameter
                param ([string]$ip)
                
                # Ping IP address    
                $online = Test-Connection $ip -count 1 -ea 0 
        
                # Compatibility for older OS's than Windows 10 (Some fieldnames changed in the built-in function Windows "Test-Connection")
                $OSBuildNumber = (Get-CimInstance -ClassName win32_operatingsystem).BuildNumber
                If ($OSBuildNumber -gt 14393) {
                    $TestConnectionFieldIP = "Destination"
                } Else {
                    $TestConnectionFieldIP = "Address"
                }

                # Print IP address if online
                if ($online) {
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
                        Expression = {(($_.StatusCode -eq 0) -or ($_.Status -eq "Success"))}
                    }

                    # do DNS resolution when system responds to ping
                    $DNSName = @{
                        Name = 'DNSName'
                        Expression = {
                            if (($_.StatusCode -eq 0) -or ($_.Status -eq "Success")) { 
                                if ($_.$TestConnectionFieldIP -like '*.*.*.*') {
                                    [Net.DNS]::GetHostByAddress($_.$TestConnectionFieldIP).HostName
                                } else {
                                    [Net.DNS]::GetHostByName($_.$TestConnectionFieldIP).HostName
                                }
                            }
                        }
                    }
                    # do MAC (ARP) resolution when system responds to ping
                    $MAC = @{
                        Name = 'MAC'
                        Expression = {
                            if (($_.StatusCode -eq 0) -or ($_.Status -eq "Success")) {
                                (Get-NetNeighbor -IPAddress $_.$TestConnectionFieldIP -AddressFamily IPv4).LinkLayerAddress -replace "-", ":"
                            }
                        }
                    }
                        
                    $online | Select-Object -Property $TestConnectionFieldIP, $IsOnline, $DNSName, $statusFriendlyText, $MAC | Where-Object {$_.Online -eq "True"}
                }
            }
            
            # Loop through numbers 1 to 254 
            foreach ($hostnumber in 1..254) {
                # Set full IP address
                $ip = $network + $hostnumber
        
                $runspace = [powershell]::create()
        
                # Add script block to runspace (use $null to avoid noise)
                $null = $runspace.addscript($scriptblock)
        
                # Add IP address as an argument to the scriptblock (use $null to avoid noise)
                $null = $runspace.addargument($ip)
        
                # Add/create new runspace
                $runspace.runspacepool = $pool
                $runspaces += [pscustomobject]@{pipe=$runspace; Status=$runspace.begininvoke() }
            }
            
            # Prepare the progress bar
            $currentcount = 0
            $totalcount = ($runspaces | measure-object).count
        
            # Pause until all runspaces have completed
            $table = while ($runspaces.status -ne $null) {
                $completed = $runspaces | Where-Object { $_.status.iscompleted -eq $true }
                
                # Update progress bar
                $currentcount = $currentcount + ($completed | measure-object).count
                write-progress -activity "Pinging IP Addresses..." -percentcomplete (([int]$currentcount/[int]$totalcount)*100)
                
                # Clear completed runspaces
                foreach ($runspace in $completed) {
                    $runspace.pipe.endinvoke($runspace.status)
                    $runspace.status = $null
                }
            }

            $table | Format-Table
        
            # Clean-up Runspace Pool
            $pool.close()
            $pool.dispose()
        
        } else {
            write-host "THIS $Network IS NOT A VALID NETWORK ADDRESS" -ForegroundColor Red
        }
    }
}