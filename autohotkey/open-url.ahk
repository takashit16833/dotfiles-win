; Hyper+U sends Ctrl+Alt+Win+U from a keyboard or ZMK.
; Clipboard is read-only: no Ctrl+C is sent and previous clipboard data is kept.
^!#u::OpenClipboardUrlInEdge()

OpenClipboardUrlInEdge() {
    url := Trim(A_Clipboard, " `t`r`n")
    ; Only accept a single HTTP(S) URL with a non-empty host.
    ; In particular, quotes, whitespace and backslashes cannot become arguments.
    if !RegExMatch(url, 'i)^https?://[^/\s?#"<>\\]+(?:[/?#][^\s"<>\\]*)?$')
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
