# dotfiles-win

Windows 11 用の個人設定。

## セットアップ

会社PCでは、PowerToys・`winget` の利用が許可されていることを確認する。

```powershell
git clone https://github.com/takashit16833/dotfiles-win.git
cd dotfiles-win
.\install.ps1
```

`install.ps1` は旧版の AutoHotkey ウィンドウ配置を停止し、PowerToys が未導入なら `winget` でインストールする。また、AutoHotkey v2 が導入済みなら、ウィンドウ配置と `Alt + @` の切り替え機能を起動して自動起動に登録する。**AutoHotkey 本体は追加・削除しない**。既存の導入状態で再実行できる。

## ウィンドウ配置（AutoHotkey v2）

`autohotkey/window-layout.ahk` は macOS の `.hammerspoon/init.lua` にある配置操作に合わせている。`cycle-window.ahk` から読み込むため、既存の `Alt + @` と同じ AutoHotkey プロセスで動く。

| 操作 | Windows の Hyper（`Ctrl + Alt + Win`） | ZMK から送れる専用キー |
| --- | --- | --- |
| 左：横幅2400以上の画面では1/3、未満では1/2 | `Hyper + I` | `F19` |
| 中央1/3 | `Hyper + O` | `F20` |
| 右：横幅2400以上の画面では1/3、未満では1/2 | `Hyper + -` | `F21` |
| 左2/3（画面幅を問わない） | `Hyper + Shift + I` | `Shift + F19` |
| 右2/3（画面幅を問わない） | `Hyper + Shift + -` | `Shift + F21` |
| 最大化と変更前の位置・大きさへの復元 | `Hyper + A` | `F22` |
| 次のモニターへウィンドウを移動 | `Hyper + Tab` | — |
| 前のモニターへウィンドウを移動 | `Hyper + Shift + Tab` | — |

Windows の `Hyper` は `Ctrl + Alt + Win` の同時押し。`-` は物理キー（`SC00C`）で検出する。モニター移動では移動先の画面サイズに合わせて相対位置・大きさを維持する。複数画面の巡回順序は Windows のモニター列挙順で、画面の物理的な左右順とは限らない。

**画面幅の判定について：** macOS はポイント単位で2400以上を判定するが、Windows 側は AutoHotkey から取得した作業領域の幅（Windows座標）で2400以上を判定する。表示倍率が異なる環境では同じ物理画面でも判定結果が異なる可能性がある。実機の画面幅と動作は確認が必要。

**ZMK の割り当ては別：** Windows 用 ZMK の `Hyper + I / O / - / A` は以前の Windows 標準 `Win + 矢印` 等を送る設定のまま。Mac と同じ物理操作を使うには、ZMK 側を `Ctrl + Alt + Win + キー` または `F19`～`F22` に変更する必要がある。それまでは Windows のキーボードからショートカットを入力する。

適用コマンド（PowerShell）：

```powershell
cd ~/workspace/dotfiles-win
git pull --ff-only
.\install.ps1
```

ウィンドウ配置は現在操作中のウィンドウに対して行う。RDP 接続先のウィンドウには、接続先でもこのスクリプトを動かす必要がある場合がある。Windows 用 `layer_14` の閉じるキーは `Ctrl + W`、仮想デスクトップの切り替え `Hyper + C / V` は ZMK 側の設定を使う。

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

外部のテーマ表示ツールに依存せず、`powershell/prompt.ps1` でプロンプトを表示する。現在のパスはホーム配下なら `~/` で始め、ホーム以外は `C:\` などの絶対パスで表示する。Git 管理下なら現在のブランチを付ける。

```text
~/workspace/dotfiles-win (main) ❯
C:\Windows\System32 ❯
```

### zoxide / fzf / lazygit

`powershell/z.ps1` による自作のフォルダ移動機能は廃止し、[zoxide](https://github.com/ajeetdsouza/zoxide) に置き換えた。
`powershell/install.ps1` は、次の3つが未導入の場合に限って `winget` でインストールする。

| ツール | 用途 | コマンド |
| --- | --- | --- |
| zoxide | 過去に移動したフォルダへ素早く移動 | `z nag` |
| fzf | 候補を入力しながら絞り込む | `fzf` |
| lazygit | ターミナル上でGitの状態確認や操作をする | `lg`（`lazygit` の別名） |

`cd` で移動した場所は zoxide が自動で学習する。`z nag` は履歴から候補を選び、`zi` は fzf で候補を対話的に選べる。`zi nag` で候補を絞り込んでから選択できる（公式の標準機能なので設定追加不要）。
fzf は単体コマンドと `zi` で使用する。さらにPowerShell用の[PSFzf](https://github.com/kelleyma49/PSFzf)を導入し、`Ctrl+R` をPSReadLineのコマンド履歴の絞り込み検索へ割り当てる。
検索画面では文字入力で候補を絞り、矢印キーで選び、Enterでコマンドを**入力欄に戻すだけ**（実行はしない）。Escでキャンセルできる。

`lg` は `prompt.ps1` で定義する。`lazygit` が導入されており、既存の `lg` コマンドがない場合だけ追加する。既存のキー設定は変更しない。

旧版の履歴 `%LOCALAPPDATA%\dotfiles-win\z-history.txt` は削除しないが、zoxide へ自動移行もしない。
zoxide は導入後に訪問したフォルダから学習し直す。

### fnm（Node.js）

fnm が導入済みなら、PowerShell 起動時に `prompt.ps1` が `fnm env --use-on-cd --shell powershell` を適用する。Node.js 自体や fnm は自動インストールしない。`.node-version` 等があるフォルダへ移動した場合も切り替わる。fnm が未導入なら何もしない。

既に fnm に Node.js が導入されている場合は、以下で確認する。

```powershell
fnm current
node --version
npm --version
```

### 適用

```powershell
cd ~/workspace/dotfiles-win
git pull --ff-only
.\powershell\install.ps1
```

現在のユーザーの共通プロファイル（`$PROFILE.CurrentUserAllHosts`）に `prompt.ps1` の読み込みを1行だけ追加する。既存のプロファイルは上書きせず、再実行しても重複登録しない。
PSFzfはPowerShell Galleryから現在のユーザーにのみ導入し、既存のものは再インストールしない。PowerShellの起動時にPSReadLine→PSFzfの順に読み込み、Ctrl+Rを割り当てる。PSFzfまたはfzfがない場合は既存のCtrl+Rの動作を変更しない。
ツールの新規インストール直後は、環境変数 PATH の更新を反映するため **PowerShell を開き直す**。PowerShell 5.1 と PowerShell 7 の両方を利用する場合は、それぞれで1回ずつ設定を適用する。

`zoxide` が利用できる環境では `prompt.ps1` から公式の `zoxide init powershell` を読み込む。未導入でも独自プロンプト表示は動作する。
`winget` が利用できない場合は自動インストールを行わず、エラーを表示する。PSFzfの導入にはPowerShellGet（`Install-Module`）とPowerShell Galleryへの接続が必要。会社PCでは各ツールの導入が許可されていることを確認する。

確認例：

```powershell
zoxide --version
fzf --version
lazygit --version
Get-Command z, zi, lg
Get-PSReadLineKeyHandler | Where-Object { $_.Key -eq 'Ctrl+r' }
```

プロンプトの表示だけを変更する場合は `powershell/prompt.ps1` を編集し、PowerShell を開き直す。
設定を解除するには `notepad $PROFILE.CurrentUserAllHosts` でプロファイルを開き、追加された `prompt.ps1` の読み込み行を削除する。これだけでは導入済みの3ツールはアンインストールされない。

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

## Obsidian（Noctis Blue One Dark）

Mac と共通の CSS を利用する。配色の定義を Windows 側には複製せず、`~/workspace/dotfiles/obsidian/css` の2ファイルを Obsidian の保管庫にコピーする。Mac 用の `dotfiles/install.sh` は Windows で実行しない。

まだ共通リポジトリがない場合:

```powershell
cd ~/workspace
git clone https://github.com/takashit16833/dotfiles.git
```

Obsidian の保管庫フォルダ（中に `.obsidian` がある場所）を指定して実行する:

```powershell
cd ~/workspace/dotfiles-win
.\obsidian\install.ps1 -VaultPath 'C:\path\to\your\vault'
```

`retro-hacker-blue-base.css` と `noctis-blue-one-dark.css` を `.obsidian/snippets` に配置する。同名ファイルの内容が異なる場合は、日時付きバックアップを残してから更新する。同じ内容なら何もしない。既存の Obsidian の設定ファイルには触れない。

Obsidian の「設定 → 外観」でテーマを「デフォルト」、配色をダークにし、「CSS スニペット」で2つを有効にする（初回はスニペット一覧を再読み込みする）。後日、`dotfiles` を `git pull --ff-only` で更新したら同じスクリプトを再実行する。

## Windows Terminal

`windows-terminal/install.ps1` でタブのショートカットを自動設定する。既存の `settings.json` の内容やコメントを保ちながら、必要な項目だけ追加する。変更前には同じフォルダに日時付きバックアップを作成する。何度実行しても同じ項目を重複追加しない。キーの割り当てが競合している場合は、勝手に上書きせずエラーで停止する。

```powershell
cd ~/workspace/dotfiles-win
git pull --ff-only
.\windows-terminal\install.ps1
```

`install.ps1` 全体を実行する場合にも、Node.js が使用可能なら自動で適用する。Windows Terminal がまだ設定ファイルを作成していない場合は何もしない。Node.js は自動インストールしない。

| キー | 動作 |
| --- | --- |
| `Ctrl+PageUp` | 左のタブ（表示順） |
| `Ctrl+PageDown` | 右のタブ（表示順） |
| `Ctrl+W` | 現在のタブを閉じる |

設定ファイルが複数見つかる場合（正式版・Preview版など）は、自動でどちらかを選ばず停止する。適用対象を指定する場合は `-SettingsPath 'C:\...\settings.json'` を付ける。

「賢いコピー」は独自設定せず、Windows Terminal の標準コピーを利用する。以前手動で追加した `Ctrl+Alt+C` や `autoMarkPrompts` は自動削除しないため、不要なら利用者が確認して解除する。

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
