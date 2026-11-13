$ErrorActionPreference = 'Stop'

# 旧版の AutoHotkey によるウィンドウ配置を停止し、自動起動を解除する。
# AutoHotkey 本体はアンインストールしない。
& (Join-Path $PSScriptRoot 'uninstall.ps1')

# ウィンドウ配置は ZMK から Windows 標準ショートカットを直接送る。
# PowerToys が未導入の場合だけインストールする。
& (Join-Path $PSScriptRoot 'powertoys.ps1') -Action Install

# 同じアプリのウィンドウを Alt + @ で切り替える。
# AutoHotkey は既存のものを利用し、勝手に追加インストールしない。
$ahkPaths = @(
    (Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe'),
    (Join-Path $env:ProgramFiles 'AutoHotkey\v2\AutoHotkey64.exe')
)
$ahkExe = $ahkPaths | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if ($ahkExe) {
    $scriptPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'autohotkey\cycle-window.ahk'))
    $startupDir = [Environment]::GetFolderPath('Startup')
    $shortcutPath = Join-Path $startupDir 'dotfiles-win-cycle-window.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $ahkExe
    $shortcut.Arguments = '"' + $scriptPath + '"'
    $shortcut.WorkingDirectory = Split-Path -Parent $scriptPath
    $shortcut.Save()

    # 再実行時も #SingleInstance Force により二重起動しない。
    Start-Process -FilePath $ahkExe -ArgumentList ('"' + $scriptPath + '"')
    Write-Host 'Enabled Alt+@ window cycling (startup registered).'
} else {
    Write-Warning 'AutoHotkey v2 was not found; Alt+@ is not enabled. Install AutoHotkey v2, then rerun install.ps1.'
}
