param (
    [Parameter(Mandatory)]
    [string]$JSON_CERT,
    [Parameter(Mandatory)]
    [string]$CERT_SECRET,
    [Parameter(Mandatory)]
    [string]$AAD_APP_ID,
    [switch]$Test
)

$certPath = "$PSScriptRoot\cert.pfx"
[IO.File]::WriteAllBytes($certPath,($JSON_CERT | ConvertFrom-Json | %{[byte]$_}))

$exoSplat = @{
    CertificateFilePath = $certPath
    CertificatePassword = (ConvertTo-SecureString $CERT_SECRET -AsPlainText -Force)
    AppId = $AAD_APP_ID
    Organization = 'domain.onmicrosoft.com'
}
Connect-ExchangeOnline @exoSplat

$config = Get-Content $PSScriptRoot\definitions\config.json | ConvertFrom-Json -AsHashtable
$regionBased = Get-Content $PSScriptRoot\definitions\Regionbased.json | ConvertFrom-Json -AsHashtable

$ddgs = Get-DynamicDistributionGroup
$ddgHt = @{}
foreach ($ddg in $ddgs) {
    $ddgHt[$ddg.name] = $ddg
}

foreach ($region in $config['Regions']) {
    $region

    foreach ($ddl in $regionBased.Keys | sort) {
        if ($regionBased[$ddl]['Regions'] -contains $region -or $regionBased[$ddl]['Regions'] -eq 'all') {
            $name = "$($config['prefix'])-" + ($regionBased[$ddl]['Name'] -replace ('\$Region',$region -replace ' ',''))
            "- $name"
            $filter = $regionBased[$ddl]['Filter'] -replace '\$Region',$region
            if ($ddgs.Name -contains $name) {
                "-- Update: $filter"
                if (-not $Test.IsPresent) {
                    Set-DynamicDistributionGroup $name -RecipientFilter $filter -PrimarySmtpAddress "$name`@domain.com"
                }
            } else {
                "-- Create: $filter"
                if (-not $Test.IsPresent) {
                    New-DynamicDistributionGroup $name -RecipientFilter $filter -PrimarySmtpAddress "$name`@domain.com"
                }
            }
        }
    }
}