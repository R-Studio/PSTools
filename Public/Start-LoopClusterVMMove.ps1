<#
.SYNOPSIS
    This function is for massive LiveMigration tests.
.DESCRIPTION
    This function start LiveMigrating only one VM in a loop using FailoverCluster to make some LiveMigration tests.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Start-LoopClusterVMMove -Cluster <ClusterName> -VM <VMName> -Period <How_long_in_Days>
#>

Function Start-LoopClusterVMMove {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Cluster,

        [Parameter(Mandatory=$true)]
        [string]$VM,

        [Parameter(Mandatory=$false)]
        [datetime]$Period = (Get-Date).AddDays(10)
    )

    process {
        # Move only one VM in a Loop
        while ((get-date) -le $Period){
            Move-ClusterVirtualMachineRole -Cluster $Cluster -Name $VMName
            Start-Sleep -Seconds 5
        }
    }
}