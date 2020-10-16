<#
.SYNOPSIS
    Write a JSON-Object (tree) to Registry.
.DESCRIPTION
    This PowerShell function can write recursively Registry-Keys based on a JSON-Object even this JSON is nested (JSON-tree to Registry-tree).
.NOTES
    Author: Robin Hermann
    JSON object for testing:
    $json = '{
        "Key1" : "Value1",
        "Key2" : "Value2",
        "KeywithSubKeys": {
            "SubKey1" : "SubValue1",
            "SubKey2" : "SubValue2",
            "SubKeywithArray" : ["ArrayValue1", "ArrayValue2"]
        },
        "Key3" : 1
    }'
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Write-JsonToRegistry -InputObject <Your_JSON-Object> -RegistryPath <Your_Registry_Path>
    Write your JSON-Object to your Registry on Path. (The variable $JSON must be a PowerShell Object)
#>


Function Write-JsonToRegistry {
    param(
        [Parameter(Mandatory=$true,Position=0,HelpMessage="JSON-Object")]
        $InputObject,
        
        [Parameter(Mandatory=$true,Position=0,HelpMessage="Registry-Path, under this path the JSON tree will be written.")]
        [string]$RegistryPath
    ) 

    process{
        if (!(Test-Path -Path $RegistryPath)) {
            Write-Output "Create new key in registry on RegistryPath=$RegistryPath"
            New-Item -Path $RegistryPath -Force | Out-Null
        }

        $members = $InputObject | Get-Member -MemberType NoteProperty
        foreach ($member in $members) {
            $value = $InputObject.($member.Name)

            if ($value.GetType().FullName -eq "System.Management.Automation.PSCustomObject") {
                Write-JsonToRegistry -InputObject $value -RegistryPath ($RegistryPath + "\" + $member.Name)
            } else {
                if ($value.GetType().FullName -eq "System.Object[]") {
                    Write-Output "Add/update multistring value in registry on RegistryPath=$RegistryPath and memberName=$($member.Name) and value=$value"
                    New-ItemProperty -Path $RegistryPath -PropertyType "MultiString" -Name $member.Name -Value $value -Force | Out-Null
                } else {
                    Write-Output "Add/update string/dword value in registry on RegistryPath=$RegistryPath and memberName=$($member.Name) and value=$value"
                    New-ItemProperty -Path $RegistryPath -Name $member.Name -Value $value -Force | Out-Null
                }
            }
        }
    }
}