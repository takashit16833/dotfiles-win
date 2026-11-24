# Install shared Obsidian Noctis Blue One Dark CSS on Windows.
# Example: .\obsidian\install.ps1 -VaultPath 'C:\Users\user\Documents\MyVault'
# Keep this script ASCII-only for Windows PowerShell 5.1 compatibility.
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,
    [string]$DotfilesPath = (Join-Path $HOME 'workspace\dotfiles')
)

$ErrorActionPreference = 'Stop'
$vault = [IO.Path]::GetFullPath($VaultPath)
$configDir = Join-Path $vault '.obsidian'
if (-not (Test-Path -LiteralPath $configDir -PathType Container)) {
    throw "Obsidian config directory not found: $configDir (set VaultPath to vault root)"
}

$sourceDir = Join-Path $DotfilesPath 'obsidian\css'
$names = @('retro-hacker-blue-base.css', 'noctis-blue-one-dark.css')
foreach ($name in $names) {
    $source = Join-Path $sourceDir $name
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Shared CSS not found: $source (clone or update dotfiles first)"
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
            throw "CSS target is not a regular file: $target"
        }
        $sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
        $targetHash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
        if ($sourceHash -eq $targetHash) {
            Write-Host "Unchanged: $name"
            continue
        }
        $backup = "$target.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss-fffffff')"
        Copy-Item -LiteralPath $target -Destination $backup -ErrorAction Stop
        Write-Host "Backed up existing CSS: $backup"
    }
    Copy-Item -LiteralPath $source -Destination $target -ErrorAction Stop
    Write-Host "Installed CSS: $target"
}
Write-Host 'In Obsidian > Settings > Appearance, select Default theme, Dark mode, and enable both CSS snippets.'
