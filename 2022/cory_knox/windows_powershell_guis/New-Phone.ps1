function New-Phone {
    param(
        [Parameter(Mandatory)]
        [string]
        $name,
        [Parameter(Mandatory)]
        [string]
        $MAC,
        [string]
        $userid,
        [Parameter(Mandatory)]
        [ValidateSet(
            'Cisco 6941',
            'Cisco 7942',
            'Cisco 7841',
            'Cisco IP Communicator'
        )]
        [string]
        $phoneModel,
        [Parameter(Mandatory)]
        [ValidateSet(
            'SCCP',
            'SIP'
        )]
        [string]
        $protocol,
        [switch]
        $IVRUser,
        [switch]
        $ReplaceDN
    )

    Write-Host "Welcome to my New Phone Script."

    Write-Host @"
    It appears you're creating a phone as follows:
    Name: $name
    MAC Address: $MAC
    UserID: $userid
    Phone Model: $phoneModel
    Protocol: $protocol
    Is IVR User: $IVRUser
    Replacing DirectoryNumber $ReplaceDN
"@

$files = Get-ChildItem C:\code_local\summit-materials -Recurse -File

$files | Sort-Object Name | Out-GridView -Title 'Select the files to delete' -PassThru
$files | Sort-Object Name | Out-GridView -Title 'Select the file to use as a base template' -OutputMode Single


}

Invoke-Expression (show-command New-Phone -passthru) -ErrorAction Ignore
