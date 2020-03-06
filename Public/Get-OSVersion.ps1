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