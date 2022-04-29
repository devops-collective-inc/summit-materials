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

### Directives

``` yaml
directive:
  # They becomes Import-* due to how AutoRest correlates the *Load OperationId to a verb
  # https://github.com/Azure/autorest.powershell/blob/main/powershell/internal/name-inferrer.ts
  - where:
      verb: Import
    set:
      verb: Get
  # Convert invoke-counts to get-counts
  # i.e.: Invoke-RwCountRunner becomes Get-RwRunnerCount
  - where:
      verb: Invoke
      subject: Count([a-zA-Z]+)$
    set:
      verb: Get
      subject: $1Count
  # Set the url to pull from the RunwayDomain environment variable
  # This makes it so we can configure the domain in the event that
  # we need to talk to staging or when Runway is customer hosted.
  - from: source-file-csharp
    where: $
    transform: >
      if ($documentPath.match(/Runway.cs/gm)) {
        // line to match:
        // var _url = new global::System.Uri($"https://portal.runway.host{pathAndQuery}");
        // replace portal.runway.host with environmental variable
        let urlRegex = /var _url = [^\r\n;]+portal\.runway\.host[^\r\n;]+;/gmi
        $ = $.replace(urlRegex,'var _url = new global::System.Uri($"https://{System.Environment.GetEnvironmentVariable("RunwayDomain")}{pathAndQuery}");');

        return $;
      } else {
        return $;
      }
```
