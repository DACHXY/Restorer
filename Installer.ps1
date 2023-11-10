$backupDir = $args[0]

if (-not (Test-Path $backupDir)){
    Write-Error "Path: $backupDir not exist! [SKIPED]"
}
Write-Host "Restore Path: $backupDir"

$FILE_ROOT = $FILE_ROOT = Split-Path -parent $MyInvocation.MyCommand.Definition

Import-Module -Name "$FILE_ROOT\configer.psm1"
Import-Module -Name "$FILE_ROOT\utils.psm1"

function InstallT0Apps {
    $installList = @(
        "Mozilla.Firefox",
        "Twilio.Authy",
        "Opera.Opera",
        "M2Team.NanaZip",
        "GNU.Nano",
        "Git.Git",
        "Microsoft.VisualStudioCode",
        "Nvidia.GeForceExperience",
        "Python.Python.3.11",
        "Discord.Discord",
        "OpenJS.NodeJS",
        "AutoHotkey.AutoHotkey",
        "Microsoft.PowerToys",
        "Dell.CommandUpdate"
    )

    foreach ($package in $installList) {
        winget install --accept-package-agreements --accept-source-agreements $package --source winget
    }
}

function InstallT1Apps {
    $installList = @(
        "Notion.Notion",
        "EmoteInteractive.RemoteMouse",
        "Docker.DockerDesktop",
        "Microsoft.VisualStudio.2022.Community",
        "OBSProject.OBSStudio",
        "AppWork.JDownloader",
        "junegunn.fzf",
        "Guru3D.Afterburner",
        "REALiX.HWiNFO",
        "BlenderFoundation.Blender",
        "VMware.WorkstationPro",
        "MHNexus.HxD",
        "Logitech.GHUB",
        "RiotGames.Valorant.AP",
        "Valve.Steam",
        "Spotify",
        "Figma.Figma",
        "Postman.Postman",
        "NordSecurity.NordVPN"
    )
    foreach ($package in $installList) {
        winget install --accept-package-agreements --accept-source-agreements $package --source winget
    }   
}

function InstallAppsFromMsstore {
    $installList = @(
        "Line",
        "Messenger",
        "Surfshark"
    )
    foreach ($package in $installList) {
        winget install --accept-package-agreements --accept-source-agreements $package --source msstore
    } 
}

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
    $desWindowsTerminalPreviewSettingFile = $env:LocalAppData + "\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    $srcWindowsTerminalSettingFile = "$FILE_ROOT\sources\wt-settings.json"
    Copy-Item -Path $srcWindowsTerminalSettingFile -Destination $desWindowsTerminalSettingFile
    Copy-Item -Path $srcWindowsTerminalSettingFile -Destination $desWindowsTerminalPreviewSettingFile
}

function RestorePowerToysConfig {
    Write-Host "Copying PowerToys Config file..."
    New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\Powertoys\Backup" -Force
    $desDir = "$env:USERPROFILE\Documents\Powertoys\Backup\settings_133361257157022308.ptb"
    $srcDir = "$FILE_ROOT\sources\powertoys_backup.ptb"
    Copy-Item -Path $srcDir -Destination $desDir
    Write-Host "[Done] File Copied."
}

function RestoreUserFileStructure {
    # Restore User file
    Write-Host "Restore User File"
    $desUserDir = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\DN"
    $desUserDirIni = Join-Path -Path $desUserDir -ChildPath "desktop.ini"
    $UserDirIniContent = @'
[.ShellClassInfo]
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

function DownloadInstaller {
    DownloadAndInstall -Uri "https://dl.arturia.net/products/mfcc/soft/MiniFuse_Control_Center_1_1_1_448.exe" -Filename "MiniFuse_Control_Center_1_1_1_448.exe"
    DownloadAndInstall -Uri "https://application.ivanti.com/SSG/Clients/ps-pulse-win-9.1r11.4-b8575-64bitinstaller.msi" -Filename "ps-pulse-win-9.1r11.4-b8575-64bitinstaller.msi"
}

function RestoreWSL {
    $targetDir = Join-Path -Path $backupDir -ChildPath "WSL\Ubuntu\ubuntu-wsl-win11-2023-11-3.tar"
    New-Item -ItemType Directory -Path "C:\WSL\Images" -Force
    New-Item -ItemType Directory -Path "C:\WSL\Instance" -Force
    Write-Host "Images stored at 'C:\WSL\Images'"
    Write-Host "Instances stored at 'C:\WSL\Instance'"
    
    Write-Host "Installing wsl..."
    wsl --install
    wsl --set-default-version 2
    Write-Host "Importing WSL as ubuntu..."
    wsl --import ubuntu "C:\WSL\Instance" $targetDir
    Write-Host "[Done] Import WSL as ubuntu."
}

function RestorePicture {
    $targetDir = Join-Path -Path $backupDir -ChildPath "Documents\Pictures.7z"
    if (-not (Test-Path $targetDir)) {
        Write-Error "Target path not found: $targetDir"
        return
    }

    7z x $targetDir -o"$env:USERPROFILE" -y
}

function RestoreUserFiles {
    Write-Host "Restore User Documents..."
    New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\DN" -Force
    $restore_list = @(
        "Apps",
        "Autohotkey",
        "CMD",
        "identity",
        "Library",
        "Misc",
        "Projects",
        "Regedit",
        "Scripts",
        "Torrent",
        "大學資料"
    )

    foreach ($filename in $restore_list) {
        $filename = "$filename.7z"
        $targetDir = Join-Path -Path $backupDir -ChildPath "Documents\$filename"
        7z x $targetDir -o"$env:USERPROFILE\Documents\DN\" -y
    }
    Write-Host "[Done] Restored User Documents."
}

function main {
    InstallChocolateyAndImportModule
    InstallOhMyPosh
    RestoreWTConfig

    if (Test-Path $backupDir){
        RestoreWSL
        RestorePicture
        RestoreUserFiles
    }

    RestoreUserFileStructure
    InstallOpenSSHServer
    InstallT0Apps
    RestorePowerToysConfig
    GitConfig
    InstallT1Apps
    InstallAppsFromMsstore
    DownloadInstaller
}

# main
Pause