# PowerShell on AWS CloudShell Demos
<!-- spell-checker:words pwsh -->

List available tools

```shell
ls -la /usr/local/bin
```

Show assumed role

```shell
aws sts get-caller-identity
```

List EC2 instances

```shell
aws ec2 describe-instances
```

Pretty print EC2 instances

```shell
aws ec2 describe-instances | jq .
```

Install AWS CDK

```shell
npm install aws-cdk
```

Print the AWS CDK version

```shell
cdk --version
```

List binaries

```shell
ls /usr/bin
```

Start PowerShell

```shell
pwsh
```

Show assumed role

```powershell
Get-STSCallerIdentity
```

List modules

```powershell
Get-Module -ListAvailable
```

List commands

```powershell
Get-Command
```

List variables

```powershell
Get-Variable
Get-ChildItem env:
```

Show profile location

```powershell
$PROFILE
```

Show profile content

```powershell
Get-Content $PROFILE
```

Add to the profile

```powershell
Add-Content -Path $PROFILE -Value "Write-Output 'Hello Summit!'"
```

Reload the profile

```powershell
. $PROFILE
```

Trust the PowerShell Gallery

```powershell
Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'
```

Install Pester

```powershell
Install-Module -Name 'Pester'
```

Run Pester

```powershell
Get-Content ./pesterDemo.ps1
Invoke-Pester ./pesterDemo.ps1 -Output 'Detailed'
```

Automatically install Pester using the profile

```powershell
Add-Content -Path $PROFILE -Value 'if($null -eq (Get-Module -ListAvailable Pester)) { Install-Module -Name Pester -Force }'
```

Reload the profile

```powershell
Uninstall-Module Pester
. $PROFILE
```

Create an S3 bucket

```powershell
New-S3Bucket -BucketName 'powershell2023summit'
```

Upload the file

```powershell
Write-S3Object -BucketName 'powershell2023summit' -Key 'profile.ps1' -File $PROFILE
```

Download the file then reload the profile

```powershell
Read-S3Object -BucketName 'powershell2023summit' -Key 'profile.ps1' -File $PROFILE && . $PROFILE
```

Create lots of S3 buckets

```powershell
1..300 | ForEach-Object { New-S3Bucket -BucketName "powershell2023summit$_" -WhatIf }
```

Update all gp2 EBS volumes to gp3

```powershell
Get-EC2Volume | Where-Object { $_.VolumeType -eq 'gp2' } | Edit-EC2Volume -VolumeType 'gp3' | Format-Table -AutoSize
```

Sync command history

```powershell
$cloudHistory = Read-S3Object -BucketName 'powershell2023summit' -Key 'ConsoleHost_history.txt' -File (New-TemporaryFile)
$localHistory = (Get-PSReadLineOption).HistorySavePath
Add-Content -Path $localHistory -Value (Get-Content $cloudHistory)
Write-S3Object -BucketName 'powershell2023summit' -Key 'ConsoleHost_history.txt' -File $localHistory
```
