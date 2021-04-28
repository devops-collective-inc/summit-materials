# Deploy Cloud Shell into an Azure virtual network
Start-Process https://docs.microsoft.com/en-us/azure/cloud-shell/private-vnet


New-AzResourceGroup -Name cloudshell-rg -Location westeurope
New-AzResourceGroupDeployment -ResourceGroupName cloudshell-rg -TemplateUri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-cloud-shell-vnet/azuredeploy.json

Get-AzADServicePrincipal -DisplayNameBeginsWith 'Azure Container Instance'

New-AzResourceGroupDeployment -ResourceGroupName WestEurope-Networking -TemplateUri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-cloud-shell-vnet/azuredeploy.json -TemplateParameterFile
 ./azurecloudshell.parameters.json

 clouddrive unmount