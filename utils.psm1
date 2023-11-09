# Check If admin
function CheckIsAdmin() {
    return (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function GetRootPath() {
    return Split-Path -parent $MyInvocation.MyCommand.Definition
}