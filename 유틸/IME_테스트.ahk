; =================================================================================================
; IME Test Script
; =================================================================================================

#Persistent
#NoEnv
#SingleInstance, Force
CoordMode, ToolTip, Screen

SetTimer, CheckIME, 500
return

CheckIME:
    WinGet, hWnd, ID, A
    DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", Uint, hWnd, Uint)

    if (DefaultIMEWnd = 0) {
        imeType := "New IME (Win11)"
        imeStatus := "Cannot detect"
        canWork := "X - Auto switch NOT working"
    } else {
        imeType := "Old IME (Compatible)"

        DetectHiddenWindows, ON
        SendMessage, 0x283, 0x005, 0,, ahk_id %DefaultIMEWnd%
        imeRet := ErrorLevel
        DetectHiddenWindows, OFF

        if (imeRet = 0)
            imeStatus := "English"
        else
            imeStatus := "Korean"

        canWork := "O - Auto switch WORKING"
    }

    tooltipText := "=== IME Detection Test ===`n"
    tooltipText .= "`n[IME Type]`n" . imeType
    tooltipText .= "`n`n[IME Window Handle]`n" . DefaultIMEWnd
    tooltipText .= "`n`n[Current Status]`n" . imeStatus
    tooltipText .= "`n`n[Auto Switch]`n" . canWork
    tooltipText .= "`n`n-----------------`n"
    tooltipText .= "Press ESC to exit"

    ToolTip, %tooltipText%, 100, 100
return

Esc::
    ToolTip
    ExitApp
return
