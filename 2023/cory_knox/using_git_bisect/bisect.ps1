Param(
$numError = 0
)
Remove-Module chocolateyInstaller -ErrorAction SilentlyContinue
$error.clear()
Import-Module c:\tmp\choco\src\chocolatey.resources\helpers\chocolateyinstaller.psm1 -Force -ErrorAction SilentlyContinue
if($error.count -gt $numError){
	exit 1
}
exit 0
