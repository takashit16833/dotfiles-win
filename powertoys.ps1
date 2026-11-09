param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Install', 'Uninstall')]
    [string]$Action
)

$ErrorActionPreference = 'Stop'

function Test-PowerToysInstalled {
    # Per-user and machine-wide installations.
    $executables = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\PowerToys\PowerToys.exe')
        (Join-Path $env:ProgramFiles 'PowerToys\PowerToys.exe')
    )
    foreach ($exe in $executables) {
        if (Test-Path -LiteralPath $exe -PathType Leaf) {
            return $true
        }
    }

    # Installed apps registry: also catches installations in a custom location.
    $uninstallKeys = @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    foreach ($key in $uninstallKeys) {
        $entry = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue |
            Where-Object {
                $_.DisplayName -match '^(Microsoft )?PowerToys(\s|$)' -and
                $_.Publisher -like '*Microsoft*'
            } |
            Select-Object -First 1
        if ($entry) {
            return $true
        }
    }

    # PowerToys may also be installed from Microsoft Store.
    if (Get-AppxPackage -Name 'Microsoft.PowerToys' -ErrorAction SilentlyContinue) {
        return $true
    }

    return $false
}

$installed = Test-PowerToysInstalled

if ($Action -eq 'Install') {
    if ($installed) {
        Write-Host 'PowerToys is already installed. Skipping.'
        return
    }

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'winget is required to install PowerToys.'
    }

    # Per-user installation. Do not upgrade an existing installation.
    & winget install --id Microsoft.PowerToys --exact --source winget --scope user --silent --no-upgrade --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "PowerToys installation failed (winget exit code: $LASTEXITCODE)."
    }
    Write-Host 'PowerToys installed.'
    return
}

if (-not $installed) {
    Write-Host 'PowerToys is not installed. Nothing to uninstall.'
    return
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget is required to uninstall PowerToys.'
}

# This explicit action may require elevation for a machine-wide installation.
& winget uninstall --id Microsoft.PowerToys --exact --source winget --silent --accept-source-agreements
if ($LASTEXITCODE -ne 0) {
    throw "PowerToys uninstallation failed (winget exit code: $LASTEXITCODE)."
}
Write-Host 'PowerToys uninstalled.'
