#Requires AutoHotkey v2.0
#SingleInstance Force

; Japanese keyboard: physical @ key (scan code 01A).
!sc01A::CycleAppWindows()

CycleAppWindows() {
    static orderByExe := Map()

    active := WinExist("A")
    if !active
        return

    try exe := WinGetProcessName("ahk_id " active)
    catch
        return

    windows := []
    for hwnd in WinGetList("ahk_exe " exe) {
        if !DllCall("IsWindowVisible", "ptr", hwnd, "int")
            continue
        if WinGetTitle("ahk_id " hwnd) = ""
            continue
        windows.Push(hwnd)
    }
    if windows.Length < 2
        return

    ; Preserve the order across activations (WinGetList uses changing Z-order).
    if orderByExe.Has(exe) {
        previous := orderByExe[exe]
        same := previous.Length = windows.Length
        if same {
            for hwnd in previous {
                if !HasWindow(windows, hwnd) {
                    same := false
                    break
                }
            }
        }
        if same
            windows := previous
    }
    orderByExe[exe] := windows

    for index, hwnd in windows {
        if hwnd = active {
            next := Mod(index, windows.Length) + 1
            WinActivate("ahk_id " windows[next])
            return
        }
    }
}

HasWindow(windows, target) {
    for hwnd in windows {
        if hwnd = target
            return true
    }
    return false
}
