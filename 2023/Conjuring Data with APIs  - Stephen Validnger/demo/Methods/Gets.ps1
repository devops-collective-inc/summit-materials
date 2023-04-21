# Standalone

#region Not so good

$irmParams = @{
    Uri            = 'https://chocoserver.steviecoaster.dev/api/services/app/Computers/GetAll'
    Method         = 'GET'
    ContentType    = 'application/json'
    Credential     = (Get-Credential)
    Authentication = 'Basic'
}

irm @irmParams
#endregion

#region This'll work
function Connect-CCMServer {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]
        $CcmServerHostname,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [Switch]
        $UseSSL
    )

    process {
        $script:CcmHost = $CcmServerHostname
        $script:protocol = if ($UseSSL) {
            'https'
        }
        else {
            'http'
        }

        $body = @{
            usernameOrEmailAddress = $Credential.UserName
            password               = $Credential.GetNetworkCredential().Password
        }
        $Result = Invoke-WebRequest -Uri "$($protocol)://$CcmServerHostname/Account/Login" -Method POST -ContentType 'application/x-www-form-urlencoded' -Body $body -SessionVariable Session -ErrorAction Stop
        $script:Session = $Session
    }
}


$irmParams = @{
    Uri         = 'https://chocoserver.steviecoaster.dev/api/services/app/Computers/GetAll'
    Method      = 'GET'
    ContentType = 'application/json'
    #Credential = (Get-Credential)
    WebSession  = $Session
}

Invoke-RestMethod @irmParams

#endregion

#region Cleaner

$irmParams = @{
    Uri         = 'https://chocoserver.steviecoaster.dev/api/services/app/Computers/GetAll'
    Method      = 'GET'
    ContentType = 'application/json'
    #Credential = (Get-Credential)
    WebSession  = $Session
}

$result = Invoke-RestMethod @irmParams
$result.result

#endregion

#region Make it a something reusable
function Get-CCMComputer {
    [CmdletBinding()]
    Param()

    process {
        $irmParams = @{
            Uri         = 'https://chocoserver.steviecoaster.dev/api/services/app/Computers/GetAll'
            Method      = 'GET'
            ContentType = 'application/json'
            #Credential = (Get-Credential)
            WebSession  = $Session
        }
        
        $result = Invoke-RestMethod @irmParams
        $data = $result.result 

        $data | Foreach-Object {
            $_
        }
    }        
}
#endregion

#region Make it a _tool_
function Get-CCMComputer {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String[]]
        $Name,

        [Parameter()]
        [Switch]
        $Detailed

    )

    process {
        $irmParams = @{
            Uri         = 'https://chocoserver.steviecoaster.dev/api/services/app/Computers/GetAll'
            Method      = 'GET'
            ContentType = 'application/json'
            #Credential = (Get-Credential)
            WebSession  = $Session
        }
        
        $result = Invoke-RestMethod @irmParams

        if ($Name) {
            $data = $result.result | Where-Object { $_.name -in $Name }
        }
        else { $data = $result.result }

        $data | Foreach-Object {
            if ($Detailed) {
                $_
            }
            else {
                [pscustomobject]@{
                    Id           = $_.Id
                    Name         = $_.name
                    Fqdn         = $_.fqdn
                    FriendlyName = $_.friendlyName
                    IpAddress    = $_.ipAddress
                }
            }
        }
    }        
}
#endregion