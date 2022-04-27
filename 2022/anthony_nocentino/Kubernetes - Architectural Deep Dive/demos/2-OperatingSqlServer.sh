#Log into master node to drive demos
ssh aen@c1-cp1

cd ~/content/Talks/PowerShell\ Summit\ 2022/Kubernetes\ -\ Architectural\ Deep\ Dive/demos

######Deploying SQL Server in Kubernetes####################################
#Set up an environment variable and SA password stored as a cluster secret
PASSWORD='S0methingS@Str0ng!'
kubectl create secret generic mssql --from-literal=SA_PASSWORD=$PASSWORD


#Deploying SQL Server in a Deployment with Persistent Storage
#Disk Topology
kubectl apply -f sql.pv.yaml
kubectl apply -f sql.pvc.yaml


#Deploy 'production ready' SQL Instance with an advanced disk topology
kubectl apply -f deployment-advanced-disk.yaml


#Status is now Running
kubectl get pods


#Get access to the service
SERVICEIP=$(kubectl get service mssql-deployment -o jsonpath='{ .spec.clusterIP }')
PORT=31433
echo $SERVICEIP


#Check out the servername and the version in the container, 2019 CU13
sqlcmd -S $SERVICEIP,$PORT -U sa -Q "SELECT @@VERSION" -P $PASSWORD 


#ADD CREATING A DATABASE
sqlcmd -S $SERVICEIP,$PORT -U sa -Q "CREATE DATABASE TestDB1" -P $PASSWORD 


#List the physical path of the files in the SQL Server pod
sqlcmd -S $SERVICEIP,$PORT -U sa -Q "SELECT Physical_Name FROM sys.master_files" -P $PASSWORD -W


#Look at the actual path of the database files on our storage system...
#Kubernetes makes sure that these are mapped on the Node and Exposed inside the pod
ssh -t aen@c1-storage 'sudo ls -la /srv/exports/volumes/sql-instance-2/system/data' 
ssh -t aen@c1-storage 'sudo ls -la /srv/exports/volumes/sql-instance-2/{data,log}'


######High Availability SQL Server in Kubernetes################################################
#Crash SQL Server, do this too many times too quickly it will start to back off...initially 15s
sqlcmd -S $SERVICEIP,$PORT -U sa -Q "SHUTDOWN WITH NOWAIT" -P $PASSWORD 


#Check out the events
kubectl describe pods mssql-deployment
sqlcmd -S $SERVICEIP,$PORT -U sa -Q "SELECT @@SERVERNAME,@@VERSION" -P $PASSWORD -W


#Delete the pod
kubectl delete pod mssql-deployment-[tab][tab]


#This time we get a new Pod, check out the name and the events
kubectl get pods


#We still have our databases, because of the PV/PVC being presented as /var/opt/mssql/
sqlcmd -S $SERVICEIP,$PORT -U sa -Q "SELECT Physical_Name FROM sys.master_files" -P $PASSWORD -W


######Setting Resource Limits####################################################################
#Let's update the existing deployment with 1 CPUs and 8GB RAM.
kubectl apply -f deployment-advanced-disk-resource-limits.yaml 


#Status is now Pending, but restarted due to the config change. But this Pod was NOT able to get scheduled.
#We requested 8GB of memory but our Nodes have only 2GB
kubectl get pods


#Events will show Insufficient memory
kubectl describe pods


#Set memory Requests to a value lower than the resources available in a Node, in this case 1GB
kubectl apply -f deployment-advanced-disk-resource-limits-correct.yaml


#Status is now running, the pod was able to get scheduled
kubectl get pods


#Did SQL Server start up?
sqlcmd -S $SERVICEIP,$PORT -U sa -Q "SELECT @@VERSION" -P $PASSWORD 



######Backing up SQL Server in Kubernetes######################################################
#Backing up SQL Server in Kubernetes
#Attach a backup disk in the Pod Configuration
kubectl apply -f deployment-advanced-disk-resource-limits-correct-withbackup.yaml


#Ensure the Pod is Running and the disk is attached
kubectl get pod --watch

#We can use dbatools...
pwsh
$Username = 'sa'
$Password =  ConvertTo-SecureString -String "S0methingS@Str0ng!" -AsPlainText -Force
$SaCred = New-Object System.Management.Automation.PSCredential $Username,$Password

$SERVICEIP = kubectl get service mssql-deployment -o jsonpath='{ .spec.clusterIP }'
$PORT=31433


#Test our connectivity to the instance...to specify a port, use a quoted string
Connect-DbaInstance -SqlInstance "$SERVICEIP,$PORT" -SqlCredential $SaCred


#Let's take a backup...
Backup-DbaDatabase -SqlInstance "$SERVICEIP,$PORT" -SqlCredential $SaCred -path '/backup'


#Leave pwsh back into bash...sorry PowerShell Summiteers :P 
exit


#...but that file is really stored on the NFS Server
ssh -t aen@c1-storage 'sudo ls -al /srv/exports/volumes/sql-instance-2/backup'


######Upgrading SQL Server###################################################################
#Change out the version of SQL Server from CU13->CU14, could use YAML or kubectl edit too
kubectl set image deployment mssql-deployment \
    mssql=mcr.microsoft.com/mssql/server:2019-CU14-ubuntu-20.04

#Check the status of our rollout
kubectl rollout status deployment mssql-deployment


#1. Key thing here is to shut down the current pod before deploying the new pod. the default is to add one, then remove the old.
#2. Check out the pod template hashed changed, old scaled to 0, new scaled to 1
kubectl describe deployment mssql-deployment
kubectl get replicaset
kubectl get pods


#Check out the servername and the new version in the Pod...still upgrading or ready to go?
sqlcmd -S $SERVICEIP,$PORT -U sa -Q "SELECT @@SERVERNAME,@@VERSION" -P $PASSWORD -W


#Check the logs of our pod, SQL Error log writes to stdout, which is captured by the pod
kubectl logs mssql-deployment-[tab][tab]


#Check out the new version
sqlcmd -S $SERVICEIP,$PORT -U sa -Q "SELECT @@SERVERNAME,@@VERSION" -P $PASSWORD -W

######Clean up the demos#######################################################################
#Delete our resources to clean—up after our demos
kubectl delete secret mssql
kubectl delete -f deployment-advanced-disk-resource-limits-correct-withbackup.yaml
kubectl delete -f sql.pvc.yaml
kubectl delete -f sql.pv.yaml

#Double check everything is gone...
kubectl get all
kubectl get pvc
kubectl get pv


#Delete and recreate volume data on c1-storage for the next presentation
ssh -t aen@c1-storage 'sudo rm -rf /srv/exports/volumes/sql-instance-2/{backup,system,data,log}; 
sudo mkdir -p /srv/exports/volumes/sql-instance-2/{backup,system,data,log};
sudo chown mssql:mssql -R /srv/exports/volumes/sql-instance-2;
sudo ls -laR /srv/exports/volumes/sql-instance-2'
