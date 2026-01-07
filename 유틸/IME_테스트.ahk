; =================================================================================================
; IME 감지 테스트 스크립트
; - 현재 PC가 이전 버전 IME인지 새 IME인지 확인
; - 마우스를 움직이면 툴팁에 IME 상태 표시
; =================================================================================================

#Persistent
#NoEnv
#SingleInstance, Force
CoordMode, ToolTip, Screen

; 0.5초마다 IME 상태 체크
SetTimer, CheckIME, 500
return

CheckIME:
    WinGet, hWnd, ID, A
    DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", Uint, hWnd, Uint)

    if (DefaultIMEWnd = 0) {
        imeType := "새 IME (Windows 11 기본)"
        imeStatus := "감지 불가"
        canWork := "❌ 자동 한영전환 작동 안 함"
    } else {
        imeType := "이전 버전 IME"

        ; IME 상태 확인
        DetectHiddenWindows, ON
        SendMessage, 0x283, 0x005, 0,, ahk_id %DefaultIMEWnd%
        imeRet := ErrorLevel
        DetectHiddenWindows, OFF

        if (imeRet = 0)
            imeStatus := "영문 (English)"
        else
            imeStatus := "한글 (Korean)"

        canWork := "✓ 자동 한영전환 작동 가능"
    }

    ; 툴팁 표시
    tooltipText := "═══ IME 감지 테스트 ═══`n"
    tooltipText .= "`n[IME 타입]`n" . imeType
    tooltipText .= "`n`n[IME 윈도우 핸들]`n" . DefaultIMEWnd
    tooltipText .= "`n`n[현재 한/영 상태]`n" . imeStatus
    tooltipText .= "`n`n[자동 한영전환]`n" . canWork
    tooltipText .= "`n`n─────────────────`n"
    tooltipText .= "ESC 키로 종료"

    ToolTip, %tooltipText%, 100, 100
return

Esc::
    ToolTip
    ExitApp
return
