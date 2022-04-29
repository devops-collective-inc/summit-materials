param (
    [Parameter(Mandatory)]
    [string]$JSON_CERT,
    [Parameter(Mandatory)]
    [string]$CERT_SECRET,
    [Parameter(Mandatory)]
    [string]$AAD_APP_ID,
    [Parameter(Mandatory)]
    [string]$AAD_TENANT_ID,
    [switch]$Test
)

#region Connect to Graph
$certPath = "$PSScriptRoot\cert.pfx"
[IO.File]::WriteAllBytes($certPath,($JSON_CERT | ConvertFrom-Json | %{[byte]$_}))

$mgSplat = @{
    Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certPath,(ConvertTo-SecureString $CERT_SECRET -AsPlainText -Force))
    ClientId = $AAD_APP_ID
    TenantId = $AAD_TENANT_ID
}
Connect-MgGraph @mgSplat | Out-Null
#endregion

"Loading sites from the repository..."

# Load sites
$sites = Get-Content $PSScriptRoot\Sites.txt

# Load Config
$config = Get-Content $PSScriptRoot\config.json | ConvertFrom-Json -AsHashtable

# Import the module so we can work with certain types
Import-Module Microsoft.Graph.Users

"Retrieving Azure AD license information..."
# Load license ID
$subSku = Get-MgSubscribedSku | Where-Object {$_.SkuPartNumber -eq $config['aadLicenseSkuPartNumber']}

# Load groups
$groups = @{}
foreach ($group in $config['groups']) {
    "Retrieving members of '$group'"
    $groups[$group] = Get-MgGroup -Filter "DisplayName eq '$group'"
    $groups["members_$group"] = Get-MgGroupMember -GroupId $tmpGroup.Id -All
}

"Retrieving all MFP service accounts..."
# Get all MFP accounts
$existingSiteUsers = Get-MgUser -Filter "startswith(displayName,'$($config['prefix'])')" -Select MailNickname,UserPrincipalName,Mail,UsageLocation,DisplayName,AccountEnabled,PasswordPolicies,AssignedLicenses,Id -All

"Determining which sites from the repository already exist..."
# Put them in a hashtable
$existingSiteUsersHt = @{}
foreach ($su in $existingSiteUsers) {
    $existingSiteUsersHt[$su.UserPrincipalName] = $su
}

foreach ($site in $sites) {
    $site
    $accountName = "$($config['prefix']).$($user.site)"
    $upn = "$accountName@$($config['accountDomain'])"
    $mguserSplat = @{
        AssignedLicenses = @(@{SkuId = $subSku.SkuId})
        MailNickname = $accountName
        UserPrincipalName = $upn
        Mail = $upn
        UsageLocation = 'US'
        DisplayName = $accountName
        AccountEnabled = $true
        PasswordPolicies = 'DisablePasswordExpiration'
    }

    if ($existingSiteUsersHt.Keys -contains $upn) {
        "- Site MFP account already exists, updating"
        if (-not $Test.IsPresent) {
            Set-MgUser @mguserSplat
        }
    } else {
        "- Creating site account"
        if (-not $Test.IsPresent) {
            New-MgUser @mguserSplat
        }
    }

    $mgUser = Get-MgUser -UserId $upn

    foreach ($group in $config['groups']) {
        if ($groups["members_$group"].Id -notcontains $mgUser.Id) {
            "- User not a member of '$group'"
            if (-not $Test.IsPresent) {
                New-MgGroupMember -GroupId $groups[$group].Id -DirectoryObjectId $mguser.Id
            }
        }
    }
}