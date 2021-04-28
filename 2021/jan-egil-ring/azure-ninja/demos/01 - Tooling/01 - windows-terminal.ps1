# Windows PowerShell - deprecated
Start-Process -FilePath powershell.exe -ArgumentList -NoProfile

# PowerShell - the future, also runs on Linux and Mac
Start-Process -FilePath pwsh.exe -ArgumentList -NoProfile

# More information
Start-Process https://docs.microsoft.com/en-us/powershell
Start-Process https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell

# Windows Terminal - modern terminal experience
Start-Process -FilePath wt.exe

# Basics: Install from store, settings, command palette

# Keep an eye on the Windows Terminal blog, contains a lot of useful articles on how to customize and use Windows Terminal
Start-Process https://devblogs.microsoft.com/commandline/
Start-Process https://devblogs.microsoft.com/commandline/getting-started-with-windows-terminal/

# Documentation
Start-Process https://docs.microsoft.com/en-us/windows/terminal/

#region oh-my-posh

Start-Process https://ohmyposh.dev

Get-PoshThemes

Set-PoshPrompt powerline.omp

# Important: Install a Nerd Font to be able to use glyphs (icons)
# Recommended video: Customize Your PowerShell Prompt with Nerd Fonts & ANSI Escape Sequences by Trevor Sullivan
Start-Process https://www.youtube.com/watch?v=DhzR7mbFE9I

#endregion


#region Use WSL with multiple users for "clean" working environments

# 1) Show how to create new users
        sudo useradd contoso --create-home
# 2) Show Windows Terminal WSL profiles and add entry for new user
        New-Guid
        # "commandline": "wsl.exe -d Ubuntu-20.04 -u contoso /opt/microsoft/powershell/7/pwsh",
# 3) Launch new profile
# 4) Customize new user
    # PowerShell profile
    New-Item -Path $profile -ItemType File -Force
    vi $profile
    # Insert content from /WSL-profile example/profile.ps1

# Pre-installed as root
    Install-Module Microsoft.PowerShell.UnixCompleters -Scope AllUsers
    Install-Module -Name Az -Scope AllUsers -Force
    Install-Module -Name PSReadLine -AllowPrerelease -Scope AllUsers -Force

#endregion