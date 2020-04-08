<#
.SYNOPSIS
    List directories and size in the current path.
.DESCRIPTION
    List directories and size in the current path to find quickly the directories that use a huge amount of diskspace. 
    This works also for shares.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Get-DirectoryStats
    List directories and size in the current path.
.EXAMPLE
    Get-DirectoryStats -Path "\\hostname\share"
    List directories and size of a remote share or a normal path.
#>

Function Get-DirectoryStats {
    param(
        [Parameter(Position=0)]
        [string] $Path = (Get-Location).path
    )

    process{

        $Folders = Get-ChildItem $Path -Directory | Sort-Object
        foreach ($Folder in $Folders) {
            $subFolderItems = Get-ChildItem $Folder.FullName -File -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum | Select-Object Sum
            $Size = [math]::Round($subFolderItems.sum/1GB,2)

            [PSCustomObject]@{
                DirectorySize = $Size
                DirectoryName = $Folder.Name
                FullPath = $Folder.FullName
            }
        }
    }
}