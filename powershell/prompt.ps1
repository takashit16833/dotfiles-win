function global:prompt {
    $locationPath = (Get-Location).Path
    $homePath = $HOME.TrimEnd('\')
    $displayPath = $locationPath

    if ($locationPath -ieq $homePath) {
        $displayPath = '~'
    }
    elseif ($locationPath.StartsWith($homePath + '\', [StringComparison]::OrdinalIgnoreCase)) {
        $displayPath = '~/' + $locationPath.Substring($homePath.Length + 1).Replace('\', '/')
    }

    $branch = $null
    if (Get-Command git -CommandType Application -ErrorAction SilentlyContinue) {
        # A prompt must not change the exit code of the preceding command.
        $previousExitCode = $global:LASTEXITCODE
        try {
            $branch = git -C $locationPath branch --show-current 2>$null
        }
        finally {
            $global:LASTEXITCODE = $previousExitCode
        }
    }

    Write-Host $displayPath -NoNewline -ForegroundColor Cyan
    if ($branch) {
        Write-Host " ($branch)" -NoNewline -ForegroundColor Magenta
    }

    return " $([char]0x276F) "
}
