<#

Docker - The fastest way to containerize applications on your desktop

https://www.docker.com/docker-windows
https://desktop.docker.com/mac/stable/Docker.dmg
https://hub.docker.com/search?q=&type=edition&offering=community&operating_system=linux

#>

# Public Docker Hub
Start-Process https://hub.docker.com

# Run a container
# This will run the latest version of the Azure CLI image
docker run --rm -it mcr.microsoft.com/azure-cli:latest
# -it       run interactive
# --rm      automatically remove container


docker pull mcr.microsoft.com/powershell

# Alpine Linux is a Linux distribution built around musl libc and BusyBox. The image is only 5 MB in size and has access
# to a package repository that is much more complete than other BusyBox based images. This makes Alpine Linux a great image base for utilities and even production applications.

docker pull mcr.microsoft.com/powershell:7.2.0-preview.4-alpine-3.11-20210316

docker image list

docker run --rm -it mcr.microsoft.com/powershell:7.2.0-preview.4-alpine-3.11-20210316

Start-Process https://hub.docker.com/_/microsoft-azure-powershell

docker pull mcr.microsoft.com/azure-powershell:5.7.0-alpine-3.10

# map local folder to container
docker run --rm -it -v "c:\git:/local" mcr.microsoft.com/azure-powershell:5.7.0-alpine-3.10
# /local inside the container is now mapped to the current folder where

# You can push a new image to a repository such as Docker Hub using the CLI

docker tag local-image:tagname new-repo:tagname
docker push new-repo:tagname

# Example:
docker push janegilring/management:tagname

#region Remote containers

Start-Process https://code.visualstudio.com/docs/remote/containers

mkdir C:\temp\somerepo
code C:\temp\somerepo
# Command pallette->Remote Containers->Add Development Container Configuration Files

Remove-Item C:\temp\somerepo -Recurse

# Let`s look at a pre-customized example using a PowerShell image
Open-EditorFile .\.devcontainer\Dockerfile
Open-EditorFile .\.devcontainer\devcontainer.json

# Azure PowerShell - context persistence
Start-Process https://docs.microsoft.com/en-us/powershell/azure/context-persistence?view=azps-5.7.0

# After starting the container

Connect-AzAccount -UseDeviceAuthentication

Set-AzContext democrayon

Save-AzContext -Path /workspaces/2021-ps-summit-azure-ninja/.devcontainer/powershell/azure/democrayon.json

# After restarting the container

Get-AzContext

Import-AzContext -Path /workspaces/2021-ps-summit-azure-ninja/.devcontainer/powershell/azure/democrayon.json

Get-AzContext

Get-AzVM | Format-Wide Name

az login

az account list --output table

az account set --subscription "My Demos"

# AzureRmContext.json for Azure CLI
Get-ChildItem $HOME/.Azure/

# [Enhancement Proposal] Share login context between Azure CLI and Azure PowerShell
Start-Process https://github.com/Azure/azure-cli/issues/16460

#endregion

#region Azure Cloud Shell image

Start-Process https://github.com/Azure/CloudShell

docker pull mcr.microsoft.com/azure-cloudshell:latest

docker run -it mcr.microsoft.com/azure-cloudshell

# Add to dev-container Dockerfile: FROM mcr.microsoft.com/azure-cloudshell:latest

# After rebuilding and restarting the container

# Ansible, git, chef and many others pre-installed
Get-Command -CommandType Application

apt list --installed

Import-AzContext -Path /workspaces/2021-ps-summit-azure-ninja/.devcontainer/powershell/azure/democrayon.json

Get-AzContext

Get-AzVM | Format-Wide Name

# Trade-off: Container image size of Azure CLoud Shell is rather huge: 9.3 GB
Start-Process https://github.com/Azure/CloudShell/issues/90

# For example, azure-functions-core-tools and chef-workstation alone are over 1.2 GB.

<#
Cloud Shell update November 2020:
We are currently updating Cloud Shell to a newer base image and repository called “Common Base Linux – Delridge” (aka CBL-D).
That may sound unfamiliar – this is not a standalone distribution, but a Microsoft project which tracks Debian very closely.
The primary difference between Debian and CBL-D is that Microsoft compiles all the packages included in the CBL-D repository
internally. This helps guard against supply chain attacks.
#>

#endregion