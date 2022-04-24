# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.163.1/containers/alpine/.devcontainer/base.Dockerfile

#FROM mcr.microsoft.com/azure-powershell:5.7.0-alpine-3.10
FROM mcr.microsoft.com/azure-powershell:5.7.0-ubuntu-18.04

# Disable to save time for demo
#RUN apt-get update && apt-get -y upgrade

RUN pwsh -c Install-Module PSDepend -Force

COPY ["powershell/requirements.psd1", "/tmp/requirements.psd1"]

RUN pwsh -c Invoke-PSDepend /tmp/requirements.psd1 -Force

# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
RUN apt-get update
RUN apt-get install ca-certificates curl apt-transport-https lsb-release gnupg -y

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

RUN AZ_REPO=$(lsb_release -cs);echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list

RUN apt-get update && apt-get install azure-cli

# Switch to non-root user:
RUN useradd --create-home vscode
WORKDIR /home/vscode
USER vscode