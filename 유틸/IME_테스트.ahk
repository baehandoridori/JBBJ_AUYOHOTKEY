; =================================================================================================
; IME Test Script v2 - Registry Check
; =================================================================================================

#Persistent
#NoEnv
#SingleInstance, Force
CoordMode, ToolTip, Screen

SetTimer, CheckIME, 500
return

CheckIME:
    ; Registry check for "Use old IME" setting
    ; Windows 11 Korean IME setting location
    RegRead, useOldIME, HKEY_CURRENT_USER\Software\Microsoft\Input\Settings, IsLegacyKoreanIMEEnabled

    if (ErrorLevel) {
        ; Try another registry path
        RegRead, useOldIME, HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\CHS, EnableOldMsiIme
    }

    if (ErrorLevel) {
        regStatus := "Registry not found"
        isOldIME := "Unknown"
    } else {
        regStatus := "Value: " . useOldIME
        if (useOldIME = 1)
            isOldIME := "OLD IME (Enabled)"
        else
            isOldIME := "NEW IME (Disabled)"
    }

    ; Also check ImmGetDefaultIMEWnd
    WinGet, hWnd, ID, A
    DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", Uint, hWnd, Uint)

    if (DefaultIMEWnd = 0) {
        immStatus := "0 (No handle)"
    } else {
        immStatus := DefaultIMEWnd . " (Has handle)"

        ; Check current Korean/English status
        DetectHiddenWindows, ON
        SendMessage, 0x283, 0x005, 0,, ahk_id %DefaultIMEWnd%
        imeRet := ErrorLevel
        DetectHiddenWindows, OFF

        if (imeRet = 0)
            currentLang := "English"
        else
            currentLang := "Korean"
    }

    tooltipText := "=== IME Test v2 ===`n"
    tooltipText .= "`n[Registry Check]`n" . regStatus
    tooltipText .= "`n`n[Old IME Setting]`n" . isOldIME
    tooltipText .= "`n`n[ImmGetDefaultIMEWnd]`n" . immStatus
    tooltipText .= "`n`n[Current Lang]`n" . currentLang
    tooltipText .= "`n`n-----------------`n"
    tooltipText .= "ESC to exit"

    ToolTip, %tooltipText%, 100, 100
return

Esc::
    ToolTip
    ExitApp
return
