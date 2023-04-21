#region Understanding the method

$uri = 'https://httpbin.org/post'
$Body = @{
    Make = 'Ford'
    Model = 'GT'
    Color = 'Blue'
    Year  = '2023'
}

$irmParams = @{
    Uri = $Uri
    Method = 'POST'
    ContentType = 'application/json'
    Body = ($Body | ConvertTo-Json)
}

Invoke-RestMethod @irmParams
#endregion

#region Make it a tool
function New-Widget {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String]
        $Make,

        [Parameter()]
        [String]
        $Model,

        [Parameter()]
        [String]
        $Color,

        [Parameter()]
        [Int]
        [ValidateRange(2001,2023)]
        $Year
    )

    process {
        $uri = 'https://httpbin.org/post'
$Body = @{
    Make = $Make
    Model = $Model
    Color = $Color
    Year  = $Year
}

$irmParams = @{
    Uri = $Uri
    Method = 'POST'
    ContentType = 'application/json'
    Body = ($Body | ConvertTo-Json)
}

Invoke-RestMethod @irmParams
    }
}
#endregion
