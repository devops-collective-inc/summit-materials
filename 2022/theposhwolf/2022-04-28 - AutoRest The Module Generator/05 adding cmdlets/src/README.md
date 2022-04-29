### AutoRest Configuration

``` yaml
use: "@autorest/powershell@3.0.471"
input-file: ../../02 sample/swagger.json
azure: false
powershell: true
output-folder: ./
clear-output-folder: true
namespace: RunwaySdk.PowerShell
title: Runway
prefix: Rw
module-version: 0.0.1
metadata:
    authors: ThePoShWolf
    owners: Runway Software
    companyName: Runway Software
    description: "The PowerShell SDK for the Runway API"
    copyright: &copy; Runway Software. All rights reserved.
    tags: Runway PowerShell
    requireLicenseAcceptance: false
    projectUri: https://github.com/runway-software/runway-powershell
    licenseUri: https://github.com/Runway-Software/runway-powershell/blob/main/license.txt
```