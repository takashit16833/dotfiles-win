; Hyper+U sends Ctrl+Alt+Win+U from a keyboard or ZMK.
; Open the currently selected URL in Edge without permanently replacing clipboard data.
^!#u::OpenClipboardUrlInEdge()

OpenClipboardUrlInEdge() {
    ; Let the Hyper shortcut keys go before sending Ctrl+C.
    ; Otherwise Ctrl+Alt+Win+C may reach the focused application.
    for key in ["u", "Ctrl", "Alt", "LWin", "RWin"] {
        if !KeyWait(key, "T1")
            return
    }

    ; ClipboardAll preserves text, images and other clipboard formats.
    ; Only the newly copied selection is used; stale clipboard URLs are ignored.
    savedClipboard := ClipboardAll()
    url := ""
    try {
        A_Clipboard := ""
        Send("^c")
        if ClipWait(0.8)
            url := Trim(A_Clipboard, " `t`r`n")
    } finally {
        A_Clipboard := savedClipboard
    }

    ; Only accept a single HTTP(S) URL with a non-empty host.
    ; In particular, quotes, whitespace and backslashes cannot become arguments.
    if !RegExMatch(url, 'i)^https?://[^/\s?#"<>\\]+(?:[/?#][^\s"<>\\]*)?\z')
        return

    edge := FindEdgeExecutable()
    if (edge = "") {
        TrayTip("Microsoft Edge executable was not found.", "Open URL", 3)
        return
    }
    try Run('"' edge '" "' url '"')
    catch as err
        TrayTip(err.Message, "Could not open URL in Edge", 3)
}

FindEdgeExecutable() {
    for root in ["HKCU", "HKLM"] {
        try {
            path := RegRead(root "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe")
            if FileExist(path)
                return path
        }
    }

    candidates := [A_ProgramFiles "\Microsoft\Edge\Application\msedge.exe"]
    programFilesX86 := EnvGet("ProgramFiles(x86)")
    if (programFilesX86 != "")
        candidates.Push(programFilesX86 "\Microsoft\Edge\Application\msedge.exe")
    for path in candidates {
        if FileExist(path)
            return path
    }
    return ""
}
)
        return

    edge := FindEdgeExecutable()
    if (edge = "") {
        TrayTip("Microsoft Edge executable was not found.", "Open URL", 3)
        return
    }
    try Run('"' edge '" "' url '"')
    catch as err
        TrayTip(err.Message, "Could not open URL in Edge", 3)
}

FindEdgeExecutable() {
    for root in ["HKCU", "HKLM"] {
        try {
            path := RegRead(root "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe")
            if FileExist(path)
                return path
        }
    }

    candidates := [A_ProgramFiles "\Microsoft\Edge\Application\msedge.exe"]
    programFilesX86 := EnvGet("ProgramFiles(x86)")
    if (programFilesX86 != "")
        candidates.Push(programFilesX86 "\Microsoft\Edge\Application\msedge.exe")
    for path in candidates {
        if FileExist(path)
            return path
    }
    return ""
}
