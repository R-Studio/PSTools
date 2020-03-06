<#
.SYNOPSIS
    Get the BlackoutTime of each LiveMigration.
.DESCRIPTION
    Get the BlackoutTime of each LiveMigration from the Windows Eventlogs from all clusternodes.
    The BlackoutTime is the time for the last transfer of the state of a VM in a LiveMigration process.
    More informations: http://wiki.webperfect.ch/index.php?title=Blackout-Time_(VM_Live_Migration)
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Get-LiveMigrationBlackoutTime -Cluster <YourCluster> -EventlogAge <-3>
    Get the BlackoutTime of each LiveMigration (between now and 3 days ago).
#>

Function Get-LiveMigrationBlackoutTime {
    [CmdletBinding()]
 
    param(
        [Parameter(Position=0,mandatory=$true)]
        [string] $Cluster,

        [Parameter(Position=1,mandatory=$true)]
        [int] $EventlogAge,

        [ValidateSet("VMName", "BlackoutTime","TimeCreated")]
	    [String] $Sortby = "BlackoutTime"
    )
 
    process{
        $ErrorActionPreference = "SilentlyContinue"
 
        $eventsnormal = (Get-ClusterNode -Cluster $Cluster).Name | ForEach-Object {Get-WinEvent -ComputerName $_ -FilterHashtable @{LogName = 'Microsoft-Windows-Hyper-V-VMMS-Admin'; ID = 20415,20417; StartTime = ((Get-Date).AddDays($EventlogAge))}} #| select TimeCreated, Id, Message, MachineName
        $HyperVNode = $events.MachineName
 
        $obj = foreach ($event in $eventsnormal) {  
            If ($event.id -eq 20417) {
                $Level = "Critical"
            } Else {
                $Level = "Normal"
            }
 
            $EventVM = $event.properties.value[0]
            $EventVMID = $event.properties.value[1]
            $EventBlackoutTime = $event.properties.value[2]
            $HyperVNode = $event.MachineName
            $TimeCreated = $event.TimeCreated
 
            [PSCustomObject]@{
                VMName = $EventVM
                BlackoutTime = $EventBlackoutTime
                VMID = $EventVMID
                HyperVNode = $HyperVNode
                TimeCreated = $TimeCreated
                Level = $Level
            }
        }
        $obj | Sort-Object -Descending $Sortby 
    }
}