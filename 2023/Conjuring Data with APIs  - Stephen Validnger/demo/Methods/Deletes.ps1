#region Understanding the Method
$uri = 'https://httpbin.org/delete/{id}'

$irmParams = @{
    Uri = $uri
    Method = 'DELETE'
    ContentType = 'application/json'
}

Invoke-RestMethod @irmParams
#endregion

#region Make it a tool
function Remove-Widget {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [Int]
        $Id
    )

    process {
        $irmParams = @{
            Uri = "https://httpbin.org/delete/$Id"
            Method = 'DELETE'
            ContentType = 'application/json'
        }

        Invoke-RestMethod @irmParams
    }
}
#endregion

#region Make it a SAFE tool

# Kevin Marquette to the rescue! https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3
function Remove-Widget {
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
    Param(
        [Parameter(Mandatory)]
        [Int]
        $Id,

        [Parameter()]
        [Switch]
        $Force
    )

    process {
        $irmParams = @{
            Uri = "https://httpbin.org/delete/$Id"
            Method = 'DELETE'
            ContentType = 'application/json'
        }

        if ($Force -and -not $Confirm) {
            $ConfirmPreference = 'None'
            if ($PSCmdlet.ShouldProcess("$_", "Remove Widget")) {
                Write-Verbose $($Body | ConvertTo-Json)
                Invoke-RestMethod @irmParams
            }
        }
        else {
            if ($PSCmdlet.ShouldProcess("$_", "Remove Widget")) {
                Write-Verbose $($Body | ConvertTo-Json)
                Invoke-RestMethod @irmParams
            }
        }
    }
}
#endregion
