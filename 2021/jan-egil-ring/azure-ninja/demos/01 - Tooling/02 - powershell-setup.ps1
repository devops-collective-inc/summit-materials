#region PowerShell setup

Get-Content $profile.CurrentUserAllHosts

Start-Process https://github.com/SCRT-HQ/PSProfile

Install-Module PSProfile -Repository PSGallery -Scope CurrentUser

Import-Module PSProfile

Start-PSProfileConfigurationHelper

# Example
Add-PSProfileProjectPath C:\WorkProjects,~\PersonalGit -Save

Open-EditorFile "~\AppData\Roaming\powershell\SCRT HQ\PSProfile\Configuration.psd1"

# Example file loaded via PSProfile
Open-EditorFile "~\Git\WindowsPowerShell\Scripts\Core\Profile\Variables.ps1"

# Tip when working on multiple machines (desktop, laptop, management servers, etc): Symbolic link for profile.ps1

$DocumentsFolderPath = [Environment]::GetFolderPath("MyDocuments")
$FileName = 'profile.ps1'

$LinkPath = Join-Path -Path $DocumentsFolderPath -ChildPath PowerShell
$TargetPath = "C:\git\mypowershellrepo\$FileName" # The path to profile.ps1 in a central location such as a Git-repo, Dropbox, OneDrive, etc
New-Item -ItemType SymbolicLink -Name $FileName -Target $TargetPath -Path $LinkPath

$LinkPath = Join-Path -Path $DocumentsFolderPath -ChildPath WindowsPowerShell
$TargetPath = "C:\git\mypowershellrepo\$FileName"
New-Item -ItemType SymbolicLink -Name $FileName -Target $TargetPath -Path $LinkPath

#endregion

#region Profile performance

# Optimizing your $Profile by Steve Lee (example of Using GitHub to store profile.ps1)
Start-Process https://devblogs.microsoft.com/powershell/optimizing-your-profile/

#endregion