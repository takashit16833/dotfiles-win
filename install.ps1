$ErrorActionPreference = 'Stop'

# リポジトリ内のスクリプトを直接使う。コピーは作らない。
$scriptPath = Join-Path $PSScriptRoot 'autohotkey\window.ahk'
if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
    throw "AutoHotkey script not found: $scriptPath"
}

# AutoHotkey v2 の標準的なインストール先（ユーザー／全ユーザー）。
$candidates = @(
    (Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe')
    (Join-Path $env:ProgramFiles 'AutoHotkey\v2\AutoHotkey64.exe')
)
$ahkExe = $candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
    Select-Object -First 1

if (-not $ahkExe) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'winget is not available. Check that Windows App Installer is installed.'
    }

    # 現在のユーザーだけにインストールし、管理者権限を要求しない。
    & winget install --id AutoHotkey.AutoHotkey --exact --source winget --scope user --silent --no-upgrade --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "AutoHotkey installation failed (winget exit code: $LASTEXITCODE)."
    }

    $ahkExe = $candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
        Select-Object -First 1
    if (-not $ahkExe) {
        throw 'AutoHotkey v2 was not found at its standard location after installation.'
    }
}

# ログイン時に起動するショートカットを現在のユーザーに登録。
$startupDir = [Environment]::GetFolderPath('Startup')
$shortcutPath = Join-Path $startupDir 'dotfiles-win-window.lnk'
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $ahkExe
$shortcut.Arguments = ('"{0}"' -f $scriptPath)
$shortcut.WorkingDirectory = Split-Path -Parent $scriptPath
$shortcut.Description = 'dotfiles-win: window placement'
$shortcut.Save()

# 今すぐ有効化（同じスクリプトが動作中なら #SingleInstance Force で置き換える）。
Start-Process -FilePath $ahkExe -ArgumentList ('"{0}"' -f $scriptPath)

Write-Host "AutoHotkey: $ahkExe"
Write-Host "Key bindings: $scriptPath"
Write-Host "Startup shortcut: $shortcutPath"
