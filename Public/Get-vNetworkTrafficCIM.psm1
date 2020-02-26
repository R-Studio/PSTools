<#
.Synopsis
   Get-vNetworkTrafficCIM
.DESCRIPTION
   Shows the Traffic of the vNICs of the VMs on a Hyper-V Node
.EXAMPLE
   Get-vNetworkTrafficCIM -ComputerName <ComputerName>
.EXAMPLE
   Get-vNetworkTrafficCIM -ComputerName HyperVNode01 -VMName VM01 -Unit MB/s -SortBy Adapter
#>
 
Function Get-vNetworkTrafficCIM {
    [CmdletBinding()]
 
    param(
        [Parameter(Position=0,mandatory=$false,HelpMessage="ComputerName of the remote Hyper-V Node")]
        [string] $ComputerName = $env:COMPUTERNAME,
 
        [Parameter(Position=1,mandatory=$false,HelpMessage="VMName")]
        [string] $VMName,
 
        [Parameter(Position=2,mandatory=$false,HelpMessage="Unit/sec")]
        [ValidateSet('MB/s','KB/s')]
        [string] $Unit= "MB/s",
 
        [Parameter(Position=3,mandatory=$false,HelpMessage="Sort by")]
        [ValidateSet('Adapter','AllTraffic','Receive','Sent')]
        [string] $SortBy = "AllTraffic"
    )
 
 
    process {
        If ($VMName -eq $null) {
            $WMICounters = (Get-CimInstance "Win32_PerfFormattedData_NvspNicStats_HyperVVirtualNetworkAdapter" -ComputerName $ComputerName) | Where-Object {($_.Name -notlike "*__TEAMNIC*") -and ($_.Name -notlike "*__DEVICE*")} | select Name, BytesReceivedPersec, BytesSentPersec
        } Else {
            $WMICounters = (Get-CimInstance "Win32_PerfFormattedData_NvspNicStats_HyperVVirtualNetworkAdapter" -ComputerName $ComputerName) | Where-Object {($_.Name -match $VMName) -and ($_.Name -notlike "*__TEAMNIC*") -and ($_.Name -notlike "*__DEVICE*")} | select Name, BytesReceivedPersec, BytesSentPersec
        }
 
        $PSObject = @()
 
        Foreach ($Counter in $WMICounters) {
            #Write-Host $Counter -ForegroundColor Green #Enable for Debugging
 
            If ($Unit -eq "MB/s") {
                $ReceiveRoundedValueIn = [math]::Round(($Counter.BytesReceivedPersec/1024/1024),2)
                $SentRoundedValueIn = [math]::Round(($Counter.BytesSentPersec/1024/1024),2)
            } ElseIf ($Unit -eq "KB/s") {
                $ReceiveRoundedValueIn = [math]::Round(($Counter.BytesReceivedPersec/1024),2)
                $SentRoundedValueIn = [math]::Round(($Counter.BytesSentPersec/1024),2)
            } Else {
                $ReceiveRoundedValueIn = [math]::Round(($Counter.BytesReceivedPersec/1024),2)
                $SentRoundedValueIn = [math]::Round(($Counter.BytesSentPersec/1024),2)
            }
 
            $PSObjectReceive = New-Object PSCustomObject -Property @{
                Adapter = ($Counter.Name -split "_")[0]
                Receive = $ReceiveRoundedValueIn
                Sent = $SentRoundedValueIn
                AllTraffic = $ReceiveRoundedValueIn + $SentRoundedValueIn
                Unit = $Unit
                #FullCounterName = $Counter
            }
            $PSObject += $PSObjectReceive
        }
        $PSObject | Select-Object Adapter, AllTraffic, Receive, Sent, Unit| Sort-Object $SortBy -Descending
    }
}