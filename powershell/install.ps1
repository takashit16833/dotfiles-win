$ErrorActionPreference = 'Stop'

$promptScript = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'prompt.ps1'))
$profilePath = $PROFILE.CurrentUserAllHosts
$loadLine = ". '$($promptScript.Replace("'", "''"))'"

$profileDir = Split-Path -Parent $profilePath
if (-not (Test-Path -LiteralPath $profileDir -PathType Container)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
if (-not (Test-Path -LiteralPath $profilePath -PathType Leaf)) {
    New-Item -ItemType File -Path $profilePath | Out-Null
}

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

. $promptScript
