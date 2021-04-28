#region PowerShell on Linux

# Getting into the Linux world as a PowerShell user
Start-Process "https://www.powershell.no/linux,/powershell,/devops/2021/02/25/learning-linux.html"

# Get parameter completion for native Unix utilities
Install-Module -Name Microsoft.PowerShell.UnixCompleters

#endregion

#region Secret management

Start-Process https://devblogs.microsoft.com/powershell/secretmanagement-and-secretstore-are-generally-available/

Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore

$SubscriptionId = (Get-AzContext).Subscription.Id
$VaultName = (Get-AzKeyVault -VaultName jer-infra-vault).VaultName

Register-SecretVault -Module Az.KeyVault -Name jer-infra-vault -VaultParameters @{ AZKVaultName = $VaultName; SubscriptionId = $SubscriptionId}

Get-SecretVault

Get-SecretInfo -Vault jer-infra-vault

Get-Secret -Name demosecret

Get-Secret -Name demosecret -AsPlainText

# The SecretStore vault stores secrets locally on file for the current user, and uses .NET Core cryptographic APIs to encrypt file contents. This extension vault is configurable and works over all supported PowerShell platforms on Windows, Linux, and macOS.
Register-SecretVault -Name SecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault

Set-Secret -Name DemoSecret -Secret "S0meP@ssw0rd"

Get-SecretInfo -Vault SecretStore

Get-Secret -Name DemoSecret -Vault SecretStore

Get-Secret -Name DemoSecret -Vault SecretStore -AsPlainText


# Using the SecretStore in Automation
Set-SecretStoreConfiguration -Scope CurrentUser -Authentication Password -PasswordTimeout 3600 -Interaction None -Password $password -Confirm:$false

<#
To find SecretManagement extension vault modules, search the PowerShell Gallery for the “SecretManagement” tag
- KeePass
- LastPass
- Hashicorp Vault
- KeyChain
- CredMan
#>

#endregion

#region PSArm

Start-Process https://devblogs.microsoft.com/powershell/announcing-the-preview-of-psarm/

Install-Module -Name PSArm -AllowPrerelease

$PSArmTemplatePath = 'C:\git\2021-ps-summit-azure-ninja\demos\01 - Tooling\PSArm-example\StorageAccount.psarm.ps1'
$ArmTemplatePath = $PSArmTemplatePath.Replace('psarm.ps1','json')

# The following example builds an ARM template to create a new storage account:

Open-EditorFile -Path $PSArmTemplatePath

# With the above PSArm script saved to newStorageAccount.psarm.ps1, you can turn it into an ARM JSON template with the Publish-PSArmTemplate cmdlet:

Publish-PSArmTemplate -Path $PSArmTemplatePath -Parameters @{
    storageAccountName = 'psarmdemo01'
    location = 'norwayeast'
} -OutFile $ArmTemplatePath

Open-EditorFile -Path $ArmTemplatePath

# This will create the equivalent ARM template in .\template.json. This file can then be deployed like any other ARM template, for example using Azure PowerShell:

New-AzResourceGroup -Name demo-rg -Location norwayeast
New-AzResourceGroupDeployment -ResourceGroupName demo-rg -TemplateFile $ArmTemplatePath -Force -Name Complete

Start-Process https://github.com/PowerShell/PSArm/tree/master/examples

# Clean up
Remove-AzResourceGroup -Name demo-rg