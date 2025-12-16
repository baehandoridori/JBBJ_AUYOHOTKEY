#Persistent  ; 스크립트를 계속 실행 상태로 유지
#NoEnv  ; 성능과 호환성을 위해 권장
SetWorkingDir %A_ScriptDir%  ; 스크립트의 작업 디렉토리를 스크립트 파일의 위치로 설정
CoordMode, Mouse, Screen  ; 마우스 좌표를 스크린 기준으로 설정
SetBatchLines, -1  ; 스크립트 실행 속도를 최대화

; 전역 변수 선언
global debugWindowVisible := false  ; 디버그 창 표시 여부
global lastX := 0  ; 마지막 마우스 X 좌표
global lastY := 0  ; 마지막 마우스 Y 좌표
global lastCapsPress := 0  ; 마지막 CapsLock 키 누름 시간

; 트레이 아이콘 생성 및 설정
Menu, Tray, NoStandard
Menu, Tray, Add, 메인 창 열기, ShowMainGUI
Menu, Tray, Add, 종료, ExitScript
Menu, Tray, Default, 메인 창 열기
Menu, Tray, Icon, Shell32.dll, 283  ; 트레이 아이콘 설정

; 메인 GUI 생성
Gui, Main:New, +Resize
Gui, Main:Font, s12
Gui, Main:Add, Text, x10 y10 w380, JBBJ 작업도우미

Gui, Main:Font, s10
Gui, Main:Add, Button, x10 y+10 w180 h40 gInitialSetup, 초기 사용자 설정
Gui, Main:Add, Button, x+10 w180 h40 gShowSupportedPrograms, 지원 프로그램 목록

Gui, Main:Add, Button, x10 y+10 w180 h40 gShowFortune, 오늘의 운세
Gui, Main:Add, Button, x+10 w180 h40 gPlaySnakeGame, 스네이크 게임

Gui, Main:Add, Button, x10 y+10 w180 h40 gPlayMinesweeper, 지뢰찾기
Gui, Main:Add, Button, x+10 w180 h40 gToggleDebugWindow, 디버그 창 토글

Gui, Main:Add, Button, x10 y+20 w380 h40 gShowFeedbackWindow, 피드백 전송

Gui, Main:Show, w400 h300, JBBJ 작업도우미

; 디버그 창 생성
Gui, Debug:New, +AlwaysOnTop +Resize
Gui, Add, Text, vDebugText w300 h200
Gui, Show, w320 h220, Debug Info
Gui, Debug:Hide

; 디버그 창 토글 함수
ToggleDebugWindow() {
    global debugWindowVisible
    if (debugWindowVisible) {
        Gui, Debug:Hide
        debugWindowVisible := false
    } else {
        Gui, Debug:Show, w320 h220, Debug Info
        debugWindowVisible := true
    }
}



; 한영 전환 기능 초기화
SetTimer, Check, 20  ; 20ms 간격으로 Check 라벨 실행


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
            } else if WinActive("ahk_class AE_CApplication_24.5") {
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
    GuiControl,, DebugText, %debugText%
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

; 핫키 설정
^Enter::
NumpadEnter::
    ret := IME_CHECK("A")
    if (ret != 0) {
        if WinActive("ahk_class 742DEA58-ED6B-4402-BC11-20DFC6D08040") 
        or WinActive("ahk_class Photoshop") 
        or WinActive("ahk_class Premiere Pro") {
            Send, {%A_ThisHotkey%}
            Send, {vk15sc138}
            UpdateDebug(A_ThisHotkey . " 처리", ret, "전환됨")
        } else {
            Send, {%A_ThisHotkey%}
            UpdateDebug(A_ThisHotkey . " 처리", ret, "전환 안됨")
        }
    } else {
        Send, {%A_ThisHotkey%}
        UpdateDebug(A_ThisHotkey . " 처리", ret, "이미 영어 상태")
    }
return




; 초기 사용자 설정 확인
CheckInitialSetup()

return

; 서브루틴 및 함수 정의
ShowMainGUI:
    Gui, Main:Show
return

; 초기 사용자 설정 실행 함수
InitialSetup:
    PerformInitialSetup()
return

; 지원 프로그램 목록 표시 함수
ShowSupportedPrograms:
    ShowSupportedProgramsList()
return

ShowFortune:
    MsgBox, 오늘의 운세 기능은 아직 구현되지 않았습니다.
return

PlaySnakeGame:
    Run, G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\스네이크게임.ahk
return

PlayMinesweeper:
    MsgBox, 지뢰찾기 게임 기능은 아직 구현되지 않았습니다.
return


; 피드백 창 실행 함수
ShowFeedbackWindow:
    Run, G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\피드백.ahk
return



; 초기 사용자 설정 기능
CheckInitialSetup() {
    if (!FileExist("config.ini")) {
        MsgBox, 4, 초기 설정, 초기 설정이 필요합니다. 지금 설정하시겠습니까?
        IfMsgBox, Yes
        {
            PerformInitialSetup()
        }
    }
}

; 초기 설정 실행 함수
PerformInitialSetup() {
    MsgBox, 4, IME 설정 안내, 간편한 한/영 전환 사용을 위해 설정을 시작할까요?`n(최초 실행 시 동작 수행 권장)
    IfMsgBox, Yes
    {
        Gui, Main:+Disabled
        MsgBox, 1, 설정 진행, 스크립트 사용을 위한 설정 변경을 진행합니다.`n동작 수행 동안 키보드 및 마우스를 조작하지 말아주세요.
        IfMsgBox, OK
        {
            Run, ms-settings:regionlanguage
            WinWait, 설정
            if WinExist("설정")
            {
                WinActivate
                Sleep, 2000
                Send, {Tab 3}
                Sleep, 500
                Send, {Enter 2}
                Sleep, 1000
                Send, {Tab 10}
                Sleep, 1000
                Send, {Space 2}
                Sleep, 1000
                
                MsgBox, 3, 설정 확인, 이전 버전의 Microsoft IME 사용 옵션이 '켬'으로 표기되나요?
                IfMsgBox, Yes
                {
                    MsgBox, 0, 설정 완료, 자동 한영전환 스크립트 사용 준비를 마쳤습니다! 작업 화이팅~
                    IniWrite, 1, config.ini, Settings, InitialSetupComplete
                }
                else IfMsgBox, No
                {
                    MsgBox, 0, 설정 실패, 설정에 실패했습니다. 다시 시도해 주세요.
                    PerformInitialSetup()
                }
            }
            else
            {
                MsgBox, 0, 오류, 설정 창을 열 수 없습니다. 수동으로 설정을 변경해주세요.
            }
        }
        Gui, Main:-Disabled
    }
}

; 지원 프로그램 목록 표시 함수
ShowSupportedProgramsList() {
    supportedPrograms := "지원 프로그램 목록`n`nAdobe After Effect (2024)`nAdobe Animate (2024)`nAdobe Premiere pro (2024)`nAdobe Photoshop (2024)`nMoho 14`nClip studio`n`n별도의 프로그램 지원 원하시면 빨간바지한테 말해주세요"
    MsgBox, %supportedPrograms%
}

; 스크립트 종료 함수
ExitScript:
    ExitApp
return

; GUI 닫기 처리
GuiClose:
GuiEscape:
    Gui, Hide
return

; 특수 키 처리
CapsLock::
    currentTime := A_TickCount
    if (currentTime - lastCapsPress < 300)
    {
        KeyWait, CapsLock
        ClipSaved := ClipboardAll
        Send, ^c
        ClipWait, 1
        folderPath := Clipboard
        Run, explorer %folderPath%
        Clipboard := ClipSaved
        ClipSaved := ""
    }
    else
    {
        KeyWait, CapsLock
        if GetKeyState("CapsLock", "T")
            SetCapsLockState, Off
        else
            SetCapsLockState, On
    }
    lastCapsPress := currentTime
return


return