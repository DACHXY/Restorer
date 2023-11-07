# install Package Provider
Install-PackageProvider -Name NuGet -Force
Install-Module -SkipPublisherCheck -Name Microsoft.WinGet.Client -Force

# Get Winget Newest and Install
Write-Host "Downloading AppInstaller package..."
$wc = New-Object net.webclient
$wc.Downloadfile("https://aka.ms/getwinget", "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle")
Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -InstallAllResources
Write-Host "[DONE] AppInstaller package Installed."

# Install the powershell
winget install -e --id Microsoft.PowerShell  --accept-package-agreements --accept-source-agreements

# Install the windows terminal preview
winget install -e --id Microsoft.WindowsTerminal.Preview  --accept-package-agreements --accept-source-agreements

function InstallChocolateyAndImportModule {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    
    # Make 'refreshenv' available right away
    Import-Module "C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1"
    refreshenv
}

function InstallOhMyPosh {
    $desPsConfigFilePath = $PROFILE
    $content = @'
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/bubblesextra.omp.json" | Invoke-Expression
$env:Path = $env:Path + ";C:\Users\Danny\Documents\DN\CMD;"
'@
    
    Write-Host "Install PSReadLine Module"
    Install-Module -Name PSReadLine -AllowClobber -Force

    Write-Host "Enable IntelliSense"
    Start-Process pwsh -ArgumentList "Set-PSReadLineOption -PredictionSource History"

    Write-Host "Installing Oh My Posh..."
    Write-Host "Polling from winget..."

    # == Install oh my posh
    winget install --accept-package-agreements --accept-source-agreements JanDeDobbeleer.OhMyPosh -s winget
    
    # == Write Config Content to profile
    Add-Content -Path $desPsConfigFilePath -Value $content
    
    # == Update environment
    refreshenv

    Write-Host "Installing cascadiaCode font..."
    # Install CascadiaCode font
    oh-my-posh font install CascadiaCode --user

    # Reload config file
    . $PROFILE
}

function RestoreWTConfig {
    # Restore Windows Terminal Setting
    $desWindowsTerminalSettingFile = $env:LocalAppData + "\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $srcWindowsTerminalSettingFile = "sources\wt-settings.json"
    Set-Content -Path $desWindowsTerminalSettingFile -Value (Get-Content $srcWindowsTerminalSettingFile)
}

InstallChocolateyAndImportModule
InstallOhMyPosh
RestoreWTConfig
