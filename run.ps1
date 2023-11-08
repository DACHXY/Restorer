# install Package Provider
Install-PackageProvider -Name NuGet -Force
Install-Module -SkipPublisherCheck -Name Microsoft.WinGet.Client -Force

# Get Winget Newest and Install
Write-Host "Downloading AppInstaller package..."
(New-Object Net.WebClient).Downloadfile("https://aka.ms/getwinget", "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle")
Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -InstallAllResources
Write-Host "[DONE] AppInstaller package Installed."

# Install the powershell
winget install -e --id Microsoft.PowerShell  --accept-package-agreements --accept-source-agreements

# Install the windows terminal preview
winget install -e --id Microsoft.WindowsTerminal.Preview  --accept-package-agreements --accept-source-agreements

# Start installer with pwsh
Start-Process pwsh -ArgumentList "-File Installer.ps1"