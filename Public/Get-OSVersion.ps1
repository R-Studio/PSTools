Function Get-OSVersion {
    param(
        [string]$ComputerName = $env:COMPUTERNAME
    )

    process{
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            ("CurrentMajorVersionNumber","CurrentMinorVersionNumber","CurrentBuildNumber","ReleaseId","UBR" | ForEach-Object {(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").$_}) -join "."
        }
    }
}