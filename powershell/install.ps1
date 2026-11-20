$ErrorActionPreference = 'Stop'

# 必要なツールだけ winget で導入する。すでに利用可能なら再インストールしない。
$packages = @(
    @{ Name = 'zoxide'; Id = 'ajeetdsouza.zoxide' },
    @{ Name = 'fzf'; Id = 'junegunn.fzf' },
    @{ Name = 'lazygit'; Id = 'JesseDuffield.lazygit' }
)
$missing = @($packages | Where-Object {
    -not (Get-Command $_.Name -CommandType Application -ErrorAction SilentlyContinue)
})

if ($missing.Count -gt 0) {
    if (-not (Get-Command winget -CommandType Application -ErrorAction SilentlyContinue)) {
        throw 'winget が見つかりません。必要なツールのインストールには winget が必要です。'
    }

    foreach ($package in $missing) {
        Write-Host "Installing $($package.Name) ($($package.Id))..."
        & winget install --id $package.Id --exact --source winget --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to install $($package.Name) (winget exit code: $LASTEXITCODE)."
        }
    }
    Write-Host 'インストール後は PowerShell を開き直して PATH の更新を反映してください。'
}

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
# 新規インストールしたツールは PATH が未反映の場合があるため、開き直し後に有効になる。
. $promptScript
