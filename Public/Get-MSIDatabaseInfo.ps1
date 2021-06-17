<#
.SYNOPSIS
    Get infos from MSI database.
.DESCRIPTION
    Get infos (mandatory properties) from the database of an MSI-file.
.NOTES
    Author: Robin Hermann
    Source: forge.puppet.com

    MSI Mandatory properties (https://docs.microsoft.com/en-us/windows/win32/msi/required-properties):
        - ProductCode
        - ProductLanguage
        - Manufacturer
        - ProductVersion
        - ProductName
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Get-MsiDatabaseInfo -FilePath C:\path\your.msi
    Get MSI database infos from File "C:\path\your.msi".
#>


Function Get-MsiDatabaseInfo {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [IO.FileInfo]$FilePath
    )

    process{  
        $productName = Invoke-MSIQuery -FilePath $FilePath.FullName -Query "SELECT Value FROM Property WHERE Property = 'ProductName'"
        $ProductVersion = Invoke-MSIQuery -FilePath $FilePath.FullName -Query "SELECT Value FROM Property WHERE Property = 'ProductVersion'"
        $productCode = Invoke-MSIQuery -FilePath $FilePath.FullName -Query "SELECT Value FROM Property WHERE Property = 'ProductCode'"
        $Manufacturer = Invoke-MSIQuery -FilePath $FilePath.FullName -Query "SELECT Value FROM Property WHERE Property = 'Manufacturer'"
    
        return [PSCustomObject]@{
            FullName    = $FilePath.FullName
            ProductName = ([string]$productName).TrimStart()
            ProductVersion = ([string]$ProductVersion).TrimStart()
            ProductId = ([string]$productCode).Replace("{","").Replace("}","").TrimStart()
            Manufacturer = ([string]$Manufacturer).TrimStart()
        }
    }
}