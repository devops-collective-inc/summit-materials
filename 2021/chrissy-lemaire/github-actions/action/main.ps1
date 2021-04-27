param (
   [string[]]$Module,
   [string]$Type
)

$neededlist = @()
$allmodules = Get-Module -ListAvailable

foreach ($item in $Module) {
   if (-not ($allmodules | Where-Object Name -eq $item)) {
      $neededlist += $item
   }
}
switch ($Type) {
   'Needed' {
      Write-Output "$($neededlist -join ', ')"
   }
   'KeyGen' {
      if ($neededlist.count -gt 0) {
         Write-Output "$($PSVersionTable.Platform)-$($neededlist -join '-')"
      }
      else {
         Write-Output "psmodulecache"
      }
   }
   'ModulePath' {
      if ($PSVersionTable.Platform -eq "Win32NT") {
         Write-Output "C:\Users\runneradmin\Documents\PowerShell\Modules\"
      } else {
         Write-Output "/home/runner/.local/share/powershell/Modules/"
      }
   }
}