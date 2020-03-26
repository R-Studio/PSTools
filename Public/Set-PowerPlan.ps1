<#
.SYNOPSIS
    Set Windows PowerPlans.
.DESCRIPTION
    Set Windows PowerPlans locally or remotely.
.NOTES
    Author: Robin Hermann
    Open: 
        Bug: If you select a PowerPlan with whitespaces then you have to manually add double quotes around it.
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Set-PowerPlan -PowerPlan <Select_PowerPlan>
    Set local PowerPlan to the selected one.
.EXAMPLE
    Set-PowerPlan -ComputerName <Hostname> -RemotePowerPlan <Select_RemotePowerPlan> 
    Set remote PowerPlan to the selected one.
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
            (Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerPlan -Filter "ElementName = '$RemotePowerPlan'" -ComputerName $ComputerName).Activate()
        } Else {
            #Set local PowerPlan
            (Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerPlan -Filter "ElementName = '$PowerPlan'").Activate()
        }
    }
}