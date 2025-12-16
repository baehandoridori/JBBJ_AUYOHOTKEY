#Persistent
#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen

; 전역 변수 선언
global lastX := 0
global lastY := 0

; 디버그 창 생성
Gui, Debug:New, +AlwaysOnTop +Resize +OwnDialogs
Gui, Debug:Add, Text, vDebugText w300 h200
Gui, Debug:Add, Button, gExitDebug w300, 디버그 종료
Gui, Debug:Show, w320 h250, Debug Info

; 한영 전환 기능 초기화
SetTimer, Check, 20

; 메인 루프
return

; 한영 전환 기능
Check:
    MouseGetPos, cx, cy
    if (cx != lastX or cy != lastY) {
        ret := IME_CHECK("A")
        if (ret != 0) {  ; IME가 한글 상태일 때만 전환
            if WinActive("ahk_class 742DEA58-ED6B-4402-BC11-20DFC6D08040") {
                Send, {vk15sc138}
                UpdateDebug("클립스튜디오", ret, "전환됨")
            } else if WinActive("ahk_class Photoshop") {
                Send, {vk15sc138}
                UpdateDebug("포토샵", ret, "전환됨")
            } else if WinActive("ahk_class Premiere Pro") {
                Send, {vk15sc138}
                UpdateDebug("프리미어 프로", ret, "전환됨")
            } else if WinActive("ahk_class LM_Wnd") {
                Send, {vk15sc138}
                UpdateDebug("모호 애니메이션", ret, "전환됨")
            } else if WinActive("ahk_class AE_CApplication_25.0") {
                Send, {vk15sc138}
                UpdateDebug("어도비 애니메이트", ret, "전환됨")
            } else if WinActive("ahk_class AE_CApplication_24.4") {
                Send, {vk15sc138}
                UpdateDebug("어도비 애니메이트", ret, "전환됨")
            } else if WinActive("ahk_class AE_CApplication_24.3") {
                Send, {vk15sc138}
                UpdateDebug("어도비 애니메이트", ret, "전환됨")
            } else if WinActive("ahk_class AE_CApplication_24.7") {
                Send, {vk15sc138}
                UpdateDebug("어도비 애니메이트", ret, "전환됨")
            } else if WinActive("ahk_class AE_CApplication_24.6") {
                Send, {vk15sc138}
                UpdateDebug("애프터 이펙트", ret, "전환됨")
            } else if WinActive("ahk_class AE_CApplication_24.7") {
                Send, {vk15sc138}
                UpdateDebug("어도비 애니메이트", ret, "전환됨")
            } else if WinActive("ahk_class AE_CApplication_24.8") {
                Send, {vk15sc138}
                UpdateDebug("어도비 애니메이트", ret, "전환됨")
            } else if WinActive("ahk_class Adobe Animate 2024"){
                Send, {vk15sc138}
                UpdateDebug("어도비 애니메이트", ret, "전환됨")
            } else {
                UpdateDebug("대상 프로그램 아님", ret, "전환 안됨")
            }
        } else {
            UpdateDebug("이미 영어 상태", ret, "유지됨")
        }
        lastX := cx
        lastY := cy
    }
return

; 디버그 정보 업데이트 함수
UpdateDebug(program, imeState, action) {
    WinGetActiveTitle, activeWindow
    WinGetClass, activeClass, A
    debugText := "Active Window: " . activeWindow . "`n"
    debugText .= "Active Class: ahk_class " . activeClass . "`n"
    debugText .= "Detected Program: " . program . "`n"
    debugText .= "IME State: " . (imeState ? "한글" : "영어") . "`n"
    debugText .= "Action: " . action
    GuiControl, Debug:, DebugText, %debugText%
}

; IME 상태 확인 함수
IME_CHECK(WinTitle) {
    WinGet, hWnd, ID, %WinTitle%
    Return Send_ImeControl(ImmGetDefaultIMEWnd(hWnd), 0x005, "")
}

; IME 제어 함수
Send_ImeControl(DefaultIMEWnd, wParam, lParam) {
    DetectSave := A_DetectHiddenWindows
    DetectHiddenWindows, ON
    SendMessage 0x283, wParam, lParam,, ahk_id %DefaultIMEWnd%
    if (DetectSave <> A_DetectHiddenWindows)
        DetectHiddenWindows, %DetectSave%
    return ErrorLevel
}

; IME 윈도우 핸들 가져오기 함수
ImmGetDefaultIMEWnd(hWnd) {
    return DllCall("imm32\ImmGetDefaultIMEWnd", Uint, hWnd, Uint)
}

; 디버그 종료 함수
ExitDebug:
    ExitApp
return

; GUI 닫기 처리
GuiClose:
GuiEscape:
    ExitApp
return