# Lightning demo about ArgumentCompleters

See James O'Neill's session _How to be a Parameter ninja_.

## Why use them?

- Simple to use
- Self-documenting
- Better user experience for every one
- Impress your colleagues

## Four styles

### [ValidateSet](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters#validatescript-validation-attribute) attribute

- Hard-coded list of values
- Validation does not allow other values
- Not reusable - Must be repeated for every function that uses the same parameter

### [ArgumentCompletions](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters#argumentcompletions-attribute) attribute

- Hard-coded list of values
- No validation - so you can use other values
- Not reusable - Must be repeated for every function that uses the same parameter

### [Enum](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_enum) types

- Named list of hardcoded values
- Can be used as a type
- Reusable - Type can be used for multiple functions/parameters
- Good way to create friendly names for numeric values

### [ArgumentCompletion](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_argument_completion) functions

- No validation
- Can combine hard-coded and dynamic values
- Reusable - function can be bound to parameters of multiple functions

## Examples

### Using multiple types

```powershell
enum DevOpsFeatures {
    NewContent = 1669512
    ContentMaintenance = 1669513
    GitHubIssues = 1669514
    IADesignWork = 1669515
    DevRelProjects = 1669516
    CommunityProjects = 1669517
    PipelineProject = 1719855
    LearnModule = 1733702
}
function New-DevOpsWorkItem {
    param(
        [Parameter(Mandatory = $true)]
        [string]$title,

        [Parameter(Mandatory = $true)]
        [string]$description,

        [DevOpsFeatures]$parentId,

        [string[]]$tags,

        [ValidateSet('Task', 'User%20Story')]
        [string]$wiType = 'User%20Story',

        [string]$areapath = 'TechnicalContent\Azure\Compute\Management\Config\PowerShell',

        [string]$iterationpath = "TechnicalContent\CY$(Get-Date -Format 'yyyy')\$(Get-Date -Format 'MM_yyyy')",

        [ArgumentCompletions('sewhee', 'mlombardi')]
        [string]$assignee = 'sewhee'
    )

    # lots of code here
}


$sbAreaPathList = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $areaPathList = 'TechnicalContent\Azure\Compute\Management\Config\PowerShell',
    'TechnicalContent\Azure\Compute\Management\Config\PowerShell\Cmdlet Ref',
    'TechnicalContent\Azure\Compute\Management\Config\PowerShell\Core',
    'TechnicalContent\Azure\Compute\Management\Config\PowerShell\Developer',
    'TechnicalContent\Azure\Compute\Management\Config\PowerShell\DSC'
    $areaPathList
}
Register-ArgumentCompleter -CommandName Import-GitHubIssueToTFS,New-DevOpsWorkItem -ParameterName areapath -ScriptBlock $sbAreaPathList

$sbIterationPathList = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $year = Get-Date -Format 'yyyy'
    $iterationPathList = @()
    1..12 | %{ $iterationPathList +="TechnicalContent\CY$year\{0:d2}_$year" -f $_ }
    $iterationPathList += 'TechnicalContent\Future'
    $iterationPathList
}
Register-ArgumentCompleter -CommandName Import-GitHubIssueToTFS,New-DevOpsWorkItem -ParameterName iterationpath -ScriptBlock $sbIterationPathList
```

### Using a function to complete dynamic values

```powershell
function Kill-Branch {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$branch
    )
    process {
        if ($branch) {
            $allbranches = @()
            $branch | ForEach-Object {
                $allbranches += git branch -l $_
            }
            Write-Host ("Deleting branches:`r`n" + ($allbranches -join "`r`n"))
            $allbranches | ForEach-Object {
                $b = $_.Trim()
                '---' * 3
                git.exe push origin --delete $b
                '---'
                git.exe branch -D $b
                #git.exe branch -Dr origin/$b
            }
        }
    }
}
$sbBranchList = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    git branch --format '%(refname:lstrip=2)' | Where-Object {$_ -like "$wordToComplete*"}
}
Register-ArgumentCompleter -CommandName Checkout-Branch,Kill-Branch -ParameterName branch -ScriptBlock $sbBranchList
```
