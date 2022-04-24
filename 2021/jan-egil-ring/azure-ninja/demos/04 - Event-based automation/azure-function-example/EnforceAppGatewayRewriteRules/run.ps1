param($eventGridEvent, $TriggerMetadata)

<#

 AUTHOR: Jan Egil Ring
 EMAIL: jan.egil.ring@outlook.com

 COMMENT: Function to ensure rewrite set is enforced for all routing rules in Application Gateway

 Logic:

        -Connect to Azure using Managed Identity
        -Check if resource type is Microsoft.Network/applicationGateways
            -If Yes
                -Ensure all routing rules is enabled in the Rewrite Set X-Forwarded-For

 #>

try {

    Import-Module -Name Az.Network -RequiredVersion 3.3.0 -ErrorAction Stop

}

catch {

    Write-Error -Message 'Prerequisites not installed (Az.Resources PowerShell module(s) not installed)'

    $PSItem.Exception.Message

    break

}

$null = Set-AzContext 32927346-1234-4d03-ab1a-7b6636e377dd

$caller = $eventGridEvent.data.claims.name
Write-Host "Caller: $caller"
$resourceId = $eventGridEvent.data.resourceUri
Write-Host "ResourceId: $resourceId"

if ($null -eq $resourceId) {
    Write-Host "ResourceId is null"
    exit;
}

if ($resourceId -like "*Microsoft.Network/applicationGateways*") {

    Write-Host "Resource Id matches Microsoft.Network/applicationGateways - ensuring rewrite rules is enforced"
    $resourceId

    $appGateway = Get-AzApplicationGateway | Where-Object Id -EQ $resourceId

    $rewriteRuleSet = Get-AzApplicationGatewayRewriteRuleSet -Name X-Forwarded-For -ApplicationGateway $appGateway

    if ($rewriteRuleSet) {

        $Rules = Get-AzApplicationGatewayRequestRoutingRule -ApplicationGateway $appGateway

        foreach ($Rule in $Rules) {

            if (-not ($Rule.RewriteRuleSet )) {

                Write-Host "Missing RewriteRuleSet association for $($Rule.Name) - mitigating"

                $ruleHttpListener = Get-AzApplicationGatewayHttpListener -ApplicationGateway $appGateway | Where-Object Id -EQ $Rule.HttpListener.Id
                $ruleBackendHttpSettings = Get-AzApplicationGatewayBackendHttpSetting -ApplicationGateway $appGateway | Where-Object Id -EQ $rule.BackendHttpSettings.Id
                $ruleBackendAddressPool = Get-AzApplicationGatewayBackendAddressPool -ApplicationGateway $appGateway | Where-Object Id -EQ $rule.BackendAddressPool.Id
                $appGateway = Set-AzApplicationGatewayRequestRoutingRule -ApplicationGateway $appGateway -RuleType Basic -RewriteRuleSet $rewriteRuleSet -Name $Rule.Name -HttpListener $ruleHttpListener -BackendHttpSettings $ruleBackendHttpSettings -BackendAddressPool $ruleBackendAddressPool

                $null = Set-AzApplicationGateway -ApplicationGateway $appGateway

            }

        }

    }


} else {

    Write-Host "Resource Id does not match Microsoft.Network/applicationGateways - skipping"
    $resourceId

}