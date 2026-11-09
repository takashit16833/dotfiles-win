#Requires AutoHotkey v2.0
#SingleInstance Force

; ZMK の Windows 用 layer_15 から受け取る。
F19::MoveToThirds(0, 1)   ; 左 1/3
F20::MoveToThirds(1, 1)   ; 中央 1/3
F21::MoveToThirds(2, 1)   ; 右 1/3
+F19::MoveToThirds(0, 2)  ; 左 2/3
+F21::MoveToThirds(1, 2)  ; 右 2/3
F22::ToggleMaximize()    ; 最大化／元に戻す

; Windows 用 layer_14: 短押しはタブ、長押し（0.4秒以上）はウィンドウを閉じる。
F23::
{
    if KeyWait("F23", "T0.4") {
        Send "^w"
    } else {
        KeyWait "F23"
        Send "!{F4}"
    }
}

MoveToThirds(startThird, spanThirds) {
    hwnd := WinExist("A")
    if !hwnd
        return

    try {
        target := "ahk_id " hwnd
        WinGetPos &x, &y, &width, &height, target
        monitor := MonitorForWindow(x, y, width, height)
        MonitorGetWorkArea monitor, &left, &top, &right, &bottom

        ; 最大化中のウィンドウは、サイズ変更前に元に戻す。
        if WinGetMinMax(target) != 0
            WinRestore target

        workWidth := right - left
        newLeft := left + Round(workWidth * startThird / 3)
        newRight := left + Round(workWidth * (startThird + spanThirds) / 3)
        WinMove newLeft, top, newRight - newLeft, bottom - top, target
    } catch Error as err {
        TrayTip err.Message, "Window placement", "Iconx"
    }
}

; ウィンドウが最も大きく重なるモニターを使う。
MonitorForWindow(x, y, width, height) {
    selected := MonitorGetPrimary()
    largestArea := 0

    Loop MonitorGetCount() {
        MonitorGet A_Index, &left, &top, &right, &bottom
        overlapWidth := Max(0, Min(x + width, right) - Max(x, left))
        overlapHeight := Max(0, Min(y + height, bottom) - Max(y, top))
        area := overlapWidth * overlapHeight

        if area > largestArea {
            largestArea := area
            selected := A_Index
        }
    }
    return selected
}

ToggleMaximize() {
    hwnd := WinExist("A")
    if !hwnd
        return

    try {
        target := "ahk_id " hwnd
        if WinGetMinMax(target) = 1
            WinRestore target
        else
            WinMaximize target
    } catch Error as err {
        TrayTip err.Message, "Window placement", "Iconx"
    }
}
