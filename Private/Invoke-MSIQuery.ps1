Function Invoke-MSIQuery {
    param($FilePath, $Query)

    try {
        $windowsInstaller = New-Object -com WindowsInstaller.Installer
        $database = $windowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $Null, $windowsInstaller, @($FilePath, 0))
    }
    catch {
        throw "Failed to open MSI file. The error was: {0}." -f $_
    }
    
    try {
        $View = $database.GetType().InvokeMember("OpenView", "InvokeMethod", $Null, $database, ($query))
        $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null)
    
        $record = $View.GetType().InvokeMember("Fetch", "InvokeMethod", $Null, $View, $Null)
        $property = $record.GetType().InvokeMember("StringData", "GetProperty", $Null, $record, 1)
    
        $View.GetType().InvokeMember("Close", "InvokeMethod", $Null, $View, $Null)
    
        return $property
    }
    catch {
        throw "Failed to read MSI file. The error was: {0}." -f $_
    }
}