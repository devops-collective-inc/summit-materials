function Invoke-PSModuleCache {
    <#
    .SYNOPSIS
        Cache modules from the PowerShell Gallery

    .DESCRIPTION
        Cache modules from the PowerShell Gallery

        Conveying Composite Actions using PowerShell concepts

    .PARAMETER ModulesToCache
        The PowerShell modules to cache from the PowerShell Gallery

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string[]]$ModulesToCache
    )
    process {
        Write-Verbose -Message "Gathering information for modules $ModulesToCache"

        # Required modules that are needed
        $needed = . $PSScriptRoot\main.ps1 -Type Needed -Module $ModulesToCache

        # Unique Key Generator
        $keygen = . $PSScriptRoot\main.ps1 -Type KeyGen -Module $ModulesToCache

        # Default module path for OS
        $modulepath = . $PSScriptRoot\main.ps1 -Type ModulePath -Module $ModulesToCache
        
        # Generate required output for the workflow to consume
        [PSCustomObject]@{
              Needed = $needed
              KeyGen = $keygen
              ModulePath = $modulepath
              ModulesToCache = $ModulesToCache
        }
    }
}