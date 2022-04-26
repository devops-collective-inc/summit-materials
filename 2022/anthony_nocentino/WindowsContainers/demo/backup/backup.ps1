###############################################################

#region demo2
###############################################################
#Precompiled build our full .NET application on Windows and IIS
#Points to note, image size and build time and first page load time
#Build time: ~3 mins 3 secs (using cached layers)
#Start time: ~52 secs
#Time to reteive page: ~ 22 sec
Set-Location ../../demo2/v1
Measure-Command { docker build -t demo2v1 . }

Measure-Command { docker run -d -p 8081:80 --name demo2v1 demo2v1 }
Measure-Command { Invoke-WebRequest http://localhost:8081/mywebapp/index.aspx -Timeoutsec 120 }

###Rollout v1 to AKS here
#Write loop to hit main page

Set-Location ../../demo2/v2
docker build -t demo2v2 .

docker run -d -p 8080:80 --name demo1v2 demo1v2
Invoke-WebRequest http://localhost:8080/mywebapp/index.aspx

###Rollout v2 to AKS here

###############################################################
#endregion

