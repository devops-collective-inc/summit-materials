
param(
    [Parameter(Mandatory)]
    $CardName,
    [Parameter()]
    [ValidateSet('Json', 'Csv')]
    $Format = 'Json',
    [Parameter()]
    [Switch]$Pretty 
)

$Card = Get-PSUCache -Key $CardName
if ($Card) {
    return $Card
}

$Card = (Invoke-RestMethod "$ScryfallApi/cards/search?q=$CardName&format=$Format&pretty=$($Pretty.IsPresent)").data | ForEach-Object {
    @{
        Name = $_.name 
        Type = $_.type_line
        Set  = $_.set_name
        Link = @{
            type = 'link'
            url  = "/card/$($_.Id)"
            text = "Info"
        }
    }
}
Set-PSUCache -Key $CardName -Value $Card -AbsoluteExpirationFromNow (New-TimeSpan -Minutes 10)
$Card
