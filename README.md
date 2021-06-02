# PSTools (still in progress)
PSTool is a PowerShell module with some usefull PowerShell functions, espescially for System Engineers and System Administrators. 
The module contains mainly functions for Windows Environments, but feel free to add functions for Linux environments.

> Please be carefull and test the functions before you use it in your production environments.
> I am very appreciative for any help, extension or comments.

# Functions & Features
| PowerShell function                 | Description                |
| ----------------------------------- |----------------------------|
| Clear-RecycleBin                    | Empty the recycle bin.     |
| Convert-UnixTimestamp               | This function converts a Unix Timestamp (Epoche Time) in a readable date format. |
| ConvertFrom-Base64                  | Converts/Decode a Base64 file. |
| ConvertTo-Base64                    | Converts/Encode a file to Base64. |
| Disable-TelemetryOnWin10            | Disable Windows 10 Telemetry Services/Tasks. |
| Export-EventLog                     | Export traditional Windows Eventlogs. |
| Get-CPUNumber                       | Get the number of CPU's, Cores, logical Processors. |
| Get-DirectoryStats                  | List directories and size in the current path. |
| Get-DuplicatedIPAddress             | Get the last duplicated IP-Address. |
| Get-FileEncoding                    | Get file encoding. |
| Get-FileLockProcess                 | Check which process is locking a file. |
| Get-FileMetaData                    | Small function that gets metadata information from file. |
| Get-FreeDiskSpace                   | Get free disk space of all disk volumes with an driveletter on a remote system. |
| Get-HBAInfo                         | Get information about the installed HBA card. |
| Get-InfluxDB2Data                   | Get data from an InfluxDB 2.x. |
| Get-InstalledSoftware               | Get all installed from the Uninstall keys in the registry. |
| Get-LiveMigrationBlackoutTime       | Get the BlackoutTime of each LiveMigration. |
| Get-MountPointsAndUserDisks         | Get all mountpoints and all UserProfileDisks (Roaming Profiles as a VHDX). |
| Get-NetStat                         | Get information about TCP & UDP connections. |
| Get-NetworkAdapterConnectionStatus  | Get NIC status with more details then in the built-in windows command. |
| Get-OSVersion                       | Get the detailed Windows Version with current support channel and updatelevel. |
| Get-PendingReboot                   | Gets the pending reboot status on a local or remote computer. |
| Get-PowerPlan                       | Get Windows PowerPlans. |
| Get-SumOfAllFiles                   | Disk Space Usage of all Files between a specified time period. |
| Get-UpTime                          | Outputs the last bootup time and uptime for one or more computers. |
| Get-vNetworkTrafficCIM              | Shows the Traffic of the vNICs of the VMs on a Hyper-V Node. |
| Get-WindowsProxyConfig              | Get information about Windows Proxy configurations. |
| Get-WindowsUpdateInfoFromWSUS       | Get information about Windows Updates from WSUS. |
| New-ISOFile                         | The New-IsoFile cmdlet creates a new .iso file containing content from chosen folders. |
| Remove-WindowsUpdateFromWSUS        | Remove a Windows Update from WSUS. |
| Search-IPsInSubnet                  | Search/Scan a subnet. |
| Set-DNSPTRRecord                    | Sets the PTR-Record on Microsoft DNS Server. |
| Set-PageFileSize                    | Configure the PageFile location/drive, initialsize and maximumsize. |
| Set-PowerPlan                       | Set Windows PowerPlans locally or remotely. |
| Set-ProxyWinINET                    | This function will set the proxy settings provided as input to the cmdlet. |
| Show-ColorTable                     | Shows all Windows console colors. |
| Start-LoopClusterNodeDraining       | This function is for massive LiveMigration tests (drain on nodes in Cluster). |
| Start-LoopClusterVMMove             | This function is for massive LiveMigration tests (move a single vm). |
| Start-LoopVMMHyperVMaintenance      | This function is for massive LiveMigration tests (start maintenance from VMM). |
| Test-NetConnectionLoop              | Test connection in a loop. |
| Test-Port                           | Tests port on computer. |
| Test-WebServerSSLCert               | Get SSL certification of a web URL. |
| Write-JsonToRegistry                | Write a JSON-Object (tree) to Registry. |   




## License
Copyright 2020 Robin Hermann

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. 
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.