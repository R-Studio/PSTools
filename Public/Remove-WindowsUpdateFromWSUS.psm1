Function Remove-UpdateFromWSUS {
    [CmdletBinding()]
 
    param (
        [Parameter(Mandatory=$false)]
        [String]$WSUSServer = "localhost",
 
        [Parameter(Mandatory=$false)]
        [Int32]$PortNumber = 8530,
 
        [Parameter(Mandatory=$false)]
        [Boolean]$useSecureConnection = $False,
 
        [Parameter(Mandatory=$false)]
        [String]$KB = "",
 
        [Parameter(Mandatory=$false)]
        [String]$RemoveUpdateID = ""
    )
 
    Process {
        # Load .NET assembly
        [void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
        $WSUS = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer($WSUSServer,$False,$PortNumber)
        Write-Host "Connected sucessfully" -foregroundcolor "Green"
 
        #UpdateID (GUID of the update) to delete 
        If (!$RemoveUpdateID) {
            $IDOfUpdateToRemove = ($WSUS.GetUpdates() | ? {$_.Title -match $KB}).Id.UpdateId.ToString()
            $RemoveUpdateID = $IDOfUpdateToRemove
        }
 
        $updatescope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
        $u=$WSUS.GetUpdates($updatescope)
 
        Foreach ($u1 in $u) {
            $a=New-Object Microsoft.UpdateServices.Administration.UpdateRevisionId
            $a=$u1.id  
 
            If ($a.UpdateId -eq $RemoveUpdateID) {  
                     Write-Host "Deleting update " $a.UpdateId "..."
                      $WSUS.DeleteUpdate($a.UpdateId)
            }
        }  
 
        trap {
            write-host "Error Occurred"
            write-host "Exception Message: " 
            write-host $_.Exception.Message
            write-host $_.Exception.StackTrace
        }
    }
}