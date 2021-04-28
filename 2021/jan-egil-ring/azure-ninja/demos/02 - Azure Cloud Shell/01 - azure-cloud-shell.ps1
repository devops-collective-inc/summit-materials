Start-Process https://docs.microsoft.com/en-us/azure/cloud-shell/overview

<#
 Access from Azure Portal
 VS Code: Type Cloud Shell in the command pallette
 Windows Terminal: Default Azure CLoud Shell profile available
#>

# Automatically authenticated

Get-AzSubscription
Get-AzContext
Set-AzContext -Subscription 'Microsoft Azure-sponsing'

Get-Command -Module PSCloudShellUtility

Enable-AzVMPSRemoting -Name workshopdemo01 -ResourceGroupName workshopdemo01

$Credential = Get-Credential
Invoke-AzVMCommand -Name workshopdemo01 -ScriptBlock {hostname;whoami} -Credential $Credential -ResourceGroupName workshopdemo01
Invoke-AzVMCommand -Name workshopdemo01 -ScriptBlock {ipconfig} -Credential $Credential -ResourceGroupName workshopdemo01

Enter-AzVM -Name workshopdemo01 -Credential $Credential

Get-AzCommand

Get-CloudDrive

# Ansible, git, chef and many others pre-installed
Get-Command -CommandType Application

# Deploy Cloud Shell into an Azure virtual network
Open-EditorFile "C:\git\2021-ps-summit-azure-ninja\demos\02 - Azure Cloud Shell\New-AzCloudShellPrivateInstance.ps1"

# Wacky WSMan on Linux: Jordan Borean - PSWSMan module
Start-Process https://www.bloggingforlogging.com/2020/08/21/wacky-wsman-on-linux/

Install-Module -Name PSWSMan -Force

# Using custom OMI version in Azure Cloud Shell
Start-Process https://github.com/jborean93/omi/issues/24

#adminjer@mgmt01
$cred = Get-Credential

# Works fine from a Linux machine using PSWSMan
Enter-PSSession -ComputerName 13.73.138.167 -Credential $cred -Authentication Negotiate

# But not from Cloud Shell due to missing/outdated packages
Enter-PSSession -ComputerName 10.200.1.4 -Credential $cred -Authentication Negotiate

<#
PS /home/admin> Enter-PSSession -ComputerName 10.200.1.4 -Credential $cred -Authentication Negotiate
Enter-PSSession: Connecting to remote server 10.200.1.4 failed with the following error message : acquiring creds with username only failed An invalid name was supplied SPNEGO cannot find mechanisms to negotiate For more information, see the about_Remote_Troubleshooting Help topic.

PS /home/admin> Enter-PSSession -ComputerName 10.200.1.4 -Credential $cred -Authentication Kerberos
Enter-PSSession: Connecting to remote server 10.200.1.4 failed with the following error message : Kerberos verify cred with password failed No credentials were supplied, or the credentials were unavailable or inaccessible For more information, see the about_Remote_Troubleshooting Help topic.
#>

# Hence, we can fall back to SSH based remoting instead when using Cloud Shell
Enter-PSSession -HostName 10.200.1.4 -UserName adminjer

# Private Endpoint-enabled PaaS-services also available

# Gotcha: Launching Cloud Shell when using VNet integration can take minutes (due to the fact that an Azure Container Instances is being spun up in the backend)
