<#
.SYNOPSIS
    Get information about Windows Updates from WSUS.
.DESCRIPTION
    Get information about Windows Updates from WSUS locally or remotely.
    You can use this function to find the GUID of a patch. For example to remove this from WSUS.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Get-WindowsUpdateInfoFromWSUS
    Get information about Windows Updates from WSUS.
.EXAMPLE
    Get-WindowsUpdateInfoFromWSUS -WSUSServer <YourWSUS> -KB KB4088889
    Get information about Windows Update [KB4088889] from WSUS.
#>

Function Get-WindowsUpdateInfoFromWSUS {
    [CmdletBinding()]
 
    param (
        [Parameter(Mandatory=$false)]
        [String]$WSUSServer = "localhost",
 
        [Parameter(Mandatory=$false)]
        [Int32]$PortNumber = 8530,
 
        [Parameter(Mandatory=$false)]
        [Boolean]$useSecureConnection = $False,
 
        [Parameter(Mandatory=$false)]
        [String]$KB = ""
    )
 
    Process {
        [void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
        $WSUS = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer($WSUSServer,$False,$PortNumber)
 
        #Get all updates
        $updates = $WSUS.GetUpdates()
 
        If ($null -ne $KB) {
            $UpdateSearched = ($Updates | Where-Object {$_.Title -match $KB})
            
            ForEach ($_UpdateSearched in $UpdateSearched) {
                New-Object PSObject -Property @{
                    Id = $_UpdateSearched.Id.UpdateId.Guid
                    Title = $_UpdateSearched.Title
                    Severity = $_UpdateSearched.MsrcSeverity
                    Source = $_UpdateSearched.UpdateSource.ToString()
                    ArrivalDate = $_UpdateSearched.ArrivalDate
                    SecurityBulletins = $_UpdateSearched.SecurityBulletins
                }
            }
        } Else {
            #List every update and output some basic info about it
            ForEach ($update in $updates) {
                New-Object PSObject -Property @{
                    Id = $update.Id.UpdateId.Guid
                    Title = $update.Title
                    Severity = $update.MsrcSeverity
                    Source = $update.UpdateSource.ToString()
                    ArrivalDate = $update.ArrivalDate
                    SecurityBulletins = $update.SecurityBulletins
                }
            }
        }
    }
}