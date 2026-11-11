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

配置は Windows 標準の `Win + 矢印` を使用する。ZMK の Windows 用 `layer_15` も同じキーを直接送るため、RDP 内で AutoHotkey を必要としない。

| 物理操作 | 送信キー | 動作 |
| --- | --- | --- |
| Hyper + I | Win + ← | 左 1/2 |
| Hyper + - | Win + → | 右 1/2 |
| Hyper + A | Win + ↑ | 最大化 |
| Hyper + O | Win + ↓ | 復元／最小化 |

最大化・復元は従来のトグルではなく別々の操作。1/3・2/3 配置は廃止。
Windows 用 `layer_14` の閉じるキーも `Ctrl + W` を直接送る。

仮想デスクトップの切り替え `Hyper + C / V` は ZMK 側で引き続き利用できる。

## PowerToys

```powershell
.\powertoys.ps1 -Action Install
.\powertoys.ps1 -Action Uninstall
```

PowerToys の設定（Command Palette や Bookmarks）は管理していない。

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
