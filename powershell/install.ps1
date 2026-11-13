$ErrorActionPreference = 'Stop'

# プロンプトの設定本体はリポジトリから直接読み込む。
$promptScript = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'prompt.ps1'))
$profilePath = $PROFILE.CurrentUserAllHosts
$loadLine = ". '$($promptScript.Replace("'", "''"))'"

# 既存の PowerShell プロファイルを消さず、なければ作る。
$profileDir = Split-Path -Parent $profilePath
if (-not (Test-Path -LiteralPath $profileDir -PathType Container)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
if (-not (Test-Path -LiteralPath $profilePath -PathType Leaf)) {
    New-Item -ItemType File -Path $profilePath | Out-Null
}

# 読み込み行を重複登録しない。既存の設定行は保持する。
$lines = @(Get-Content -LiteralPath $profilePath)
if ($lines -cnotcontains $loadLine) {
    $existing = Get-Content -LiteralPath $profilePath -Raw
    $prefix = if ($existing -and -not $existing.EndsWith([string][char]10)) { [Environment]::NewLine } else { '' }
    Add-Content -LiteralPath $profilePath -Value ($prefix + $loadLine)
    Write-Host "Registered PowerShell prompt: $profilePath"
}
else {
    Write-Host "PowerShell prompt is already registered: $profilePath"
}

# 次回起動を待たず、今の PowerShell でも設定を有効にする。
. $promptScript
