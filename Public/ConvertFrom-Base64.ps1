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
    [CmdletBinding(DefaultParameterSetName='fromClipboard')]
    Param(
        [Parameter(ParameterSetName='fromClipboard', Mandatory=$false, Position=0)]
        [switch]$FromClipboard,    
        
        [Parameter(ParameterSetName='fromFile', Mandatory=$true, ValueFromPipeline=$true, Position=0)]
	    [string]$InputFile,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1)]
        [string]$WriteToFile
    )

    process {
        If ($FromClipboard) {
            $base64String = Get-Clipboard
        }

        If ($InputFile) {
            #If InputFile is set, check the path
            if ((Test-Path $InputFile) -eq $false) {
                Write-Host "Couldn't find file: $InputFile"
                exit 1
            }

            $base64String = Get-Content $InputFile
        }

        #Convert Base64String and write to a file
        [System.IO.File]::WriteAllBytes($WriteToFile, [Convert]::FromBase64String($base64string))
            
        Write-Host "Wrote to file: " -NoNewline
        Write-Host $WriteToFile -ForegroundColor Green
    }
}