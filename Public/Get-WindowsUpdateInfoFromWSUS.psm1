Function Get-UpdateFromWSUSInfo {
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
 
        If ($KB) {
            $UpdateSearched = ($Updates | ? {$_.Title -match $KB})
 
            New-Object PSObject -Property @{
                Id = $UpdateSearched.Id.UpdateId.ToString()
                Title = $UpdateSearched.Title
                Source = $UpdateSearched.UpdateSource.ToString()
            }
        } Else {
            #List every update and output some basic info about it
            ForEach ($update in $updates) {
                New-Object PSObject -Property @{
                    Id = $update.Id.UpdateId.ToString()
                    Title = $update.Title
                    Source = $update.UpdateSource.ToString()
                }
            }
        }
    }
}