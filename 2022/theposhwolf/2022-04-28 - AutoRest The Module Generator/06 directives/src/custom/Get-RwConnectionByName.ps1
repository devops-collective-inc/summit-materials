Function Get-RwConnectionByName {
    [CmdletBinding(
        DefaultParameterSetName = 'ByName'
    )]
    param (
        [Parameter(
            ParameterSetName = 'ByName',
            Position = 0
        )]
        [Alias('Name')]
        [string[]]$ConnectionName
    )
    if ($ConnectionName.Count -gt 1) {
        $filterChildren = foreach ($name in $ConnectionName) {
            @{
                Left = 'Name'
                Operator = '='
                Right = $name
            }
        }
        $query = @{
            includeSubgroups = $true
            skip = 0
            take = 100
            sortDirection = 0
            filter = @{
                children = $filterChildren
                operator = 'OR'
            }
        }
    } else {
        $query = @{
            includeSubgroups = $true
            skip = 0
            take = 100
            SortDirection = 0
            filter = @{
                Left = 'Name'
                Operator = '='
                Right = $ConnectionName[0]
            }
        }
    }
    (Invoke-RwQueryConnection -Query $query).Items
}