Import-Module -Name Az.Accounts -RequiredVersion 1.9.2

$Subscriptions = Get-AzSubscription | Where-Object State -EQ Enabled | Sort-Object Name

$Tags = @{CreationDate = "N/A - Created before 2021-04-14"; CreatedBy = "N/A - Created before 2021-04-14" }

foreach ($Subscription in $Subscriptions) {

    Write-Host "Processing subscription $($Subscription.Name)"

    $null = Set-AzContext $Subscription.Id

    Get-AzResourceGroup | ForEach-Object {

        $ActivityLogEntries = Get-AzLog -ResourceId $PSItem.ResourceId -WarningAction Ignore

        if ($ActivityLogEntries) {

            Write-Host "Found $($ActivityLogEntries.Count) activity log entries for resource group $($PSItem.ResourceGroupName)" -ForegroundColor Yellow

            $CreatedBy = $ActivityLogEntries[-1].Caller

            Write-Host "Setting CreatedBy for for resource group $($PSItem.ResourceGroupName) to $CreatedBy" -ForegroundColor Yellow

            $Tags = @{CreatedBy = $CreatedBy }

            if ($PSItem.Tags) {
                if (-not ($PSItem.Tags.Contains('CreatedBy'))) {

                    $null = Update-AzTag -Tag $Tags -ResourceId $PSItem.ResourceId -Operation Merge

                }

            } else {

                $null = Update-AzTag -Tag $Tags -ResourceId $PSItem.ResourceId -Operation Merge

            }

        } else {

            Write-Host "No activity log entries found for resource group $($PSItem.ResourceGroupName)" -ForegroundColor Yellow

        }

    }

}