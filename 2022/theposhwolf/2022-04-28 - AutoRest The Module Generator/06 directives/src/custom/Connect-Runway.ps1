Function Connect-Runway {
    [cmdletbinding()]
    [OutputType()]
    param (
        [Parameter(
            Position = 0,
            Mandatory
        )]
        [string]$Email,
        [Parameter(Mandatory)]
        [SecureString]$Password,
        [string]$RunwayDomain = 'portal.runway.host'
    )
    $env:RunwayDomain = $RunwayDomain

    $s = Invoke-RwLoginAuthentication -Email $Email -Password ([pscredential]::new('blah',$Password).GetNetworkCredential().Password) -Remember
    $env:RunwaySessionToken = $s.Session
}