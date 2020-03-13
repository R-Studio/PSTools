<#
.SYNOPSIS
    Set Windows PowerPlans.
.DESCRIPTION
    Set Windows PowerPlans locally or remotely.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Set-PowerPlan
    Sets all local PowerPlans.
.EXAMPLE
    Set-PowerPlan -OnlyActive
    Sets only active local PowerPlan.
.EXAMPLE
    Set-PowerPlan -ComputerName <Hostname> -OnlyActive
    Sets only active PowerPlan remotely.
#>

Function Set-PowerPlan {
    [CmdletBinding(DefaultParameterSetName='local')]
    param (
        #ParameterSet = local
        [Parameter(ParameterSetName='local', Mandatory=$true, Position=0)] #This is a dynamic Paramter that gets all local PowerPlans (for autocompletion)
        [ArgumentCompleter({
            (Get-CimInstance -ClassName Win32_PowerPlan -Namespace root\cimv2\power).ElementName
        })]
        [string]$PowerPlan,

        
        #ParameterSet = remote
        [Parameter(ParameterSetName='remote', Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [string]$ComputerName,

        [Parameter(ParameterSetName='remote', Mandatory=$true, Position=1)] #This is a dynamic Paramter that gets all remote PowerPlans (for autocompletion)
        [ArgumentCompleter({
            (Get-CimInstance -ClassName Win32_PowerPlan -Namespace root\cimv2\power -ComputerName $ComputerName).ElementName
        })]
        [string]$RemotePowerPlan
    )
    
    process {
        If ($ComputerName) {
            #Set remote PowerPlan
            Get-CimInstance -ClassName Win32_PowerPlan -Namespace root\cimv2\power -ComputerName $ComputerName -Filter "ElementName = '$RemotePowerPlan'" | Set-CimInstance -Property @{isActive="true"}
        } Else {
            #Set local PowerPlan
            Get-CimInstance -ClassName Win32_PowerPlan -Namespace root\cimv2\power -Filter "ElementName = '$PowerPlan'" | Set-CimInstance -Property @{isActive="true"}
        }
    }
}

#$powerPlan = Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerPlan -Filter "ElementName = 'High Performance'"
#$powerPlan.Activate()