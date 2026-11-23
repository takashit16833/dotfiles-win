; Window placement matching dotfiles/.hammerspoon/init.lua (AutoHotkey v2).
; Hyper on Windows means Ctrl + Alt + Win.
; Wide screen threshold uses Windows work-area coordinates (2400 units).

maximizedWindowFrames := Map()

; F19-F22 can also be sent by custom keyboard firmware.
F19::PlaceActiveWindow("left")
F20::PlaceActiveWindow("center")
F21::PlaceActiveWindow("right")
+F19::PlaceActiveWindow("left", 2 / 3)
+F21::PlaceActiveWindow("right", 2 / 3)
F22::ToggleActiveMaximize()

; Hammerspoon-equivalent window keys.
^!#i::PlaceActiveWindow("left")
^!#o::PlaceActiveWindow("center")
^!#SC00C::PlaceActiveWindow("right") ; Physical minus key (JP/US).
^!#+i::PlaceActiveWindow("left", 2 / 3)
^!#+SC00C::PlaceActiveWindow("right", 2 / 3)
^!#a::ToggleActiveMaximize()
^!#Tab::MoveActiveWindowToMonitor(1)
^!#+Tab::MoveActiveWindowToMonitor(-1)

PlaceActiveWindow(position, requestedFraction := 0) {
    global maximizedWindowFrames

    hwnd := WinExist("A")
    if !hwnd
        return

    area := WorkAreaForWindow(hwnd)
    if !area
        return

    win := "ahk_id " hwnd
    if WinGetMinMax(win) != 0
        WinRestore(win)

    screenWidth := area.right - area.left
    screenHeight := area.bottom - area.top

    if position = "center" {
        fraction := 1 / 3
        start := 1 / 3
    } else {
        ; Mac: >=2400 points uses thirds; narrower screens use halves.
        fraction := requestedFraction ? requestedFraction : (screenWidth >= 2400 ? 1 / 3 : 1 / 2)
        start := position = "right" ? 1 - fraction : 0
    }

    x1 := area.left + Floor(screenWidth * start)
    x2 := area.left + Floor(screenWidth * (start + fraction))
    WinMove(x1, area.top, x2 - x1, screenHeight, win)

    ; An explicit placement supersedes the remembered maximize/restore state.
    if maximizedWindowFrames.Has(hwnd)
        maximizedWindowFrames.Delete(hwnd)
}

ToggleActiveMaximize() {
    global maximizedWindowFrames

    hwnd := WinExist("A")
    if !hwnd
        return
    win := "ahk_id " hwnd

    if maximizedWindowFrames.Has(hwnd) && WinGetMinMax(win) = 1 {
        saved := maximizedWindowFrames[hwnd]
        WinGetPos(&x, &y, &w, &h, win)
        if FramesNearlyEqual({x: x, y: y, w: w, h: h}, saved.maximized) {
            WinRestore(win)
            WinMove(saved.original.x, saved.original.y,
                saved.original.w, saved.original.h, win)
            maximizedWindowFrames.Delete(hwnd)
            return
        }
    }

    if WinGetMinMax(win) != 0
        WinRestore(win)

    WinGetPos(&x, &y, &w, &h, win)
    original := {x: x, y: y, w: w, h: h}
    WinMaximize(win)
    WinGetPos(&mx, &my, &mw, &mh, win)
    maximizedWindowFrames[hwnd] := {
        original: original,
        maximized: {x: mx, y: my, w: mw, h: mh}
    }
}

FramesNearlyEqual(a, b) {
    return Abs(a.x - b.x) <= 5
        && Abs(a.y - b.y) <= 5
        && Abs(a.w - b.w) <= 5
        && Abs(a.h - b.h) <= 5
}

MoveActiveWindowToMonitor(direction) {
    global maximizedWindowFrames

    count := MonitorGetCount()
    if count < 2
        return

    hwnd := WinExist("A")
    if !hwnd
        return
    win := "ahk_id " hwnd

    WinGetPos(&x, &y, &w, &h, win)
    currentIndex := MonitorIndexForRect(x, y, w, h)
    if !currentIndex
        return

    targetIndex := Mod(currentIndex - 1 + direction + count, count) + 1
    MonitorGetWorkArea(currentIndex, &oldL, &oldT, &oldR, &oldB)
    MonitorGetWorkArea(targetIndex, &newL, &newT, &newR, &newB)

    wasMaximized := WinGetMinMax(win) = 1
    if WinGetMinMax(win) != 0
        WinRestore(win)

    ; Relative position and size are retained across differently sized screens.
    WinGetPos(&x, &y, &w, &h, win)
    oldW := oldR - oldL
    oldH := oldB - oldT
    newW := newR - newL
    newH := newB - newT
    if oldW <= 0 || oldH <= 0
        return

    WinMove(
        newL + Round((x - oldL) * newW / oldW),
        newT + Round((y - oldT) * newH / oldH),
        Round(w * newW / oldW),
        Round(h * newH / oldH),
        win
    )

    if wasMaximized
        WinMaximize(win)

    if maximizedWindowFrames.Has(hwnd)
        maximizedWindowFrames.Delete(hwnd)
}

MonitorIndexForRect(x, y, w, h) {
    bestIndex := 0
    bestOverlap := 0
    Loop MonitorGetCount() {
        MonitorGet(A_Index, &l, &t, &r, &b)
        overlapWidth := Max(0, Min(x + w, r) - Max(x, l))
        overlapHeight := Max(0, Min(y + h, b) - Max(y, t))
        overlap := overlapWidth * overlapHeight
        if overlap > bestOverlap {
            bestOverlap := overlap
            bestIndex := A_Index
        }
    }
    return bestIndex
}

WorkAreaForWindow(hwnd) {
    ; MONITOR_DEFAULTTONEAREST = 2.
    monitor := DllCall("User32\MonitorFromWindow", "ptr", hwnd, "uint", 2, "ptr")
    if !monitor
        return false

    ; MONITORINFO is 40 bytes: size, monitor rect, work rect, flags.
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
