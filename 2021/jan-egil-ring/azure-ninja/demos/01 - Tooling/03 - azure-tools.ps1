#region Azure tooling

# Once per machine/user
Install-Module -Name Az

# Frequent updates (typically monthly), remember to update the module
Update-Module -Name Az

# Check installed version
Get-Module -Name Az -ListAvailable

# If you have never used any PowerShell modules on your computer, verify that the PowerShell execution policy is not set to Restricted
Get-ExecutionPolicy

# If so, changing it to RemoteSigned is recommended
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

# Since PowerShell 3.0, autoloading of modules became available - regardless, explicit import with required version specified is a best practice
Import-Module -Name Az #-RequiredVersion 2.5.0

# Credentials can be specified on each run
$AzureCreds = Get-Credential -UserName user@domain.onmicrosoft.com -Message "Specify Azure credentials"

# Or saved to disk and imported/exported (encrypted using the DPAPI in Windows)
$CredPath = "~\Azure-Credential_$($env:COMPUTERNAME).cred.xml"
#$AzureCreds | Export-Clixml -Path $CredPath
$AzureCreds = Import-Clixml -Path $CredPath

# Connecting to Azure
Connect-AzAccount -Credential $AzureCreds

# In PowerShell 6/7, Device Authentication is required
Connect-AzAccount -UseDeviceAuthentication

Get-AzContext

Get-AzSubscription
Set-AzContext -Subscription 'Microsoft Azure-sponsing'
Set-AzContext -Subscription 380d994a-e9b5-4648-ab8b-815e2ef18a2b
Get-AzSubscription | Out-GridView -PassThru -Title 'Select subscription to operate against' | Set-AzContext

Disconnect-AzAccount

Get-AzVM

Get-AzVM -Name MGMT-AZ-01 | Where-Object ResourceGroupName -eq compute-rg |
Invoke-AzVMRunCommand -CommandId RunPowerShellScript -ScriptPath "~\Git\PSDemo\Domain specific\Azure\sample.ps1"

New-AzVm

New-AzVm -Location norwayeast

Disconnect-AzAccount

#endregion

# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest

Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi

Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

# getting help
az --help

# login
az login

# service principal
az login --service-principal -u "91a8ad81-2f20-4800-8b1d-e6299f20b533" --tenant "7eb05ed1-e512-43a8-b91e-bcf3f53904f2"

az account show
az account list

az account set -s "380d994a-e9b5-4648-ab8b-815e2ef18a2b"

# finding az commands
az find vm

# finding sub command help
az vm --help

Start-Process 'https://docs.microsoft.com/en-us/azure/devops/cli/?view=azure-devops'

az --version

az extension add --name azure-devops

# PAT login
az devops login --organization https://dev.azure.com/contoso

# Configure defaults: Although you can provide the organization and project for each command, we recommend you set these values as defaults in configuration for seamless commanding.
az devops configure --defaults organization=https://dev.azure.com/contoso project=ContosoWebApp

az devops project

az devops pipelines

az pipelines build show --id 1 --open

#endregion


#region Misc recommendations

# Predictive IntelliSense - requires at least PSReadline 2.1.0
Install-Module PSReadLine -RequiredVersion 2.1.0

# To enable Predictive IntelliSense (disabled by default)
Set-PSReadLineOption -PredictionSource History

# More information (key bindings and other customization options)
Start-Process https://devblogs.microsoft.com/powershell/announcing-psreadline-2-1-with-predictive-intellisense

# Also check out Az.Predictor
Start-Process https://techcommunity.microsoft.com/t5/azure-tools/announcing-az-predictor/ba-p/1873104
Start-Process https://techcommunity.microsoft.com/t5/azure-tools/announcing-az-predictor-preview-2/ba-p/2197744

# Latest preview requires PowerShell 7.2-preview 3
Start-Process https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.3
# or
docker run --rm -it mcr.microsoft.com/powershell:7.2.0-preview.4-alpine-3.11-20210316

# and at least PSReadline 2.2.0-beta2
Install-Module -Name PSReadLine -AllowPrerelease -RequiredVersion 2.2.0-beta2

# Launch new PowerShell instance to load new PSReadLine version
pwsh

# Also worth noting is a very useful feature in PSReadLine 2.2-beta.2: Dynamic help
Start-Process https://devblogs.microsoft.com/powershell/announcing-psreadline-2-2-beta-2-with-dynamic-help/

Update-Help

# By default ShowCommandHelp bound is to F1. Changing to F2 for the demo as I`m using F1 for the Command Pallette in Windows Terminal and VS Code
Set-PSReadLineKeyHandler -Function ShowCommandHelp -Chord F2
Get-ChildItem
Get-ChildItem -Filter # Type Alt+H to trigger parameter help

# Back to Az Predictor
Install-Module -Name Az -Force
Install-Module -Name Az.Tools.Predictor -Force

Import-Module Az.Tools.Predictor

# Updates Microsoft.PowerShell_profile.ps1 to import the module
Enable-AzPredictor -AllSession

# Inline view mode (default)
New-AzStorageAccount

# List view mode - Switch to this view either by using the "F2" function key on your keyboard or run the following command:
Set-PSReadLineOption -PredictionViewStyle ListView

# "Alt + A" to quickly fill replace the proposed values with yours

# Similar feature in Azure CLI: AI-powered interactive assistant
Start-Process https://techcommunity.microsoft.com/t5/itops-talk-blog/ai-powered-interactive-assistant-in-the-azure-cli/ba-p/2246498

az extension add -n next

az next

az next --help

#endregion