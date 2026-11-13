# dotfiles-win

Windows 11 用の個人設定。

## セットアップ

会社PCでは、PowerToys・`winget` の利用が許可されていることを確認する。

```powershell
git clone https://github.com/takashit16833/dotfiles-win.git
cd dotfiles-win
.\install.ps1
```

`install.ps1` は旧版の AutoHotkey ウィンドウ配置を停止し、PowerToys が未導入なら `winget` でインストールする。また、AutoHotkey v2 が導入済みなら `Alt + @` のウィンドウ切り替えを起動して自動起動に登録する。**AutoHotkey 本体は追加・削除しない**。既存の導入状態で再実行できる。

## ウィンドウ配置（ZMK）

ウィンドウ配置は Windows 標準の `Win + 矢印` を直接使う。ZMK の `Hyper + I / - / A / O` への割り当ては廃止した。1/3・2/3 配置や最大化トグルにも依存しない。
Windows 用 `layer_14` の閉じるキーも `Ctrl + W` を直接送る。

仮想デスクトップの切り替え `Hyper + C / V` は ZMK 側で引き続き利用できる。

## 同じアプリのウィンドウ切り替え（AutoHotkey）

日本語キーボードの `Alt + @` で、現在のアプリが開いている別ウィンドウへ順番に切り替える（例：VS Code A → B → C → A）。ウィンドウが1つしかない場合は何もしない。

`autohotkey/cycle-window.ahk` を AutoHotkey v2 で実行する。通常は `install.ps1` で常駐開始・サインイン時の自動起動まで登録される。AutoHotkey v2 が見つからない場合は警告して登録を飛ばすため、導入後に `install.ps1` を再実行する。

`uninstall.ps1` でこの常駐処理と自動起動設定も解除する。RDP 接続先の開発端末内のアプリを切り替えるには、接続先でも動作するか別途確認が必要。

## PowerToys

```powershell
.\powertoys.ps1 -Action Install
.\powertoys.ps1 -Action Uninstall
```

PowerToys の設定（Command Palette や Bookmarks）は管理していない。

## PowerShell プロンプト

外部ツールを使わず、`powershell/prompt.ps1` でプロンプトを表示する。現在のパスはホーム配下なら `~/` で始め、ホーム以外は `C:\` などの絶対パスで表示する。Git 管理下なら現在のブランチを付ける。

```text
~/workspace/dotfiles-win (main) ❯
C:\Windows\System32 ❯
```

### 適用

```powershell
cd ~/workspace/dotfiles-win
git pull --ff-only
.\powershell\install.ps1
```

現在のユーザーの共通プロファイル（`$PROFILE.CurrentUserAllHosts`）に設定ファイルの読み込みを1行だけ追加し、その場でも反映する。既存のプロファイルは上書きせず、再実行しても重複登録しない。`winget` や追加ソフトは不要。

設定変更は `powershell/prompt.ps1` を編集する。変更後は PowerShell を開き直す。Windows PowerShell 5.1 と PowerShell 7 はプロファイルの保存先が異なるので、両方で使う場合はそれぞれで一度実行する。

解除する場合は `notepad $PROFILE.CurrentUserAllHosts` で開き、追加された `prompt.ps1` の読み込み行を削除する。ほかの設定は残す。

## VS Code

Mac と同じ操作感になるよう、Windows 用の設定を分けて管理する。

- `vscode/keybindings.json`：Explorer、エディタのタブ、パネル、Markdown 切り替え、スクロールのキー操作
- `vscode/settings.json`：補完、JSON 保存時の整形、Markdown Editor の既定設定など。Mac 固有のフォント・パス・見た目の設定は含めない

### 適用（リポジトリを直接参照）

Windows 標準版 VS Code は `%APPDATA%\Code\User` の `keybindings.json` と `settings.json` を読む。リポジトリにある2ファイルを**シンボリックリンク**で参照すれば、コピーや手動同期は不要。

まず `git pull --ff-only` で `dotfiles-win` を更新する。続いて VS Code の `Ctrl+Shift+P` から **Preferences: Open User Settings (JSON)** と **Preferences: Open Keyboard Shortcuts (JSON)** を開き、既存の独自設定が必要なら**リポジトリ側のファイルに統合**する。パスワードや端末固有の値は Git に登録しない。

PowerShell に以下を**直接貼り付けて**実行する（`.ps1` の実行や実行ポリシーの変更は不要）。

```powershell
$sourceDir = Join-Path $HOME 'workspace\dotfiles-win\vscode'
$userDir = Join-Path $env:APPDATA 'Code\User'
foreach ($name in @('keybindings.json', 'settings.json')) {
    $source = Join-Path $sourceDir $name
    $target = Join-Path $userDir $name
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "設定元がありません: $source"
    }

    $current = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
    if ($current -and $current.LinkType -eq 'SymbolicLink') {
        if (@($current.Target)[0] -eq $source) {
            Write-Host "リンク済み: $name"
            continue
        }
        throw "別のリンクが存在します。確認してください: $target"
    }

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
    Write-Host "設定済み: $name"
}
```

既存ファイルは `.bak-日時` に退避し、リンク作成に失敗した場合は元へ戻す。**既存の VS Code 設定は自動統合しない**ため、リンク作成前に必要な設定を確認すること。すでに正しくリンク済みのファイルは触らない。VS Code 上での設定変更はリポジトリ側のファイルに反映される。

リンク作成には Windows の開発者モードまたは管理者権限が必要な場合がある。会社 PC の権限設定を許可なく変更しない。ハードリンクでは Git 更新時に参照が切れる場合があるため代用しない。

### キー操作

| 対象 | キー | 動作 |
| --- | --- | --- |
| Explorer | `←` | フォルダを閉じる（標準動作） |
| Explorer | `→` | フォルダを展開／ファイルを開き、パネルとサイドバーを閉じる |
| Explorer | `Ctrl+N` | 選択位置に新しいファイルを作成 |
| Explorer | `Ctrl+←` | 全フォルダを折りたたむ |
| Explorer | `Ctrl+↑/↓` | 先頭／末尾へ移動 |
| エディタ | `Ctrl+PageUp/Down` | 前／次のタブ |
| パネル | `Ctrl+PageUp/Down` | 前／次のパネル（問題・出力・ターミナルなど） |
| Markdown Editor | `Ctrl+E` | 編集・プレビューを切り替える |
| テキストエディタ | `Alt+PageUp/Down` | 1行ずつスクロール |
| テキストエディタ | `PageUp/Down` | 半ページずつスクロール |

Explorer / エディタ / パネルのフォーカスに応じて操作が切り替わる。

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
