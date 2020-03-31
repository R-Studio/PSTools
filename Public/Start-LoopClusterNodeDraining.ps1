
<#
.SYNOPSIS
    This function is for massive LiveMigration tests.
.DESCRIPTION
    This function drains all Hyper-V cluster nodes one by one using FailoverCluster to make some LiveMigration tests.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Start-LoopClusterNodeDraining -Cluster Cluster01 -Period 2
    Start draining the ClusterNodes of Cluster "Cluster01" for 2 Days in a loop.
#>

Function Start-LoopClusterNodeDraining {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Cluster,

        [Parameter(Mandatory=$false)]
        [datetime]$Period = (Get-Date).AddDays(10)
    )

    process {
        while ((get-date) -le $Period){
            $nodes = Get-ClusterNode -Cluster $cluster
            $pausednode = $nodes | Where-Object {$_.DrainStatus -ne "NotInitiated"}

            If ($pausednode) {
                Write-Host "The following Node is in 'Paused' state, this will be changed:" $pausednode.name -ForegroundColor Red
                Resume-ClusterNode -Cluster $cluster -Name $pausednode.name
                Write-Host "The state of the following node has changed to 'Up':" $pausednode.name -ForegroundColor Green
            }

            foreach ($node in $nodes){
                $nodestatus  = $node.DrainStatus

                if ($nodestatus -eq "NotInitiated"){
                    Write-Host "Draining of following Node:" $node.name -ForegroundColor Gray
                    Suspend-ClusterNode -Cluster $cluster -Name $node.name -Drain

                    # do-loop because: FailoverCluster State is dump -> State change to "Paused" before the Node is completely drained
                    do {
                        Start-Sleep -Seconds 2

                        # Check if FailoverCluster State is failed -> Drain the node again
                        If ((Get-ClusterNode -Cluster $cluster -Name $node.name).DrainStatus -eq "Failed") {
                            Suspend-ClusterNode -Cluster $cluster -Name $node.name -Drain
                        }
                    } until ((Get-ClusterNode -Cluster $cluster -Name $node.name).DrainStatus -eq "Completed")
                    Write-Host "Draining of following Node completed:" $node.name -ForegroundColor Gray
                }
                
                Resume-ClusterNode -Cluster $cluster -Name $node.name
                Start-Sleep -Seconds 5
                Write-Host "--Next LiveMigration phase" -ForegroundColor Cyan
            }
        }
    }
}