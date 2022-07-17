
New-PSUEndpoint -Url "/random-card" -Method @('GET') -Endpoint {
    $Random = Invoke-RestMethod "$ScryfallApi/cards/random"
    $Random | ForEach-Object {
        @{
            Name       = $_.name 
            Type       = $_.type_line
            Set        = $_.set_name
            Image      = $_.image_uris.large
            Text       = $_.oracle_text
            FlavorText = $_.flavor_text
        }
    }
} -ErrorAction "Stop" 

New-PSUEndpoint -Url "/cards/:id" -Method @('GET') -Endpoint {
    param(
        [Parameter(Mandatory)]
        $Id
    )

    $Card = Get-PSUCache -Key $Id
    if ($Card) {
        return $Card
    }

    $Card = Invoke-RestMethod "$ScryfallApi/cards/$Id" | ForEach-Object {
        @{
            Name       = $_.name 
            Type       = $_.type_line
            Set        = $_.set_name
            Image      = $_.image_uris.large
            Text       = $_.oracle_text
            FlavorText = $_.flavor_text
        }
    }
    Set-PSUCache -Key $Id -Value $Card -AbsoluteExpirationFromNow (New-TimeSpan -Minutes 10)
    $Card
} 


New-PSUEndpoint -Url "/random-card" -Method @('GET') -Endpoint {
    $Random = Invoke-RestMethod "$ScryfallApi/cards/random"

    $Stats = Get-PSUCache -Key 'Stats'
    if ($Stats -eq $null) {
        $Stats = @{
            Colors = @{}
            Sets   = @()
        }
    }

    if ($Stats.Sets -notcontains $Random.set_name) {
        $Stats.Sets.Add($Random.set_name) | Out-Null
    }

    $Random.Colors | ForEach-Object {
        if ($Stats.Colors.ContainsKey($_)) {
            $Stats.Colors[$_] += 1
        }
        else {
            $Stats.Colors[$_] = 1
        }
    }

    Set-PSUCache -Key 'Stats' -Value $Stats

    $Random | ForEach-Object {
        @{
            Name       = $_.name 
            Type       = $_.type_line
            Set        = $_.set_name
            Image      = $_.image_uris.large
            Text       = $_.oracle_text
            FlavorText = $_.flavor_text
        }
    }
} -ErrorAction "Stop" 
New-PSUEndpoint -Url "/card-stats/colors" -Method @('GET') -Endpoint {
    $Stats = Get-PSUCache -Key "Stats"
    $Stats.Colors.Keys | ForEach-Object {
        @{ Color = $_; Value = $Stats.Colors[$_] }
    }
} -ErrorAction "Stop" 
New-PSUEndpoint -Url "/card-stats/sets" -Method @('GET') -Endpoint {
    $Stats = Get-PSUCache -Key 'Stats'
    $Stats.Sets | ForEach-Object {
        @{
            Name = $_
        }
    }
}