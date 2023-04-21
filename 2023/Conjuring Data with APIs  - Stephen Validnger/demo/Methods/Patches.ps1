#region Understanding the method
$uri = 'https://httpbin.org/patch'
$body = @{
    Enabled = $true
}

$irmParams = @{
    Uri         = $uri
    Method      = 'PATCH'
    ContentType = 'application/json'
    Body        = $body | ConvertTo-Json
}

Invoke-RestMethod @irmParams
#endregion

#region Make it a tool
function Set-Widget {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [String]
        $Name,

        [Parameter()]
        [Switch]
        $Enabled
    )

    process {
        #region Understanding the method
        $uri = 'https://httpbin.org/patch'
        $body = @{
            Name = $Name
            Enabled = if($Enabled){ $true } else { $false }
        }

        $irmParams = @{
            Uri         = $uri
            Method      = 'PATCH'
            ContentType = 'application/json'
            Body        = $body | ConvertTo-Json
        }

        Invoke-RestMethod @irmParams
    }
}
#endregion

#region Closer look at usage
function Get-Widget {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String]
        $Name
    )

    process {
        #region Understanding the method
        $uri = 'https://httpbin.org/get'
        $body = @{
            Name = $Name
        }

        $irmParams = @{
            Uri         = $uri
            Method      = 'GET'
            ContentType = 'application/json'
            Body        = $body | ConvertTo-Json
        }

        $response = Invoke-RestMethod @irmParams
        
        #Fake it because of httpbin
        [pscustomobject]@{
            Name = $Name
        }

    }
}