$fileRoot = Split-Path -parent $MyInvocation.MyCommand.Definition

# install Package Provider
Install-PackageProvider -Name NuGet -Force
Install-Module -SkipPublisherCheck -Name Microsoft.WinGet.Client -Force

# Get Winget Newest and Install
Write-Host "Downloading AppInstaller package..."
$desPath = "$fileRoot\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
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
Start-Process pwsh "$FileRoot\Installer.ps1"