<#
.SYNOPSIS
    Get the VMHealthStates (Heartbeat) of all VMs in a Cluster.
.DESCRIPTION
    Get the VMHealthStates (Heartbeat) of all VMs in a Cluster to find fast VMs that are running for example in the Windows Recovery Mode.
.NOTES
    This function requires the PowerShell modules "FailoverClusters" and "Hyper-V".
    Because of PowerShell modul conflict -> the modul "Hyper-V" is forced in command
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Get-VMHealthState -Cluster <YOUR_CLUSTER_NAME>
    Get VMHealthStates of running VMs that are not 'OK'
.EXAMPLE
    Get-VMHealthState -Cluster <YOUR_CLUSTER_NAME> -ShowAllVMStates
    Get all VMHealthStates of running VMs
#>

function Get-VMHealthState {
    [CmdletBinding()]
    param (
      [Parameter(Mandatory=$true, Position=0)]
      [string]$Cluster,

      [Parameter(Mandatory=$false)]
      [switch]$ShowAllVMStates
    )

    process{
        If ($ShowAllVMStates) {
            Write-Host "Get all VMHealthStates of running VMs (this can take some time).." -ForegroundColor Gray
            Hyper-V\Get-VM -ComputerName (Get-ClusterNode -Cluster $Cluster).Name | Where-Object {$_.State -ne "Off"} | Get-VMIntegrationService -Name heartbeat*
        } else {
            Write-Host "Get VMHealthStates of running VMs that are not 'OK' (this can take some time).." -ForegroundColor Gray
            Hyper-V\Get-VM -ComputerName (Get-ClusterNode -Cluster $Cluster).Name | Where-Object {$_.State -ne "Off"} | Get-VMIntegrationService -Name heartbeat* | Where-Object {$_.PrimaryStatusDescription -ne "OK"}
        }
    }
}