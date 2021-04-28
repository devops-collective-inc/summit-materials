# Start Windows VM to show vanilla VS Code experience

<# VS Code extensions

Must have extensions:
- PowerShell: ms-vscode.powershell
- Remote Development (extension pack): ms-vscode-remote.vscode-remote-extensionpack
    - Remote containers
    - Remote SSH
    - Remote WSL

Recommended domain specific extensions
- Azure Account: ms-vscode.azure-account
- Azure Functions: ms-azuretools.vscode-azurefunctions
- Azure Kubernetes Service: ms-kubernetes-tools.vscode-aks-tools
- Azure Resource Manager (ARM) Tools: msazurermtools.azurerm-vscode-tools
- Docker: ms-azuretools.vscode-docker
- GitHub Codespaces: github.codespaces
- HashiCorp Terraform: hashicorp.terraform
- Kubernetes: ms-kubernetes-tools.vscode-kubernetes-tools

    #>

# Pro tip: Sign in with Microsoft/GitHub account to synchronize settings across machines (settings, keybindings, and installed extensions)
Start-Process https://code.visualstudio.com/docs/editor/settings-sync

# Recommended video: Optimizing VSCode for PowerShell Development - Justin Grote
Start-Process https://www.youtube.com/watch?v=WaTw6zwhiHM

# Starting point, examples from above video
Start-Process https://github.com/justingrote/pwsh24examples