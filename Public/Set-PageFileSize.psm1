Function Set-PageFileSize {
    [CmdletBinding()]
    Param(
            [Parameter(Mandatory)]
            [Alias('dl')]
            [ValidatePattern('^[A-Z]$')]
            [String]$DriveLetter,
     
            [Parameter(Mandatory)]
            [ValidateRange(0,[int32]::MaxValue)]
            [Int32]$InitialSize,
     
            [Parameter(Mandatory)]
            [ValidateRange(0,[int32]::MaxValue)]
            [Int32]$MaximumSize
    )
    Begin {}
    Process {
        #The AutomaticManagedPagefile property determines whether the system managed pagefile is enabled. 
        #This capability is not available on windows server 2003,XP and lower versions.
        #Only if it is NOT managed by the system and will also allow you to change these.
        try {
            $Sys = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop 
        } catch {
     
        }
     
        If($Sys.AutomaticManagedPagefile) {
            try {
                $Sys | Set-CimInstance -Property @{ AutomaticManagedPageFile = $false } -ErrorAction Stop
                Write-Verbose -Message "Set the AutomaticManagedPageFile to false"
            } catch {
                Write-Warning -Message "Failed to set the AutomaticManagedPageFile property to false in  Win32_ComputerSystem class because $($_.Exception.Message)"
            }
        }
     
        # Configuring the page file size
        try {
            $PageFile = Get-CimInstance -ClassName Win32_PageFileSetting -Filter "SettingID='pagefile.sys @ $($DriveLetter):'" -ErrorAction Stop
        } catch {
            Write-Warning -Message "Failed to query Win32_PageFileSetting class because $($_.Exception.Message)"
        }
     
        If($PageFile){
            try {
                $PageFile | Remove-CimInstance -ErrorAction Stop
            } catch {
                Write-Warning -Message "Failed to delete pagefile the Win32_PageFileSetting class because $($_.Exception.Message)"
            }
        }
        try {
            New-CimInstance -ClassName Win32_PageFileSetting -Property  @{Name= "$($DriveLetter):\pagefile.sys"} -ErrorAction Stop | Out-Null
     
            # http://msdn.microsoft.com/en-us/library/windows/desktop/aa394245%28v=vs.85%29.aspx            
            Get-CimInstance -ClassName Win32_PageFileSetting -Filter "SettingID='pagefile.sys @ $($DriveLetter):'" -ErrorAction Stop | Set-CimInstance -Property @{
                InitialSize = $InitialSize ;
                MaximumSize = $MaximumSize ; 
            } -ErrorAction Stop
     
            Write-Verbose -Message "Successfully configured the pagefile on drive letter $DriveLetter"
     
        } catch {
            Write-Warning "Pagefile configuration changed on computer '$Env:COMPUTERNAME'. The computer must be restarted for the changes to take effect."
        }
    }
    End {}
    }