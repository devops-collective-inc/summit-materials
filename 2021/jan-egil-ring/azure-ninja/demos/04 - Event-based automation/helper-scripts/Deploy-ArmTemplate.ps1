$Subscriptions = Get-AzSubscription | Where-Object State -EQ Enabled | Sort-Object Name

foreach ($Subscription in $Subscriptions) {

    $null = Set-AzContext $Subscription.Id

    $AzureTagCreatedBy = Get-AzEventGridSubscription | Select-Object -ExpandProperty PsEventSubscriptionsList | Where-Object EventSubscriptionName -EQ AzureTagCreatedBy

    if ($AzureTagCreatedBy) {

        Write-Host "Found AzureTagCreatedBy EventGrid Subscription for  $($Subscription.Name)" -ForegroundColor Green

    } else {

        Write-Host " Did not find AzureTagCreatedBy EventGrid Subscription for  $($Subscription.Name) - adding" -ForegroundColor Yellow

        $null = New-AzSubscriptionDeployment `
            -Name EventGridTagCreatedBy `
            -Location norwayeast `
            -TemplateUri 'C:\git\2021-ps-summit-azure-ninja\demos\04 - Event-based automation\arm-templates\eventgridsubscription_tagcreatedby.json' `
            -eventGridSubscriptionName AzureTagCreatedBy `
            -resourceId /subscriptions/2d7558eb-dedc-4617-9227-efc1c1e61234/resourceGroups/infrastructure-automation-rg/providers/Microsoft.Web/sites/it-automation
    }

}