<#
.SYNOPSIS
    Get the detailed Windows Version with current support channel and updatelevel.
.DESCRIPTION
    Get the detailed Windows Version with current support channel and updatelevel from the registry.
    With the number after the last "." you can find the updatelevel. 
    For example if you run this function on a server and you have following output: 10.0.14393.1607.3542.
    You know you are on updatelevel 25. February 2020, because if you go to the update site from Microsoft and search for the number (in this exmaple "3542")
    you will find the update [KB4537806] (https://support.microsoft.com/en-us/help/4537806/windows-10-update-kb4537806).
    Because in the last part of the title on the updatesite you can find follwing string "(OS Build 14393.3542)" -> "3542".
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Get-OSVersion
    Gets the detailed Windows Version with current support channel and updatelevel (locally).
.EXAMPLE
    Get-OSVersion -ComputerName <Hostname>
    Gets the detailed Windows Version with current support channel and updatelevel (remotely).
#>

Function Get-OSVersion {
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
        [string]$ComputerName
    )

    process{
        Invoke-Command @PSBoundParameters -ScriptBlock {
            ("CurrentMajorVersionNumber","CurrentMinorVersionNumber","CurrentBuildNumber","ReleaseId","UBR" | ForEach-Object {(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").$_}) -join "."
        }
    }
}