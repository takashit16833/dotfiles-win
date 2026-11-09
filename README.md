# dotfiles-win

Windows 11 用の個人設定。

## セットアップ

会社PCでは、AutoHotkey と `winget` の利用が許可されていることを確認する。

```powershell
git clone https://github.com/takashit16833/dotfiles-win.git
cd dotfiles-win
.\install.ps1
```

`install.ps1` は AutoHotkey v2 を `winget` で導入し、`autohotkey/window.ahk` を起動する。また、現在のユーザーのスタートアップにショートカットを作り、次回ログイン時から自動起動する。設定変更後は `install.ps1` を再実行するか、常駐中のスクリプトを再読み込みする。

リポジトリは移動せず、同じ場所で使う（自動起動のショートカットがファイルを直接参照するため）。

## ウィンドウ配置

ZMK の Windows 用 `layer_15` から、次のキーを送信する想定。**ZMK 側への割り当ては別途必要**。

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

## 自動起動を解除

`Win + R` → `shell:startup` で `dotfiles-win-window.lnk` を削除する。すぐ停止したい場合は通知領域の AutoHotkey アイコンから終了する。
