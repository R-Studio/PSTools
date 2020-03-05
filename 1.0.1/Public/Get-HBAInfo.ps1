function Get-HBAInfo {
    [CmdletBinding()]
    Param
    (
      [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
      $ComputerName
    )
  
    Begin {
       $Namespace = "root\WMI"
 } Process {
      $port = Get-WmiObject -Class MSFC_FibrePortHBAAttributes -Namespace $Namespace @PSBoundParameters
      $hbas = Get-WmiObject -Class MSFC_FCAdapterHBAAttributes -Namespace $Namespace @PSBoundParameters
      $hbaProp = $hbas | Get-Member -MemberType Property, AliasProperty | Select-Object -ExpandProperty name | Where-Object {$_ -notlike "__*"}
      $hbas = $hbas | Select-Object $hbaProp
      $hbas | %{ $_.NodeWWN = ((($_.NodeWWN) | % {"{0:x2}" -f $_}) -join ":").ToUpper() }
  
      ForEach($hba in $hbas) {
        Add-Member -MemberType NoteProperty -InputObject $hba -Name FabricName -Value (
         ($port |? { $_.instancename -eq $hba.instancename}).attributes | `
         Select-Object `
         @{Name='Fabric Name';Expression={(($_.fabricname | % {"{0:x2}" -f $_}) -join ":").ToUpper()}}, `
         @{Name='Port WWN';Expression={(($_.PortWWN | % {"{0:x2}" -f $_}) -join ":").ToUpper()}} 
         ) -passThru
     }
   }
 }