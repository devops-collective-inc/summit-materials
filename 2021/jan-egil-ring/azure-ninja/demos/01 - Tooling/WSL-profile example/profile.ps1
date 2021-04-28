cd /
$ENV:PATH = ((dir env: | Where-Object name -eq PATH | Select-Object -exp Value) -split ':' | Where-Object {$PSItem -notlike "/mnt*"}) -join ':'
Import-Module Microsoft.PowerShell.UnixCompleters
Import-UnixCompleters
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete