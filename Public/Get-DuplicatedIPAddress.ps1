<#
.SYNOPSIS
    Get the last duplicated IP-Address.
.DESCRIPTION
    This function is to finding fast the computer for causing duplicated IP-Addresses.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch

.EXAMPLE
    Get-DuplicatedIPAddress
    Get the last duplicated IP-Address on the local computer.
.EXAMPLE
    Get-DuplicatedIPAddress -ComputerName <DestinationComputer>
    Get the last duplicated IP-Address on an remote computer.
#>


Function Get-DuplicatedIPAddress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, Position=0, HelpMessage="Remote computername to search the duplicated IP event.")]
        [String]$ComputerName,

        [Parameter(Mandatory=$false, Position=0, HelpMessage="Credentials to authenticate with the remote computer")]
        [pscredential]$Credential
    )
 
    process {
        $EventObject = Get-WinEvent -FilterHashtable @{LogName = "Microsoft-Windows-Dhcp-Client/Admin"; ID=1005} -MaxEvents 1 @PSBoundParameters
        $EventObject.Message -match 'IP\saddress\s(\d+\.\d+\.\d+\.\d+)\sfor' | Out-Null

        $EventXML = [xml]$EventObject.ToXml()

        $MAC = ($EventXML.Event.EventData.Data | Where-Object {$_.name -eq "HWAddress"}).'#text' 
        $MACFormated = $MAC -replace '(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})', '$1:$2:$3:$4:$5:$6' #format MAC-Address
 
        [PSCustomObject]@{
            Time = $EventObject.TimeCreated
            MAC_Address = $MACFormated
            MAC_RAW = $MAC
            IP_Address = $Matches[1]
            DuplicatedIPSourceComputerName = $EventObject.MachineName
        }
    }
}