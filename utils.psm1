# Check If admin
function CheckIsAdmin() {
    return (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function GetRootPath() {
    return Split-Path -parent $MyInvocation.MyCommand.Definition
}

function DownloadAndInstall {
    param (
        [uri] $Uri,
        [string] $Filename
    )

    Write-Host "[Downloading] $Filename"
    $nc = New-Object Net.WebClient
    $nc.DownloadFile($Uri, "$env:USERPROFILE/Downloads/$Filename")
    Write-Host "[Done] $Filename"

    & "$env:USERPROFILE/Downloads/$Filename"
}