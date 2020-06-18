<#
.SYNOPSIS
    Shows all Windows console colors.
.DESCRIPTION
    Shows all Windows console colors. For example to get the colors for "Windows Terminal" themes.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Show-Colors
    Shows all Windows console colors (foreground & background colors).
.EXAMPLE
    Show-Colors -WithoutBackgroundColor
    Shows all Windows console colors (without background colors).
#>

Function Show-Colors {
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [switch]$WithoutBackgroundColor
    )

    process{
        $colors = [enum]::GetValues([System.ConsoleColor])
        
        If ($WithoutBackgroundColor) {
            Foreach ($fgcolor in $colors) { 
                Write-Host "$FGcolor|" -ForegroundColor $FGcolor -NoNewLine
            }
        } Else {
            Foreach ($BGcolor in $colors){
                Foreach ($fgcolor in $colors) { 
                    Write-Host "$FGcolor|" -ForegroundColor $FGcolor -BackgroundColor $BGcolor -NoNewLine
                }
                Write-Host " on $BGcolor"
            }
        }
    }
}