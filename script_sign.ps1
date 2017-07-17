New-SelfSignedCertificate -DnsName test.imjoseangel.com -CertStoreLocation cert:\LocalMachine\My -type CodeSigning
$cert = @(Get-ChildItem cert:\LocalMachine\My -CodeSigning)[0] 
Set-AuthenticodeSignature .\scriptTosing.ps1 $cert
