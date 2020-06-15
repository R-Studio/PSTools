<#
.SYNOPSIS
    Empty the recycle bin.
.DESCRIPTION
    Empty the recycle bin of the current or of all users.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Clear-RecycleBin
    Empty the recycle bin of the current.
.EXAMPLE
    Clear-RecycleBin -AllUsers
    Empty the recycle bin of all users on this system.
#>

Function Clear-RecycleBin {
    param(
    [Parameter(Mandatory=$false, Position=0)]
    [switch]$AllUsers
    )

    process{
        #Get SID of the current user
        $CurrentUserSID = (New-Object System.Security.Principal.NTAccount("$env:USERNAME")).Translate([System.Security.Principal.SecurityIdentifier]).Value

        If ($AllUsers) {
            #Clear the recycle bin of all users on this system
            Get-ChildItem -Path 'C:\$Recycle.Bin' -Force | Remove-Item -Recurse -ErrorAction SilentlyContinue
        } else {
            #Clear the recycle bin of the current user
            Get-ChildItem -Path 'C:\$Recycle.Bin' -Force | Where-Object {$_.Name -eq $CurrentUserSID} | Remove-Item -Recurse -ErrorAction SilentlyContinue
        }
    }
}