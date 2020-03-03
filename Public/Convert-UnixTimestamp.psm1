<#
.SYNOPSIS
    This function converts a Unix Timestamp (Epoche Time) in a readable date format.
.DESCRIPTION
    This function converts a Unix Timestamp (Epoche Time) in a readable date format.
.NOTES
    Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
    Convert-UnixTimestamp 1582719397
#>

Function Convert-UnixTimestamp {
    Param(
        [Parameter(Mandatory=$true)][int64]$udate
    )
 
    $Timezone = (Get-TimeZone)
    
    #Temp. Remove wrong calculation with DaylightSavingTime
    <#
    If ($Timezone.SupportsDaylightSavingTime -eq $True){
        $TimeAdjust =  ($Timezone.BaseUtcOffset.TotalSeconds + 3600)
    } Else {
        $TimeAdjust = ($Timezone.BaseUtcOffset.TotalSeconds)
    }#>

    #Maybe fixing DaylightSavingTime
    $TimeAdjust = $Timezone.BaseUtcOffset.TotalSeconds
    
    # Adjust time from UTC to local based on offset that was determined before.
    $udate = ($udate + $TimeAdjust)
    
    # Retrieve start of UNIX Format
    $orig = (Get-Date -Year 1970 -Month 1 -Day 1 -hour 0 -Minute 0 -Second 0 -Millisecond 0)
    
    # Return final time
    return $orig.AddSeconds($udate)
}