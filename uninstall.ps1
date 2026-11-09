param(
    [switch]$RemoveAutoHotkey
)

$ErrorActionPreference = 'Stop'

$scriptPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'autohotkey\window.ahk'))
$startupDir = [Environment]::GetFolderPath('Startup')
$shortcutPath = Join-Path $startupDir 'dotfiles-win-window.lnk'

# 自分の window.ahk だけを停止。他の AutoHotkey スクリプトは触らない。
# install.ps1 はスクリプトの絶対パスを二重引用符で囲んで起動する。
$scriptArgument = '"' + $scriptPath + '"'
$pattern = [regex]::Escape($scriptArgument) + '(?=\s|$)'
$processes = @(Get-CimInstance Win32_Process -Filter "Name = 'AutoHotkey64.exe'" |
    Where-Object { $_.CommandLine -and $_.CommandLine -match $pattern })

foreach ($process in $processes) {
    try {
        Stop-Process -Id $process.ProcessId -ErrorAction Stop
        Write-Host "Stopped window.ahk (PID $($process.ProcessId))"
    } catch {
        if (Get-Process -Id $process.ProcessId -ErrorAction SilentlyContinue) {
            throw
        }
    }
}

if (Test-Path -LiteralPath $shortcutPath -PathType Leaf) {
    Remove-Item -LiteralPath $shortcutPath -Force
    Write-Host "Removed startup shortcut: $shortcutPath"
}

if ($RemoveAutoHotkey) {
    # このセットアップが導入する、現在のユーザー用のAutoHotkeyのみ対象。
    # 他の用途でもAutoHotkeyを使う場合は、このオプションを指定しないこと。
    $userExe = Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe'
    if (Test-Path -LiteralPath $userExe -PathType Leaf) {
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            throw 'winget is required to uninstall AutoHotkey.'
        }

        & winget uninstall --id AutoHotkey.AutoHotkey --exact --source winget --scope user --silent --accept-source-agreements
        if ($LASTEXITCODE -ne 0) {
            throw "AutoHotkey uninstallation failed (winget exit code: $LASTEXITCODE)."
        }
        Write-Host 'Uninstalled AutoHotkey for the current user.'
    } else {
        Write-Host 'User-scoped AutoHotkey was not found at its standard location; nothing to uninstall.'
    }
}

Write-Host 'dotfiles-win window settings have been removed.'
