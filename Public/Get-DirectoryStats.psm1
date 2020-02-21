Function Get-DirectoryStats {
    param(
        [Parameter(Position=0)]
        [string] $Path = (Get-Location).path
    )

    process{

        $Folders = Get-ChildItem $Path -Directory | Sort-Object
        foreach ($Folder in $Folders) {
            $subFolderItems = Get-ChildItem $Folder.FullName -File -Recurse -Force | Measure-Object -Property Length -Sum | Select-Object Sum
            $Size = [math]::Round($subFolderItems.sum/1GB,2)

            [PSCustomObject]@{
                DirectorySize = $Size
                DirectoryName = $Folder.Name
                FullPath = $Folder.FullName
            }
        }
    }
}