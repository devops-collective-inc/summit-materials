#region Understanding the method

$uri = 'https://httpbin.org/put'
$Body = @{
    Make  = 'Ford'
    Model = 'GT'
    Color = 'Blue'
    Year  = '2023'
}

$irmParams = @{
    Uri         = $Uri
    Method      = 'PUT'
    ContentType = 'application/json'
    Body        = ($Body | ConvertTo-Json)
}

Invoke-RestMethod @irmParams
#endregion

#region Tool
function Set-Widget {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [Int]
        $Id,

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

    begin {
        #Get the object to update
        $getParams = @{
            Uri = "https://httpbin.org/get/$Id"
            Method = 'GET'
            ContentType = 'application/json'
        }
        $data = Invoke-RestMethod @getParams
    }
    process {
        $uri = 'https://httpbin.org/put'
        $Body = @{}
        
        if( $data.id){
            $Body.Add('Id',$data.id)
        } else { $Body.Add('Id',$Id)}
        if($Make){
            $Body.Add('Make',$Make)
        } else { $Body.Add('Make',$data.Make)}

        if($Model){
            $Body.Add('Model',$Model)
        } else { $Body.Add('Model',$data.Model)}

        if($Color){
            $Body.Add('Color',$Color)
        } else { $Body.Add('Color',$data.Color)}

        if($Year){
            $Body.Add('Year',$Year)
        } else {$Body.Add('Year',$data.Year)}

        $irmParams = @{
            Uri         = $Uri
            Method      = 'PUT'
            ContentType = 'application/json'
            Body        = ($Body | ConvertTo-Json)
        }

        Invoke-RestMethod @irmParams
    }
}
#endregion