# 簡易版 z: 最近訪問したフォルダを記録し、名前から移動する。
# 訪問履歴は PC 内に保存する。リポジトリには含めない。
function global:Save-ZLocation {
    $location = Get-Location

    # レジストリなど、ファイルシステム以外の場所は記録しない。
    if ($location.Provider.Name -ne 'FileSystem') {
        return
    }

    $currentPath = $location.ProviderPath
    $historyFile = Join-Path $env:LOCALAPPDATA 'dotfiles-win\z-history.txt'

    try {
        $history = @()
        if (Test-Path -LiteralPath $historyFile -PathType Leaf) {
            $history = @(Get-Content -LiteralPath $historyFile -Encoding UTF8 -ErrorAction Stop)
        }

        # 同じフォルダで続けてコマンドを打っても、履歴を書き直さない。
        if ($history.Count -gt 0 -and $history[-1] -ieq $currentPath) {
            return
        }

        # 同じ場所の古い記録を消し、最新の場所として末尾へ追加する。
        # 肥大化を防ぐため、直近200件だけを残す。
        $history = @($history | Where-Object { $_ -and $_ -ine $currentPath })
        $history = @($history + $currentPath | Select-Object -Last 200)

        $historyDir = Split-Path -Parent $historyFile
        if (-not (Test-Path -LiteralPath $historyDir -PathType Container)) {
            New-Item -ItemType Directory -Path $historyDir -Force -ErrorAction Stop | Out-Null
        }

        Set-Content -LiteralPath $historyFile -Value $history -Encoding UTF8 -ErrorAction Stop
    }
    catch {
        # 履歴保存に失敗しても、PowerShell のプロンプトは使えるようにする。
    }
}

function global:z {
    param([string]$Query)

    if ([string]::IsNullOrWhiteSpace($Query)) {
        Write-Host '使い方: z <フォルダ名の一部>'
        return
    }

    $historyFile = Join-Path $env:LOCALAPPDATA 'dotfiles-win\z-history.txt'
    if (-not (Test-Path -LiteralPath $historyFile -PathType Leaf)) {
        Write-Warning 'まだ移動履歴がありません。cd でフォルダを移動してください。'
        return
    }

    # 履歴の末尾が最新。最近のフォルダから部分一致で探す。
    # ワイルドカードではなく通常の文字列として検索する。
    try {
        $history = @(Get-Content -LiteralPath $historyFile -Encoding UTF8 -ErrorAction Stop)
        for ($i = $history.Count - 1; $i -ge 0; $i--) {
            $path = $history[$i]
            if ($path.IndexOf($Query, [StringComparison]::OrdinalIgnoreCase) -lt 0) {
                continue
            }

            # 消されたフォルダへの移動は試みない。
            if (Test-Path -LiteralPath $path -PathType Container) {
                Set-Location -LiteralPath $path
                return
            }
        }

        Write-Warning "一致するフォルダがありません: $Query"
    }
    catch {
        Write-Warning "移動履歴を読み込めません: $_"
    }
}
