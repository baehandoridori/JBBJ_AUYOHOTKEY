; =================================================================================================
; IME Test Script v3 - Find Registry Path
; =================================================================================================

#Persistent
#NoEnv
#SingleInstance, Force
CoordMode, ToolTip, Screen

; Try to find IME registry path
regPaths := []
regPaths.Push("HKEY_CURRENT_USER\Software\Microsoft\Input\Settings")
regPaths.Push("HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\CHS")
regPaths.Push("HKEY_CURRENT_USER\Software\Microsoft\IME\15.0\IMEKR")
regPaths.Push("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Input\Locales\ko-KR")

regKeys := []
regKeys.Push("IsLegacyKoreanIMEEnabled")
regKeys.Push("EnableOldMsiIme")
regKeys.Push("UseCompatibleMode")
regKeys.Push("UseLegacyIME")

foundPath := ""
foundKey := ""
foundValue := ""

; Search all combinations
for i, path in regPaths {
    for j, key in regKeys {
        RegRead, val, %path%, %key%
        if (!ErrorLevel) {
            foundPath := path
            foundKey := key
            foundValue := val
            break 2
        }
    }
}

SetTimer, CheckIME, 500
return

CheckIME:
    ; ImmGetDefaultIMEWnd check
    WinGet, hWnd, ID, A
    DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", Uint, hWnd, Uint)

    currentLang := "N/A"
    if (DefaultIMEWnd != 0) {
        DetectHiddenWindows, ON
        SendMessage, 0x283, 0x005, 0,, ahk_id %DefaultIMEWnd%
        imeRet := ErrorLevel
        DetectHiddenWindows, OFF

        if (imeRet = 0)
            currentLang := "English"
        else
            currentLang := "Korean"
    }

    tooltipText := "=== IME Test v3 ===`n"

    if (foundPath != "") {
        tooltipText .= "`n[Registry Found!]`n" . foundKey . " = " . foundValue
        tooltipText .= "`n`nPath: " . foundPath
    } else {
        tooltipText .= "`n[Registry]`nNot found (searched 16 paths)"
    }

    tooltipText .= "`n`n[IME Handle]`n" . DefaultIMEWnd
    tooltipText .= "`n`n[Current Lang]`n" . currentLang
    tooltipText .= "`n`n-----------------"
    tooltipText .= "`nR = Search Registry"
    tooltipText .= "`nESC = Exit"

    ToolTip, %tooltipText%, 100, 100
return

r::
    ; Open regedit to search manually
    Run, regedit
    MsgBox, Search for: IsLegacyKoreanIMEEnabled`nor: UseLegacyIME`n`nPath usually contains "Input" or "IME"
return

Esc::
    ToolTip
    ExitApp
return
