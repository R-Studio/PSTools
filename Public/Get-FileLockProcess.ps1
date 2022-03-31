<#
.SYNOPSIS
    Check which process is locking a file
.DESCRIPTION
    On Windows, Get-FileLockProcess takes a path to a file and returns a System.Collections.Generic.List of
    System.Diagnostic.Process objects (one or more processes could have a lock on a specific file, which is why
    a List is used).
    On Linux, this function returns a PSCustomObject with similar properties.
.NOTES
    Windows solution credit to: https://stackoverflow.com/a/20623311
    PowerShell function Author: @pldmgg
.PARAMETER FilePath
    This parameter is MANDATORY.
    This parameter takes a string that represents a full path to a file.
.EXAMPLE
    # On Windows...
    PS C:\Users\username> Get-FileLockProcess -FilePath "C:\Users\Username\Downloads\call_activity_2017_Nov.xlsx"
 
    Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
    -------  ------    -----      -----     ------     --  -- -----------
    1074      51    50056      86984       5.86   2856   2 EXCEL
.EXAMPLE
    # On Linux/MacOS
    PS /home/pdadmin/Downloads> Get-FileLockProcess -FilePath "/home/pdadmin/Downloads/test.txt"
 
    COMMAND  : bash
    PID      : 244585
    USER     : pdadmin
    FD       : 3w
    TYPE     : REG
    DEVICE   : 253,2
    SIZE/OFF : 0
    NODE     : 100798534
    NAME     : /home/pdadmin/Downloads/test.txt
#>
 
function Get-FileLockProcess {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$FilePath
    )
 
    ##### BEGIN Variable/Parameter Transforms and PreRun Prep #####
 
    if (! $(Test-Path $FilePath)) {
        Write-Error "The path $FilePath was not found! Halting!"
        $global:FunctionResult = "1"
        return
    }
 
    ##### END Variable/Parameter Transforms and PreRun Prep #####
 
 
    ##### BEGIN Main Body #####
 
    if ($PSVersionTable.PSEdition -eq "Desktop" -or $PSVersionTable.Platform -eq "Win32NT") {
        $CurrentlyLoadedAssemblies = [System.AppDomain]::CurrentDomain.GetAssemblies()
 
        $AssembiesFullInfo = $CurrentlyLoadedAssemblies | Where-Object {
            $_.GetName().Name -eq "Microsoft.CSharp" -or
            $_.GetName().Name -eq "mscorlib" -or
            $_.GetName().Name -eq "System" -or
            $_.GetName().Name -eq "System.Collections" -or
            $_.GetName().Name -eq "System.Core" -or
            $_.GetName().Name -eq "System.IO" -or
            $_.GetName().Name -eq "System.Linq" -or
            $_.GetName().Name -eq "System.Runtime" -or
            $_.GetName().Name -eq "System.Runtime.Extensions" -or
            $_.GetName().Name -eq "System.Runtime.InteropServices"
        }
        $AssembiesFullInfo = $AssembiesFullInfo | Where-Object {$_.IsDynamic -eq $False}
 
        $ReferencedAssemblies = $AssembiesFullInfo.FullName | Sort-Object | Get-Unique
 
        $usingStatementsAsString = @"
        using Microsoft.CSharp;
        using System.Collections.Generic;
        using System.Collections;
        using System.IO;
        using System.Linq;
        using System.Runtime.InteropServices;
        using System.Runtime;
        using System;
        using System.Diagnostics;
"@
 
        $TypeDefinition = @"
        $usingStatementsAsString
 
        namespace MyCore.Utils
        {
            static public class FileLockUtil
            {
                [StructLayout(LayoutKind.Sequential)]
                struct RM_UNIQUE_PROCESS
                {
                    public int dwProcessId;
                    public System.Runtime.InteropServices.ComTypes.FILETIME ProcessStartTime;
                }
 
                const int RmRebootReasonNone = 0;
                const int CCH_RM_MAX_APP_NAME = 255;
                const int CCH_RM_MAX_SVC_NAME = 63;
 
                enum RM_APP_TYPE
                {
                    RmUnknownApp = 0,
                    RmMainWindow = 1,
                    RmOtherWindow = 2,
                    RmService = 3,
                    RmExplorer = 4,
                    RmConsole = 5,
                    RmCritical = 1000
                }
 
                [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
                struct RM_PROCESS_INFO
                {
                    public RM_UNIQUE_PROCESS Process;
 
                    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = CCH_RM_MAX_APP_NAME + 1)]
                    public string strAppName;
 
                    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = CCH_RM_MAX_SVC_NAME + 1)]
                    public string strServiceShortName;
 
                    public RM_APP_TYPE ApplicationType;
                    public uint AppStatus;
                    public uint TSSessionId;
                    [MarshalAs(UnmanagedType.Bool)]
                    public bool bRestartable;
                }
 
                [DllImport("rstrtmgr.dll", CharSet = CharSet.Unicode)]
                static extern int RmRegisterResources(uint pSessionHandle,
                                                    UInt32 nFiles,
                                                    string[] rgsFilenames,
                                                    UInt32 nApplications,
                                                    [In] RM_UNIQUE_PROCESS[] rgApplications,
                                                    UInt32 nServices,
                                                    string[] rgsServiceNames);
 
                [DllImport("rstrtmgr.dll", CharSet = CharSet.Auto)]
                static extern int RmStartSession(out uint pSessionHandle, int dwSessionFlags, string strSessionKey);
 
                [DllImport("rstrtmgr.dll")]
                static extern int RmEndSession(uint pSessionHandle);
 
                [DllImport("rstrtmgr.dll")]
                static extern int RmGetList(uint dwSessionHandle,
                                            out uint pnProcInfoNeeded,
                                            ref uint pnProcInfo,
                                            [In, Out] RM_PROCESS_INFO[] rgAffectedApps,
                                            ref uint lpdwRebootReasons);
 
                /// <summary>
                /// Find out what process(es) have a lock on the specified file.
                /// </summary>
                /// <param name="path">Path of the file.</param>
                /// <returns>Processes locking the file</returns>
                /// <remarks>See also:
                /// http://msdn.microsoft.com/en-us/library/windows/desktop/aa373661(v=vs.85).aspx
                /// http://wyupdate.googlecode.com/svn-history/r401/trunk/frmFilesInUse.cs (no copyright in code at time of viewing)
                /// 
                /// </remarks>
                static public List<Process> WhoIsLocking(string path)
                {
                    uint handle;
                    string key = Guid.NewGuid().ToString();
                    List<Process> processes = new List<Process>();
 
                    int res = RmStartSession(out handle, 0, key);
                    if (res != 0) throw new Exception("Could not begin restart session.  Unable to determine file locker.");
 
                    try
                    {
                        const int ERROR_MORE_DATA = 234;
                        uint pnProcInfoNeeded = 0,
                            pnProcInfo = 0,
                            lpdwRebootReasons = RmRebootReasonNone;
 
                        string[] resources = new string[] { path }; // Just checking on one resource.
 
                        res = RmRegisterResources(handle, (uint)resources.Length, resources, 0, null, 0, null);
 
                        if (res != 0) throw new Exception("Could not register resource.");                                    
 
                        //Note: there's a race condition here -- the first call to RmGetList() returns
                        //      the total number of process. However, when we call RmGetList() again to get
                        //      the actual processes this number may have increased.
                        res = RmGetList(handle, out pnProcInfoNeeded, ref pnProcInfo, null, ref lpdwRebootReasons);
 
                        if (res == ERROR_MORE_DATA)
                        {
                            // Create an array to store the process results
                            RM_PROCESS_INFO[] processInfo = new RM_PROCESS_INFO[pnProcInfoNeeded];
                            pnProcInfo = pnProcInfoNeeded;
 
                            // Get the list
                            res = RmGetList(handle, out pnProcInfoNeeded, ref pnProcInfo, processInfo, ref lpdwRebootReasons);
                            if (res == 0)
                            {
                                processes = new List<Process>((int)pnProcInfo);
 
                                // Enumerate all of the results and add them to the 
                                // list to be returned
                                for (int i = 0; i < pnProcInfo; i++)
                                {
                                    try
                                    {
                                        processes.Add(Process.GetProcessById(processInfo[i].Process.dwProcessId));
                                    }
                                    // catch the error -- in case the process is no longer running
                                    catch (ArgumentException) { }
                                }
                            }
                            else throw new Exception("Could not list processes locking resource.");                    
                        }
                        else if (res != 0) throw new Exception("Could not list processes locking resource. Failed to get size of result.");                    
                    }
                    finally
                    {
                        RmEndSession(handle);
                    }
 
                    return processes;
                }
            }
        }
"@
 
        $CheckMyCoreUtilsDownloadIdLoaded = $CurrentlyLoadedAssemblies | Where-Object {$_.ExportedTypes -like "MyCore.Utils.FileLockUtil*"}
        if ($null -eq $CheckMyCoreUtilsDownloadIdLoaded) {
            Add-Type -ReferencedAssemblies $ReferencedAssemblies -TypeDefinition $TypeDefinition
        }
        else {
            Write-Verbose "The Namespace MyCore.Utils Class FileLockUtil is already loaded and available!"
        }
 
        $Result = [MyCore.Utils.FileLockUtil]::WhoIsLocking($FilePath)
    }
    if ($null -ne $PSVersionTable.Platform -and $PSVersionTable.Platform -ne "Win32NT") {
        $lsofOutput = lsof $FilePath
 
        function Parse-lsofStrings ($lsofOutput, $Index) {
            $($lsofOutput[$Index] -split " " | ForEach-Object {
                if (![String]::IsNullOrWhiteSpace($_)) {
                    $_
                }
            }).Trim()
        }
 
        $lsofOutputHeaders = Parse-lsofStrings -lsofOutput $lsofOutput -Index 0
        $lsofOutputValues = Parse-lsofStrings -lsofOutput $lsofOutput -Index 1
 
        $Result = [pscustomobject]@{}
        for ($i=0; $i -lt $lsofOutputHeaders.Count; $i++) {
            $Result | Add-Member -MemberType NoteProperty -Name $lsofOutputHeaders[$i] -Value $lsofOutputValues[$i]
        }
    }
 
    $Result
 
    ##### END Main Body #####
 
}
