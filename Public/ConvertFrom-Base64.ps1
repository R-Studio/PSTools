<#
.SYNOPSIS
    Converts/Decode a Base64 file
.DESCRIPTION
    Converts/Decode a Base64 file
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    ConvertTo-Base64 -InputFile <YourFileToConvert> -$WriteToFile <FileToSave>
    Decode your Base64 file.
#>

Function ConvertFrom-Base64 {
    [CmdletBinding()]
    Param(
	    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
	    [string]$InputFile,
        
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1)]
	    [string]$WriteToFile
    )

    process {
        if ((Test-Path $InputFile) -eq $false) {
            Write-Host "Couldn't find file: $InputFile"
            exit 1
        }

        $base64String = Get-Content $InputFile
        [System.IO.File]::WriteAllBytes($WriteToFile, [Convert]::FromBase64String($base64string))
            
        Write-Host "Wrote to file: " -NoNewline
        Write-Host $WriteToFile -ForegroundColor Green
    }
}