
$backupDir = $args[0]

if (-not (Test-Path $backupDir)){
    Write-Error "Path: $backupDir not exist!"
}

Write-Host "Restore Path: $backupDir"

$FILE_ROOT = Split-Path -parent $MyInvocation.MyCommand.Definition

Import-Module -Name "$FILE_ROOT/utils.psm1"

$isAdmin = CheckIsAdmin
if (-not $isAdmin) {
    Write-Error "You are not Admin! Please run this script with Administrator privilege!"
    Pause
    Exit
}

# install Package Provider
Install-PackageProvider -Name NuGet -Force
Install-Module -SkipPublisherCheck -Name Microsoft.WinGet.Client -Force

# Get Winget Newest and Install
Write-Host "Downloading AppInstaller package..."
$desPath = "$FILE_ROOT\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
(New-Object Net.WebClient).Downloadfile("https://aka.ms/getwinget", $desPath)
Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -InstallAllResources
Write-Host "[DONE] AppInstaller package Installed."
Write-Host "Clean up installer package..."
Remove-Item $desPath
Write-Host "[Done] Cleaned up."

# Install the powershell
winget install -e --id Microsoft.PowerShell  --accept-package-agreements --accept-source-agreements

# Install the windows terminal preview
winget install -e --id Microsoft.WindowsTerminal.Preview  --accept-package-agreements --accept-source-agreements

Write-Host "Installing Apps & Environment"
# Start installer with pwsh
Start-Process pwsh -ArgumentList "-File $FILE_ROOT\Installer.ps1 $backupDir"