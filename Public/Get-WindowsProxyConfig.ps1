<#
.SYNOPSIS
    Get information about Windows Proxy configurations.
.DESCRIPTION
    Get information about Windows Proxy configurations (WinINet & WinHTTP for User & Machine).
.NOTES
    Author: Robin Hermann
    MigrateProxy:
    - If 'Automatically detect settings' is disabled and migrateProxy is set to 0 setting detection will occur at first internet connection and value of Key MigrateProxy will be changed to 1.
    - If 'Automatically detect settings' is enabled. The key MigrateProxy has no effect.
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Get-WindowsProxyConfig
    Get information about the current Windows Proxy configuration from the local machine.
.EXAMPLE
    Get-WindowsProxyConfig -ComputerName <Hostname> -Credentials 
    Get information about the current Windows Proxy configuration of a remote host with different credentials.
#>

Function Get-WindowsProxyConfig {
    param(
        [parameter(Mandatory=$false)]
        [string]$ComputerName,

        [parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$Credential
    )

    process{
        Invoke-Command @PSBoundParameters -ScriptBlock {
            [PSCustomObject]@{
                #Get WinINet User Proxy Settings
                WinINetUser_AutoConfigURL = (Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings").GetValue("AutoConfigURL")
                WinINetUser_MigrateProxy = (Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings").GetValue("MigrateProxy")
                WinINetUser_ProxyEnable = (Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings").GetValue("ProxyEnable")
                WinINetUser_ProxyServer = (Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings").GetValue("ProxyServer")
                WinINetUser_Bypass = (Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings").GetValue("ProxyOverride")

                #Get WinINet Machine Proxy Settings
                WinINetMachine_AutoConfigURL = (Get-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings").GetValue("AutoConfigURL")
                WinINetMachine_MigrateProxy = (Get-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings").GetValue("MigrateProxy")
                WinINetMachine_ProxyEnable = (Get-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings").GetValue("ProxyEnable")
                WinINetMachine_ProxyServer = (Get-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings").GetValue("ProxyServer")
                WinINetMachine_Bypass = (Get-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings").GetValue("ProxyOverride")

                #Get WinHTTP User & Machine Proxy Settings
                WinHTTPUser = (((Get-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections").GetValue("WinHttpSettings")) | ForEach{ [char]$_ }) -join "" -replace ([char]0)
                WinHTTPMachine = (((Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections").GetValue("WinHttpSettings")) | ForEach{ [char]$_ }) -join "" -replace ([char]0)
            }
        }
    }
}