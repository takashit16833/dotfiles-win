# dotfiles-win

Windows 11 用の個人設定。

## セットアップ

会社PCでは、AutoHotkey・PowerToys・`winget` の利用が許可されていることを確認する。

```powershell
git clone https://github.com/takashit16833/dotfiles-win.git
cd dotfiles-win
.\install.ps1
```

`install.ps1` は、AutoHotkey v2 と PowerToys が未導入なら `winget` で現在のユーザーにインストールする。また、`autohotkey/window.ahk` を起動し、ログイン時の自動起動を登録する。

**再実行可能**。導入済みの PowerToys はスキップし、AutoHotkey も標準の場所にあれば再インストールしない。自動起動のショートカットは上書きし、実行中の同じ AutoHotkey スクリプトは置き換える。

リポジトリは移動せず、同じ場所で使う（自動起動のショートカットがファイルを直接参照するため）。

## PowerToys

PowerToys だけを操作する場合は次を実行する。

```powershell
.\powertoys.ps1 -Action Install
.\powertoys.ps1 -Action Uninstall
```

インストール済みなら導入を省略し、未インストールなら削除を省略する。新規インストールはユーザー単位。削除は明示したときだけ実行する。全ユーザー向けに導入されている場合は削除に管理者権限が必要になることがある。

PowerToys の設定（Command Palette や Bookmarks）は現時点では管理していない。

## ウィンドウ配置

ZMK の Windows 用 `layer_15` と連携する。

| 物理操作 | ZMK が送信 | 動作 |
| --- | --- | --- |
| Hyper + I | F19 | 左 1/3 |
| Hyper + O | F20 | 中央 1/3 |
| Hyper + - | F21 | 右 1/3 |
| Hyper + Shift + I | Shift + F19 | 左 2/3 |
| Hyper + Shift + - | Shift + F21 | 右 2/3 |
| Hyper + A | F22 | 最大化／元に戻す |

Windows 用 `layer_14` の「閉じる」キーは `F23` を送り、AutoHotkey で短押し・長押しを判定する。

| 操作 | ZMK が送信 | 動作 |
| --- | --- | --- |
| 閉じるキーを短押し | F23 | `Ctrl + W`：タブや文書を閉じる |
| 閉じるキーを 0.4 秒以上長押し | F23 | `Alt + F4`：ウィンドウを閉じる（キーを離した時） |

アプリ別のタブ数判定はしない。短押しはアプリの `Ctrl + W` の動作に任せるため、最後のタブでウィンドウが閉じないアプリでは長押しする。

アクティブなウィンドウを、配置先のモニターのタスクバーを除いた領域に配置する。複数モニターではウィンドウが最も大きく重なるモニターを使用する。

RDP 全画面中にこれらのキーが手元PCと接続先のどちらに届くかは、RDP側の設定・実機で別途確認する。

## アンインストール

```powershell
.\uninstall.ps1
```

現在の `window.ahk` を停止し、自動起動のショートカットを削除する。**AutoHotkey 本体とリポジトリは削除しない**。他の AutoHotkey スクリプトも停止しない。何度実行してもよい。

AutoHotkey 本体も不要なら、明示的に指定する。PowerToys は通常の `uninstall.ps1` では削除しない。

```powershell
.\uninstall.ps1 -RemoveAutoHotkey
```

PowerToys も同時に削除する場合:

```powershell
.\uninstall.ps1 -RemovePowerToys
```

両方のソフトを削除する場合は `-RemoveAutoHotkey -RemovePowerToys` を指定する。いずれもソフト本体の削除は明示的な指定が必要。他の用途で使っている場合は削除しないこと。リポジトリ自体は手動で削除する。
