# dotfiles-win

Windows 11 用の個人設定。

## セットアップ

会社PCでは、PowerToys・`winget` の利用が許可されていることを確認する。

```powershell
git clone https://github.com/takashit16833/dotfiles-win.git
cd dotfiles-win
.\install.ps1
```

`install.ps1` は旧版の AutoHotkey ウィンドウ配置を停止して自動起動を解除し、PowerToys が未導入なら `winget` でインストールする。**AutoHotkey 本体は削除しない**。既存の導入状態で再実行できる。

## ウィンドウ配置（ZMK）

ウィンドウ配置は Windows 標準の `Win + 矢印` を直接使う。ZMK の `Hyper + I / - / A / O` への割り当ては廃止した。1/3・2/3 配置や最大化トグルにも依存しない。
Windows 用 `layer_14` の閉じるキーも `Ctrl + W` を直接送る。

仮想デスクトップの切り替え `Hyper + C / V` は ZMK 側で引き続き利用できる。

## PowerToys

```powershell
.\powertoys.ps1 -Action Install
.\powertoys.ps1 -Action Uninstall
```

PowerToys の設定（Command Palette や Bookmarks）は管理していない。

## VS Code のキー操作

`vscode/keybindings.json` に、Mac で使っている Explorer とタブ移動の操作を Windows 用に移植した。

**適用（リポジトリを直接参照）**

Windows 標準版 VS Code のユーザーキー設定 `%APPDATA%\Code\User\keybindings.json` から `dotfiles-win/vscode/keybindings.json` への**シンボリックリンク**を作る。コピーや手作業での再同期は不要。

最初に VS Code で `Ctrl+Shift+P` → **Preferences: Open Keyboard Shortcuts (JSON)** を開き、**既存のキー設定があれば確認する**。今まで使っていた独自設定は必要に応じて `dotfiles-win/vscode/keybindings.json` に統合してから、PowerShell に次を貼り付けて実行する。

```powershell
$source = Join-Path $HOME 'workspace\dotfiles-win\vscode\keybindings.json'
$target = Join-Path $env:APPDATA 'Code\User\keybindings.json'
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "設定元がありません: $source" }
$current = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
if ($current -and $current.LinkType -eq 'SymbolicLink' -and $current.Target -eq $source) {
    Write-Host 'すでにリンク済みです'
} else {
    $backup = $null
    if ($current) {
        $backup = "$target.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Move-Item -LiteralPath $target -Destination $backup -ErrorAction Stop
    }
    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $source -ErrorAction Stop | Out-Null
    } catch {
        if ($backup -and -not (Test-Path -LiteralPath $target)) {
            Move-Item -LiteralPath $backup -Destination $target -ErrorAction Stop
        }
        throw
    }
}
Get-Item -LiteralPath $target -Force | Select-Object FullName, LinkType, Target
```

既存ファイルは日時付き `.bak-...` に退避し、リンク作成に失敗した場合は元に戻す。VS Code の操作から保存した変更も、リポジトリ側のファイルに反映される。**初回適用後、VS Code でキー操作を確認すること。**

Windows ではリンク作成に管理者権限か開発者モードが必要な場合がある。会社 PC で許可されていない場合は、権限や組織の設定を変更せず中断する。PowerShell の実行ポリシーは変更不要。ハードリンクは Git 更新で参照が切れる場合があるため、代用しない。

| 対象 | キー | 動作 |
| --- | --- | --- |
| Explorer | `←` | フォルダを閉じる（標準動作） |
| Explorer | `→` | フォルダを展開／ファイルを開き、パネルとサイドバーを閉じる |
| Explorer | `Ctrl+N` | 選択位置に新しいファイルを作成 |
| Explorer | `Ctrl+←` | 全フォルダを折りたたむ |
| Explorer | `Ctrl+↑/↓` | 先頭／末尾へ移動 |
| エディタ | `Ctrl+PageUp/Down` | 前／次のタブ |
| パネル | `Ctrl+PageUp/Down` | 前／次のパネル（問題・出力・ターミナルなど） |

Explorer / エディタ / パネルの**フォーカスに応じて**操作が切り替わる。その他の VS Code 設定（補完、Markdown Editor、スクロールなど）は今回の設定には含めない。

## 旧 AutoHotkey 設定の解除・アンインストール

旧版で起動した `window.ahk` と自動起動ショートカットだけを解除する場合:

```powershell
.\uninstall.ps1
```

AutoHotkey 本体も削除したい場合のみ、明示的に指定する（ほかの用途で使っている場合は指定しない）。

```powershell
.\uninstall.ps1 -RemoveAutoHotkey
```

PowerToys を削除したい場合は `-RemovePowerToys` を指定する。2つの引数は併用できる。
