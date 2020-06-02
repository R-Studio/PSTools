Function Set-RegKey {
    param (
        [string] $RegKey,
        [string] $Value,
        [string] $SvcName,
        [Int] $CheckValue,
        [Int] $SetData
    )

    Write-Host "Checking if $SvcName is enabled" -ForegroundColor Green
    if (!(Test-Path $RegKey)) {
        Write-Host "Registry Key for service $SvcName does not exist, creating it now" -ForegroundColor Yellow
        New-Item -Path (Split-Path $RegKey) -Name (Split-Path $RegKey -Leaf) 
    }
    $ErrorActionPreference = 'Stop'

    try {
        Get-ItemProperty -Path $RegKey -Name $Value 
        if ((Get-ItemProperty -Path $RegKey -Name $Value).$Value -eq $CheckValue) {
            Write-Host "$SvcName is enabled, disabling it now" -ForegroundColor Green
            Set-ItemProperty -Path $RegKey -Name $Value -Value $SetData -Force
        }
        if ((Get-ItemProperty -Path $RegKey -Name $Value).$Value -eq $SetData) {
            Write-Host "$SvcName is disabled" -ForegroundColor Green
        }
    }
    catch [System.Management.Automation.PSArgumentException] {
        Write-Host "Registry entry for service $SvcName doesn't exist, creating and setting to disable now" -ForegroundColor Yellow
        New-ItemProperty -Path $RegKey -Name $Value -Value $SetData -Force
    }
}