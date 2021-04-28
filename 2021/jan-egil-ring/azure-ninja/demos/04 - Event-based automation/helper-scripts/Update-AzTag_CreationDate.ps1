Import-Module -Name Az.Accounts -RequiredVersion 1.9.2

$Subscriptions = Get-AzSubscription | Where-Object State -EQ Enabled | Sort-Object Name

$Tags = @{CreationDate = "N/A - Created before 2021-04-14"; CreatedBy = "N/A - Created before 2021-04-14" }

foreach ($Subscription in $Subscriptions) {

    Write-Host "Processing subscription $($Subscription.Name)"

    $null = Set-AzContext $Subscription.Id

    Get-AzResource | ForEach-Object {
    #Get-AzResourceGroup | foreach {
        $PSItem.ResourceId
        if ($PSItem.Tags) {
            if (-not ($PSItem.Tags.ContainsKey('CreationDate'))) {

                $null = Update-AzTag -Tag $Tags -ResourceId $PSItem.ResourceId -Operation Merge -Ea Ignore

            }

        } else {

            $null = Update-AzTag -Tag $Tags -ResourceId $PSItem.ResourceId -Operation Merge -Ea Ignore

        }
    }

}