# Apply Windows Terminal shortcuts without replacing existing settings.
# Requires Node.js and an existing Windows Terminal settings.json.
param([string]$SettingsPath)

$ErrorActionPreference = 'Stop'
if (-not (Get-Command node -CommandType Application -ErrorAction SilentlyContinue)) {
    throw 'Node.js is required. Open a PowerShell session with fnm initialized.'
}
if (-not $SettingsPath) {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json')
    )
    $found = @($candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
    if ($found.Count -eq 0) {
        Write-Host 'No Windows Terminal settings.json found; skipping.'
        return
    }
    if ($found.Count -gt 1) {
        throw 'Multiple Terminal settings.json files found. Specify -SettingsPath explicitly.'
    }
    $SettingsPath = $found[0]
}
if (-not (Test-Path -LiteralPath $SettingsPath -PathType Leaf)) {
    throw "Windows Terminal settings.json not found: $SettingsPath"
}

& node (Join-Path $PSScriptRoot 'apply.js') $SettingsPath
if ($LASTEXITCODE -ne 0) {
    throw "Windows Terminal shortcut setup failed (exit code $LASTEXITCODE)."
}
