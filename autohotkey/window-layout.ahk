; Window placement for the currently active window (AutoHotkey v2).
; F19/F20/F21/F22 are suitable for custom keyboard firmware.
; Ctrl+Alt+Win+I/O/-/A are also available without firmware remapping.

; 1/3: left, center, right.
F19::TileActiveWindow(0, 1)
F20::TileActiveWindow(1, 1)
F21::TileActiveWindow(2, 1)

; 2/3: left and right.
+F19::TileActiveWindow(0, 2)
+F21::TileActiveWindow(1, 2)

; Maximize / restore.
F22::ToggleActiveMaximize()

; Windows Hyper (Ctrl + Alt + Win) equivalents.
^!#i::TileActiveWindow(0, 1)
^!#o::TileActiveWindow(1, 1)
^!#SC00C::TileActiveWindow(2, 1) ; Physical minus key on JP/US layouts.
^!#+i::TileActiveWindow(0, 2)
^!#+SC00C::TileActiveWindow(1, 2)
^!#a::ToggleActiveMaximize()

TileActiveWindow(firstThird, thirdCount) {
    hwnd := WinExist("A")
    if !hwnd
        return

    ; Select the monitor containing most of the window, even with multiple monitors.
    area := WorkAreaForWindow(hwnd)
    if !area
        return

    win := "ahk_id " hwnd
    if WinGetMinMax(win) != 0
        WinRestore(win)

    screenWidth := area.right - area.left
    x1 := area.left + Floor(screenWidth * firstThird / 3)
    x2 := area.left + Floor(screenWidth * (firstThird + thirdCount) / 3)
    WinMove(x1, area.top, x2 - x1, area.bottom - area.top, win)
}

ToggleActiveMaximize() {
    hwnd := WinExist("A")
    if !hwnd
        return

    win := "ahk_id " hwnd
    if WinGetMinMax(win) = 1
        WinRestore(win)
    else
        WinMaximize(win)
}

WorkAreaForWindow(hwnd) {
    ; MONITOR_DEFAULTTONEAREST = 2.
    monitor := DllCall("User32\MonitorFromWindow", "ptr", hwnd, "uint", 2, "ptr")
    if !monitor
        return false

    ; MONITORINFO: cbSize (4) + rcMonitor (16) + rcWork (16) + flags (4).
    info := Buffer(40, 0)
    NumPut("uint", 40, info, 0)
    if !DllCall("User32\GetMonitorInfoW", "ptr", monitor, "ptr", info, "int")
        return false

    return {
        left: NumGet(info, 20, "int"),
        top: NumGet(info, 24, "int"),
        right: NumGet(info, 28, "int"),
        bottom: NumGet(info, 32, "int")
    }
}
