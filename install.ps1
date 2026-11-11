$ErrorActionPreference = 'Stop'

# 旧版の AutoHotkey によるウィンドウ配置を停止し、自動起動を解除する。
# AutoHotkey 本体はアンインストールしない。
& (Join-Path $PSScriptRoot 'uninstall.ps1')

# ウィンドウ配置は ZMK から Windows 標準ショートカットを直接送る。
# PowerToys が未導入の場合だけインストールする。
& (Join-Path $PSScriptRoot 'powertoys.ps1') -Action Install
