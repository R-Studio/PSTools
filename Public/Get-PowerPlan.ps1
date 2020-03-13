<#
.SYNOPSIS
    Get Windows PowerPlans.
.DESCRIPTION
    Get Windows PowerPlans locally or remotely.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Get-PowerPlan
    Gets all local PowerPlans.
.EXAMPLE
    Get-PowerPlan -OnlyActive
    Gets only active local PowerPlan.
.EXAMPLE
    Get-PowerPlan -ComputerName <Hostname> -OnlyActive
    Gets only active PowerPlan remotely.
#>

Function Get-PowerPlan {
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
        [string]$ComputerName,

        [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=1)]
        [switch]$OnlyActive
    )
    
    process {
        If ($OnlyActive.IsPresent) {
            If ($ComputerName) {
                #Only active remote Powerplans
                Get-CimInstance -ClassName Win32_PowerPlan -Namespace root\cimv2\power -Filter "IsActive = 'True'" -ComputerName $ComputerName | Select-Object ElementName, IsActive, Description, InstanceID, PSComputerName
            } Else {
                #Only active local Powerplans
                Get-CimInstance -ClassName Win32_PowerPlan -Namespace root\cimv2\power -Filter "IsActive = 'True'" | Select-Object ElementName, IsActive, Description, InstanceID
            }
        } Else {
            If ($ComputerName) {
                #All remote Powerplans
                Get-CimInstance -ClassName Win32_PowerPlan -Namespace root\cimv2\power -ComputerName $ComputerName | Select-Object ElementName, IsActive, Description, InstanceID, PSComputerName
            } Else {
                #All local Powerplans
                Get-CimInstance -ClassName Win32_PowerPlan -Namespace root\cimv2\power | Select-Object ElementName, IsActive, Description, InstanceID
            }
        }
    }
}