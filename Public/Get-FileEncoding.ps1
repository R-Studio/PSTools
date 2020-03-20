<#
.SYNOPSIS
    Get file encoding. 
.DESCRIPTION
	Gets the file encoding by looking at BYte Order Mark (BOM).
	Based on port of C# code from http://www.west-wind.com/Weblog/posts/197245.aspx
.NOTES
	Author: Robin Hermann
.LINK
    http://wiki.webperfect.ch
.EXAMPLE
	Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'} | foreach {(get-content $_.FullName) | Set-Content $_.FullName -Encoding ASCII}
	This command gets ps1 files in current directory where encoding is not ASCII and set that to ASCII with "Set-Content".
#>

Function Get-FileEncoding {
	[CmdletBinding()] 
	param (
		[Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$True)] 
		[string]$Path
	)
	
	process{
		$legacyEncoding = $false
		
		#Write-Host Bytes: $byte[0] $byte[1] $byte[2] $byte[3]
		try {
			try {
				[byte[]]$byte = Get-Content -AsByteStream -ReadCount 4 -TotalCount 4 -LiteralPath $Path
			} catch {
				[byte[]]$byte = Get-Content -Encoding Byte -ReadCount 4 -TotalCount 4 -LiteralPath $Path
				$legacyEncoding = $true
			}
			
			if (!$byte) {
				if ($legacyEncoding) { 
					"unknown" 
				} else {
					[System.Text.Encoding]::Default
				}
			}
		} catch {
			throw
		}
	
		# EF BB BF (UTF8)
		if ($byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf) { 
			if ($legacyEncoding) {
				Write-Output 'UTF8'
			} else {
				[System.Text.Encoding]::UTF8
			}
		} 
		# FE FF  (UTF-16 Big-Endian)
		elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff) { 
			if ($legacyEncoding) { 
				Write-Output 'Unicode UTF-16 Big-Endian'
			} else {
				 [System.Text.Encoding]::BigEndianUnicode
			}
		}
	
		# FF FE  (UTF-16 Little-Endian)
		elseif ($byte[0] -eq 0xff -and $byte[1] -eq 0xfe) { 
			if ($legacyEncoding) {
				Write-Output 'Unicode UTF-16 Little-Endian' 
			} else {
				[System.Text.Encoding]::Unicode 
			}
		}
	
		# 00 00 FE FF (UTF32 Big-Endian)
		elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff) { 
			if ($legacyEncoding) {
				Write-Output 'UTF32 Big-Endian'
			} else {
				[System.Text.Encoding]::UTF32
			}
		}
	
		# FE FF 00 00 (UTF32 Little-Endian)
		elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff -and $byte[2] -eq 0 -and $byte[3] -eq 0) { 
			if ($legacyEncoding) {
				Write-Output 'UTF32 Little-Endian'
			} else {
				[System.Text.Encoding]::UTF32
			}
		}
	
		# 2B 2F 76 (38 | 38 | 2B | 2F)
		elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76 -and ($byte[3] -eq 0x38 -or $byte[3] -eq 0x39 -or $byte[3] -eq 0x2b -or $byte[3] -eq 0x2f)) { 
			if ($legacyEncoding) {
				Write-Output 'UTF7'
			} else {
				[System.Text.Encoding]::UTF7
			} 
		}
	
		# F7 64 4C (UTF-1)
		elseif ( $byte[0] -eq 0xf7 -and $byte[1] -eq 0x64 -and $byte[2] -eq 0x4c ) { 
			throw "UTF-1 not a supported encoding"
		}
	
		# DD 73 66 73 (UTF-EBCDIC)
		elseif ($byte[0] -eq 0xdd -and $byte[1] -eq 0x73 -and $byte[2] -eq 0x66 -and $byte[3] -eq 0x73) { 
			throw "UTF-EBCDIC not a supported encoding"
		}
	
		# 0E FE FF (SCSU)
		elseif ($byte[0] -eq 0x0e -and $byte[1] -eq 0xfe -and $byte[2] -eq 0xff) { 
			throw "SCSU not a supported encoding"
		}
	
		# FB EE 28  (BOCU-1)
		elseif ($byte[0] -eq 0xfb -and $byte[1] -eq 0xee -and $byte[2] -eq 0x28) { 
			throw "BOCU-1 not a supported encoding"
		}
	
		# 84 31 95 33 (GB-18030)
		elseif ($byte[0] -eq 0x84 -and $byte[1] -eq 0x31 -and $byte[2] -eq 0x95 -and $byte[3] -eq 0x33) { 
			throw "GB-18030 not a supported encoding"
		} 
		
		# If there is no matches, then ASCII
		else { 
			if ($legacyEncoding) {
				Write-Output 'ASCII' 
			} else {
				[System.Text.Encoding]::ASCII
			}
		}
	}
}