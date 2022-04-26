#region Prerequisites and Demo Setup
###############################################################
# Prerequisites - Azure CLI, Az PowerShell Module, Docker Desktop Installed with the hyper-v backend (NOT WSL) and set to use Windows Containers
#Configure our development environment
https://docs.docker.com/desktop/windows/install/
https://docs.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment


#Enable HyperV, requires Windows Pro or better. Be sure to switch to Windows containers.
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
Enable-WindowsOptionalFeature -Online -FeatureName containers -All 


#Get and install Docker, don't install to WSL...we're using Windows containers
Invoke-WebRequest https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe -OutFile 'Docker Desktop Installer.exe'
Start-Process '.\Docker Desktop Installer.exe' -Wait -ArgumentList 'install --backend=hyper-v --quiet --accept-license'
& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon .


#Pull and run your first container
docker pull mcr.microsoft.com/windows/nanoserver:1809-amd64
docker run -it mcr.microsoft.com/windows/nanoserver:1809-amd64 cmd.exe

#prepull this image
docker pull mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019
#endregion


#region - Deploy an ACR
###############################################################
az login
az account set --subscription 'Demonstration Account'


#Create Resource Group for our Lab
$LOCATION='centralus'
$RESOURCEGROUP='WinContainers'
az group create --name $RESOURCEGROUP  --location $LOCATION
az group show --name $RESOURCEGROUP -o table


#Create an Azure Container Registry
#Skus include standard and premium (speed, replication, adv security features)
#https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus#sku-features-and-limits
$RANDOM= Get-Random -Maximum 100
$ACRNAME="centinosystems$Random"
$ACRNAME="centinosystems73"
az acr create `
    --resource-group $RESOURCEGROUP `
    --name $ACRNAME `
    --sku Standard `
    --location $LOCATION    

az acr show --name $ACRNAME -o table

#Let's check it out in the portal
'https://portal.azure.com/#@nocentinohotmail.onmicrosoft.com/resource/subscriptions/fd0c5e48-eea6-4b37-a076-0e23e0df74cb/resourceGroups/WinContainers/providers/Microsoft.ContainerRegistry/registries/centinosystems73/overview'

az acr login --name $ACRNAME

$ACRLOGINSERVER=$(az acr show --name $ACRNAME --query loginServer --output tsv)
Write-Output $ACRLOGINSERVER
#endregion


#region - Deploy an AKS Cluster with Windows Nodes
$AKSCLUSTERNAME="AKS-WinContainers"
$VERSION=$(az aks get-versions -l $LOCATION --query 'orchestrators[-1].orchestratorVersion' -o tsv)

Write-Output $VERSION

#Create our k8s cluster, 1 Linux control plane node
az aks create `
    --resource-group $RESOURCEGROUP `
    --name $AKSCLUSTERNAME `
    --node-count 1 `
    --enable-addons monitoring `
    --generate-ssh-keys `
    --kubernetes-version $VERSION `
    --network-plugin azure

#Three Windows nodes. 2 vCPUs, 8GB RAM each. It's just VMs :P
az aks nodepool add `
    --resource-group $RESOURCEGROUP `
    --cluster-name $AKSCLUSTERNAME `
    --os-type Windows `
    --name np1win `
    --node-count 3

#Check out our cluster at the command line
az aks show --resource-group $RESOURCEGROUP --name $AKSCLUSTERNAME  | more 

#Check out our cluster in the azure portal
'https://portal.azure.com/#@nocentinohotmail.onmicrosoft.com/resource/subscriptions/fd0c5e48-eea6-4b37-a076-0e23e0df74cb/resourceGroups/WinContainers/providers/Microsoft.ContainerService/managedClusters/AKS-WinContainers/overview'


#Enable AKS Access to ACR
az aks update --name $AKSCLUSTERNAME --resource-group $RESOURCEGROUP --attach-acr $ACRNAME


#Install kubectl
az aks install-cli


#Get our cluster context which will have our cluster location, username and authentication method
az aks get-credentials --resource-group $RESOURCEGROUP --name $AKSCLUSTERNAME --overwrite-existing


#Check connectivity
kubectl cluster-info
kubectl get nodes -o wide

#Examine the labels associated with the windows nodes...we can send pods to nodes based on these labels
kubectl describe nodes | more

#Let check out the metrics server too
kubectl top nodes
kubectl top pods 
###############################################################
#endregion


#region - Build a full .NET application in a Windows container
#Build our full .NET application on Windows and IIS
#Points to note, image size and build time and first page load time
#Build time: ~2 mins 45 secs using 16 cores and no cached layers
#Start time: ~33 secs
#Time to retrieve page: ~20 sec
Set-Location .\demo1\v1

#Build our container image
Measure-Command { docker build --no-cache -t mywebapp:v1 . | Out-Default }

#Run a container from the just built image
Measure-Command { docker run -d -p 8080:80 --name demo1v1 mywebapp:v1 | Out-Default }
Measure-Command { Invoke-WebRequest http://localhost:8080/mywebapp/index.aspx -Timeoutsec 120 | Out-Default }

#Stop the running container
docker rm -f demo1v1

#Tag and upload our image to ACR
docker tag mywebapp:v1 $ACRLOGINSERVER/mywebapp:v1
docker image ls

#Push image to Azure Container Registry
docker push $ACRLOGINSERVER/mywebapp:v1


#Build our container image inside ACR using ACR Tasks. Similar to how we did it with docker build, but this time in the cloud
#Uploades just the code and manifest rather than the image's layers...saves space and time
az acr build --image "mywebapp:demo1v1" --platform Windows --registry $ACRNAME .


#Build a v2 of our app...this time is uses cached layers...but still takes a few minutes due to the IIS config
Set-Location ..\v2
docker build -t mywebapp:v2 .


#Run and test our v2 app
Measure-Command { docker run -d -p 8080:80 --name demo1v2 mywebapp:v2 | Out-Default }
Measure-Command { Invoke-WebRequest http://localhost:8080/mywebapp/index.aspx -Timeoutsec 120 | Out-Default }
docker rm -f demo1v2


#Tag and upload our image to ACR, only a 300MB push this time
docker tag mywebapp:v2 $ACRLOGINSERVER/mywebapp:v2
docker push $ACRLOGINSERVER/mywebapp:v2
#endregion


#region - AKS Deployment of our v1 container image
Set-Location ..\
kubectl apply -f .\service.yaml
kubectl apply -f .\deploymentv1.yaml
kubectl get pods --watch #notice that as soon as the container comes online the pods status changes to READY


#How long did the container pull take? This would normally take about 90 seconds
kubectl describe pods 


#Did all the pods land on the correct windows nodes?
kubectl get pods -o wide


#Let's get the service IP
kubectl get service hello-world
$SERVICEIP=$(kubectl get service hello-world -o jsonpath='{ .status.loadBalancer.ingress[].ip }')
Write-Output $SERVICEIP


#That first hit takes a while to warm up IIS around 10-20 seconds...and then what about being load balanced to another pod? 
Measure-Command { Invoke-WebRequest "http://$SERVICEIP/mywebapp/index.aspx" -Timeoutsec 120 | Out-Default }

#Hit that URL a few more times each new pod hit will take 10-20 seconds to load

#endregion


#region - AKS Rollout of our v2 container image
kubectl apply -f .\deploymentv2.yaml
kubectl.exe get pods --watch #notice that as soon as the container comes online the pods status changes to READY


#Our pods clearly aren't ready and take nearly 2 mins to respond but they all say READY
#If there's not probes...soon as the container starts it's Pod's status becomes READY and traffic will be sent to it
#endregion


#region - Rollout with startup/readiness/liveness probes 
#This time the deployment rollout will take longer but we'll always have a minimum number of pods online and ready
kubectl apply -f .\deploymentv2-probes.yaml

#We won't have non-ready pods and a pods won't be delete until a replacement is READY
#Also let's talk about maxsurge and maxunavailable
#You'll see 0/1 running...because the app takes 10-20 seconds to respond
kubectl get pods --watch
#endregion


#region - Build a .NET Core application in a Windows container
###############################################################
#Points to note, image size and build time and first page load time
#Build time: 35 seconds, and this is a multi-stage build!
#Start time: ~4 secs
#Time to retrieve page: ~2 sec
Set-Location ..\v3

Measure-Command { docker build --no-cache -t  mywebapp:v3 . | Out-Default }
Measure-Command { docker run -d -p 8080:80 --name demo3v1 mywebapp:v3 }
Measure-Command { Invoke-WebRequest http://localhost:8080/ -Timeoutsec 120 }
docker rm -f demo3v1


#Tag and upload our image to ACR
docker tag mywebapp:v3 $ACRLOGINSERVER/mywebapp:v3
docker image ls

#Step 5 - Push image to Azure Container Registry, about 70MB
docker push $ACRLOGINSERVER/mywebapp:v3

#Rollout our .NET Core application.
kubectl apply -f ..\deploymentv3.yaml
kubectl.exe get pods --watch

#How long until the first response
Measure-Command { Invoke-WebRequest http://$SERVICEIP/ -Timeoutsec 120 | Out-Default }
###############################################################
#endregion
