param($eventGridEvent, $TriggerMetadata)

$caller = $eventGridEvent.data.claims.name
if ($null -eq $caller)
{
    if ($eventGridEvent.data.authorization.evidence.principalType = "ServicePrincipal") {
        $caller = (Get-AzADServicePrincipal -ObjectId $eventGridEvent.data.authorization.evidence.principalId).DisplayName
        if ($null -eq $caller) {
            Write-Host "MSI may not have permission to read the applications from the directory"
            $caller = $eventGridEvent.data.authorization.evidence.principalId
        }
    }
}
Write-Host "Caller: $caller"
$resourceId = $eventGridEvent.data.resourceUri
Write-Host "ResourceId: $resourceId"

if (($null -eq $caller) -or ($null -eq $resourceId)) {
    Write-Host "ResourceId or Caller is null"
    exit;
}

$ignore = @("providers/Microsoft.Resources/deployments", "providers/Microsoft.Resources/tags", "providers/Microsoft.EventGrid/systemTopics")

foreach ($case in $ignore) {
    if ($resourceId -match $case) {
        Write-Host "Skipping event as resourceId contains: $case"
        exit;
    }
}

$tags = (Get-AzTag -ResourceId $resourceId).Properties

if (!($tags.TagsProperty.ContainsKey('CreatedBy')) -or ($null -eq $tags)) {
    $tag = @{
        CreatedBy = $caller
    }
    $null = Update-AzTag -ResourceId $resourceId -Operation Merge -Tag $tag
    Write-Host "Added CreatedBy tag with value: $caller"
}
else {
    Write-Host "Tag already exists"
}