<#
.SYNOPSIS
    Get information about the installed HBA card.
.DESCRIPTION
    Get information about the installed HBA card (locally or remotely).
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Get-HBAInfo
    Get information about the installed HBA card locally.
.EXAMPLE
    Get-HBAInfo -ComputerName <Hostname>
    Get information about the installed HBA card remotely.
#>

function Get-HBAInfo {
    [CmdletBinding()]
    Param (
      [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
      [string]$ComputerName
    )
  
    Begin {
       $Namespace = "root\WMI"
    }

    Process {
      $port = Get-WmiObject -Class MSFC_FibrePortHBAAttributes -Namespace $Namespace @PSBoundParameters
      $hbas = Get-WmiObject -Class MSFC_FCAdapterHBAAttributes -Namespace $Namespace @PSBoundParameters
      $hbaProp = $hbas | Get-Member -MemberType Property, AliasProperty | Select-Object -ExpandProperty name | Where-Object {$_ -notlike "__*"}
      $hbas = $hbas | Select-Object $hbaProp
      $hbas | ForEach-Object { $_.NodeWWN = ((($_.NodeWWN) | ForEach-Object {"{0:x2}" -f $_}) -join ":").ToUpper() }
  
      ForEach($hba in $hbas) {
        Add-Member -MemberType NoteProperty -InputObject $hba -Name FabricName -Value (
         ($port | Where-Object {$_.instancename -eq $hba.instancename}).attributes | `
         Select-Object `
         @{Name='Fabric Name';Expression={(($_.fabricname | ForEach-Object {"{0:x2}" -f $_}) -join ":").ToUpper()}}, `
         @{Name='Port WWN';Expression={(($_.PortWWN | ForEach-Object {"{0:x2}" -f $_}) -join ":").ToUpper()}} 
         ) -passThru
      }
    }
 }