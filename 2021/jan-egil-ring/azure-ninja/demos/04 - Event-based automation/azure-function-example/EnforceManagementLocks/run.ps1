# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran at UTC time: $currentUTCtime"


<#

 AUTHOR: Jan Egil Ring
 EMAIL: jan.egil.ring@outlook.com

 COMMENT: Function to enable delete locks on all resource groups

 Logic:

        -Connect to Azure using Managed Identity
                -Get all subscriptions
                    -Get all resource groups
                        -Check if lock is in place
                            -If no
                                -Create lock

 #>

try {

    Import-Module -Name Az.Resources -RequiredVersion 3.0.0 -ErrorAction Stop

}

catch {

    Write-Error -Message 'Prerequisites not installed (Az.Resources PowerShell module(s) not installed)'

    break

}

$Subscriptions = Get-AzSubscription | Sort-Object Name

foreach ($Subscription in $Subscriptions) {

    Write-Host "Processing subscription $($Subscription.Name)"

    $null = Set-AzContext $Subscription.Id


    $ResourceGroups = Get-AzResourceGroup | Where-Object ResourceGroupName -NotLike "MC_*" | Where-Object ResourceGroupName -NE "NetworkWatcherRG" | Where-Object ResourceGroupName -NotLike "AzureBackupRG*"


    foreach ($ResourceGroup in $ResourceGroups) {

        $ExistingLock = Get-AzResourceLock -ResourceGroupName $ResourceGroup.ResourceGroupName -AtScope

        if (-not ($ExistingLock)) {

            Write-Output "Lock is missing for resource group $($ResourceGroup.ResourceGroupName) - adding"

            New-AzResourceLock -LockName DoNotDelete -LockLevel CanNotDelete -ResourceGroupName $ResourceGroup.ResourceGroupName -LockNotes "Automatically locked by Azure Functions at $(Get-Date)" -Force | Select-Object -ExpandProperty ResourceId

        }

    }

}

Write-Output 'Function completed'