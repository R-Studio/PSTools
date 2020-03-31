<#
.SYNOPSIS
    This function is for massive LiveMigration tests.
.DESCRIPTION
    This function start Maintenance of all Hyper-V nodes in a cluster (one by one) using VMM to make some LiveMigration tests.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Start-LoopVMMHyperVMaintenance -Cluster "Cluster01" -Period 2
    Draining the ClusterNodes of Cluster "Cluster01" for 2 Days in a loop using VMM maintenance mode.
#>

Function Start-LoopVMMHyperVMaintenance {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Cluster,

        [Parameter(Mandatory=$false)]
        [datetime]$Period = (Get-Date).AddDays(10)
    )

    process {
        $nodes = Get-SCVMHostCluster -Name $Cluster | Get-SCVMHost | Select-Object name

        while ((get-date) -le $Period){
            foreach ($node in $nodes){
                $status  = Get-SCVMHost -ComputerName $node.name | Select-Object clusternodestatus
        
                if ($status -ne "Paused"){
                    Disable-SCVMHost -VMHost $node.name -MoveWithinCluster
                }
        
                Enable-SCVMHost -VMHost $node.name
                Start-Sleep -Seconds 10
            }
        }
    }
}
