Function Test-WebServerSSLCert {
    [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
            [string]$URL,
            [Parameter(Position = 1)]
            [ValidateRange(1,65535)]
            [int]$Port = 443,
            [Parameter(Position = 2)]
            [Net.WebProxy]$Proxy,
            [Parameter(Position = 3)]
            [int]$Timeout = 60000,
            [switch]$UseUserContext
        )
     
        If ($URL -like "https://*") {
            $ConnectString = "$url`:$port"
        } Else {
            $ConnectString = "https://$url`:$port"
        }
     
        $WebRequest = [Net.WebRequest]::Create($ConnectString)
        $WebRequest.Proxy = $Proxy
        $WebRequest.Credentials = $null
        $WebRequest.Timeout = $Timeout
        $WebRequest.AllowAutoRedirect = $true
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        try {$Response = $WebRequest.GetResponse()}
        catch {}
        if ($WebRequest.ServicePoint.Certificate -ne $null) {
            $Cert = [Security.Cryptography.X509Certificates.X509Certificate2]$WebRequest.ServicePoint.Certificate.Handle
            try {$SAN = ($Cert.Extensions | Where-Object {$_.Oid.Value -eq "2.5.29.17"}).Format(0) -split ", "}
            catch {$SAN = $null}
            $chain = New-Object Security.Cryptography.X509Certificates.X509Chain -ArgumentList (!$UseUserContext)
            [void]$chain.ChainPolicy.ApplicationPolicy.Add("1.3.6.1.5.5.7.3.1")
            $Status = $chain.Build($Cert)
            $ConnectionInformation = New-Object PSObject -Property ([Ordered]@{ 
                OriginalUri = $ConnectString; 
                ReturnedUri = $Response.ResponseUri; 
                Certificate = [Security.Cryptography.X509Certificates.X509Certificate2]$WebRequest.ServicePoint.Certificate; 
                Issuer = $WebRequest.ServicePoint.Certificate.Issuer; 
                Subject = $WebRequest.ServicePoint.Certificate.Subject; 
                SubjectAlternativeNames = $SAN; 
                CertificateIsValid = $Status; 
                Response = $Response; 
                ErrorInformation = $chain.ChainStatus | ForEach-Object {$_.Status} 
            })
            $ConnectionInformation.PSObject.TypeNames.Add("Indented.LDAP.ConnectionInformation")
            $ConnectionInformation
            $chain.Reset()
            [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
        } else {
            Write-Error $Error[0]
        }
    }