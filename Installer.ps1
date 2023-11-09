Import-Module -Name "configer.psm1"

function InstallChocolateyAndImportModule {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    
    # Make 'refreshenv' available right away
    $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
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

function RestoreUserFileStructure {
    # Restore User file
    Write-Host "Restore User File"
    $desUserDir = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\DN"
    $desUserDirIni = Join-Path -Path $desUserDir -ChildPath "desktop.ini"
    $UserDirIniContent = @'
[.ShellClassInfo]
IconResource=
[ViewState]
Mode=
Vid=
FolderType=Documents    
'@
    # Create User Folder
    New-Item -ItemType Directory -Path $desUserDir -Force
    $IconPath = "IconResource=$env:USERPROFILE\Pictures\ICON\Lemon.ico,0"
    $UserDirIniContent = $UserDirIniContent -replace '\[\.ShellClassInfo\]', "[.ShellClassInfo]`r`n$IconPath"
    Set-Content -Path $desUserDirIni -Value $UserDirIniContent -Force
    Write-Host "Done."
}

function InstallOpenSSHServer {
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
    if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
        Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    } else {
        Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
    }

    # Change Default Shell to Powershell
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value (Get-Command pwsh).Path -PropertyType String -Force
}


function main {
    InstallChocolateyAndImportModule
    InstallOhMyPosh
    RestoreWTConfig
    RestoreUserFileStructure
    InstallOpenSSHServer
    GitConfig
}

main
Pause