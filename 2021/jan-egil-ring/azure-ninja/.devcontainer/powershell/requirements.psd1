@{
    PSDependOptions = @{
        Target = 'CurrentUser'
        Parameters = @{
            Repository = 'PSGallery'
            AllowPrerelease = $false
        }
    }

    'oh-my-posh' = 'latest'
    'Microsoft.PowerShell.SecretManagement' = 'latest'
    'Microsoft.PowerShell.SecretStore'      = 'latest'
    'Microsoft.PowerShell.UnixCompleters'   = 'latest'
    'Microsoft.PowerShell.ConsoleGuiTools'  = 'latest'
    'PSKubectlCompletion'                   = 'latest'
    'tftools'                               = 'latest'
}