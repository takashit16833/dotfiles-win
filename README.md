# dotfiles-win

Windows 11 用の個人設定。

## セットアップ

会社PCでは、AutoHotkey と `winget` の利用が許可されていることを確認する。

```powershell
git clone https://github.com/takashit16833/dotfiles-win.git
cd dotfiles-win
.\install.ps1
```

`install.ps1` は、標準のインストール先に AutoHotkey v2 がなければ `winget` で現在のユーザーに導入し、`autohotkey/window.ahk` を起動する。現在のユーザーのスタートアップにショートカットを登録して、次回ログイン時からも起動する。

**再実行可能**。AutoHotkey が既に標準の場所にあればインストールを省略し、ショートカットを上書きし、実行中の同じスクリプトを置き換える。標準以外の場所に導入した AutoHotkey は検出対象外。

リポジトリは移動せず、同じ場所で使う（自動起動のショートカットがファイルを直接参照するため）。

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

アクティブなウィンドウを、配置先のモニターのタスクバーを除いた領域に配置する。複数モニターではウィンドウが最も大きく重なるモニターを使用する。

RDP 全画面中にこれらのキーが手元PCと接続先のどちらに届くかは、RDP側の設定・実機で別途確認する。

## アンインストール

```powershell
.\uninstall.ps1
```

現在の `window.ahk` を停止し、自動起動のショートカットを削除する。**AutoHotkey 本体とリポジトリは削除しない**。他の AutoHotkey スクリプトも停止しない。何度実行してもよい。

現在のユーザーに導入した AutoHotkey 本体も不要なら、明示的に指定する。

```powershell
.\uninstall.ps1 -RemoveAutoHotkey
```

本体を削除すると、他の用途で使っている AutoHotkey スクリプトも動かなくなるため注意する。削除対象は標準のユーザー用インストール先の AutoHotkey に限る。リポジトリ自体は必要に応じて手動で削除する。
