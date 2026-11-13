# z の訪問履歴保存と移動コマンドを利用できるようにする。
. (Join-Path $PSScriptRoot 'z.ps1')

function global:prompt {
    $location = Get-Location
    $locationPath = $location.Path
    $homePath = $HOME.TrimEnd('\')
    $displayPath = $locationPath

    # ホームディレクトリ内は絶対パスの代わりに ~/ で表示する。
    # それ以外は C:\ などから始まるパスをそのまま表示する。
    if ($locationPath -ieq $homePath) {
        $displayPath = '~'
    }
    elseif ($locationPath.StartsWith($homePath + '\', [StringComparison]::OrdinalIgnoreCase)) {
        $displayPath = '~/' + $locationPath.Substring($homePath.Length + 1).Replace('\', '/')
    }

    # プロンプトが表示されるたびに、訪問したフォルダを記録する。
    Save-ZLocation

    # Git のブランチ名を表示する。Git 管理外では表示しない。
    # ファイルシステム以外（レジストリなど）では Git を呼び出さない。
    $branch = $null
    if ($location.Provider.Name -eq 'FileSystem' -and
        (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {

        # Git の実行によって、直前のコマンドの終了コードを変えない。
        $previousExitCode = $global:LASTEXITCODE
        try {
            $branch = git -C $location.ProviderPath branch --show-current 2>$null
        }
        finally {
            $global:LASTEXITCODE = $previousExitCode
        }
    }

    # フォルダは水色、Git ブランチは紫色で表示する。
    Write-Host $displayPath -NoNewline -ForegroundColor Cyan
    if ($branch) {
        Write-Host " ($branch)" -NoNewline -ForegroundColor Magenta
    }

    # PowerShell は prompt 関数が返した文字列を入力待ちの記号に使う。
    return " $([char]0x276F) "
}
