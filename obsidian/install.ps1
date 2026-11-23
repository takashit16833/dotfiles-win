# Obsidian の Noctis Blue One Dark を Mac の共通 CSS から導入する。
# 使用例: .\obsidian\install.ps1 -VaultPath 'C:\Users\...\Documents\MyVault'
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,
    [string]$DotfilesPath = (Join-Path $HOME 'workspace\dotfiles')
)

$ErrorActionPreference = 'Stop'
$vault = [IO.Path]::GetFullPath($VaultPath)
$configDir = Join-Path $vault '.obsidian'
if (-not (Test-Path -LiteralPath $configDir -PathType Container)) {
    throw "Obsidian の設定フォルダが見つかりません: $configDir （VaultPath には保管庫のルートを指定してください）"
}
$sourceDir = Join-Path $DotfilesPath 'obsidian\css'
$names = @('retro-hacker-blue-base.css', 'noctis-blue-one-dark.css')
foreach ($name in $names) {
    $source = Join-Path $sourceDir $name
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "共通 CSS が見つかりません: $source （先に dotfiles を取得してください）"
    }
}
$targetDir = Join-Path $configDir 'snippets'
if (-not (Test-Path -LiteralPath $targetDir -PathType Container)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}
foreach ($name in $names) {
    $source = Join-Path $sourceDir $name
    $target = Join-Path $targetDir $name
    if (Test-Path -LiteralPath $target) {
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
            throw "CSS の配置先が通常のファイルではありません: $target"
        }
        $same = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -eq
                (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
        if ($same) {
            Write-Host "変更なし: $name"
            continue
        }
        $backup = "$target.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss-fffffff')"
        Copy-Item -LiteralPath $target -Destination $backup -ErrorAction Stop
        Write-Host "既存の CSS を退避: $backup"
    }
    Copy-Item -LiteralPath $source -Destination $target -ErrorAction Stop
    Write-Host "CSS を配置: $target"
}
Write-Host 'Obsidian の「設定 → 外観 → CSS スニペット」で上記2ファイルを有効にしてください。テーマは「デフォルト」、配色はダークに設定してください。'
