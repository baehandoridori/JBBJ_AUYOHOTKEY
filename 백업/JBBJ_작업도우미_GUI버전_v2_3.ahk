#Persistent
#NoEnv
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
SetBatchLines, -1





; 전역 변수 선언
global lastX := 0
global lastY := 0
global lastCapsPress := 0
global alwaysOnTopWindow := ""

; 트레이 아이콘 설정
Menu, Tray, NoStandard
Menu, Tray, Add, 메인 창 열기, ShowMainGUI
Menu, Tray, Add, 종료, ExitScript
Menu, Tray, Default, 메인 창 열기
Menu, Tray, Icon, Shell32.dll, 283

; GUI 생성
Gui, Font, S14 CDefault, Verdana
Gui, Add, Text, x152 y9 w160 h20 , JBBJ 작업 마법사
Gui, Font, S10 CDefault, Verdana
Gui, Add, Text, x12 y49 w340 h20 , 여러분의 작업의 편의성을 위해 제작한 JBBJ 작업 마법사입니다.
Gui, Add, Text, x12 y29 w70 h20 , 안녕하세요.

Gui, Font, S12 CDefault, Verdana
Gui, Add, GroupBox, x12 y69 w330 h190 , 기본 기능

Gui, Font, S8 CDefault, Verdana
Gui, Add, Text, x22 y119 w310 h50 , 자동으로 한/영 전환 명령을 내려`, 단축키를 입력할 때 한글로 입력되는 경우를 방지하여 작업 효율과 집중도를 높입니다. 지원 프로그램 목록을 참고해주세요.
Gui, Add, Text, x22 y199 w310 h50 , 파일 경로를 탐색기에 직접 붙여넣기 할 필요 없습니다`. 경로 선택 후 Caps Lock 키를 두번 누르면 해당 경로가 파일 탐색기에 열립니다. 파일 경로를 Ctrl + C 로 복사한 후 Caps lock 키를 두 번 눌러도 됩니다.
Gui, Font, S13 Cgreen Bold, Verdana
Gui, Add, Text, x22 y89 w110 h30 , 자동 한/영전환
Gui, Add, Text, x22 y169 w150 h30 , 파일 경로 쉽게열기

Gui, Font, S8 norm, Verdana
Gui, Add, Button, x132 y89 w80 h30 gInitialSetup, 초기 설정
Gui, Add, Button, x212 y89 w120 h30 gShowSupportedPrograms, 지원 프로그램 목록
Gui, Add, CheckBox, x352 y69 w90 h30 , CheckBox
Gui, Add, Button, x12 y589 w140 h40 gShowFeedbackWindow, 피드백 전송
Gui, Add, Button, x302 y589 w140 h40 gGuiClose, 창 닫기
Gui, Add, Button, x12 y269 w130 h40 gLaunchSVGConverter, SVG변환기
Gui, Add, GroupBox, x12 y369 w140 h210 , 딴짓하기
Gui, Add, Button, x22 y399 w120 h50 gPlaySnakeGame, 딴짓하기
Gui, Add, Button, x22 y459 w120 h50 gMenuchcun, 저녁메뉴 추천
Gui, Add, Button, x22 y519 w120 h50 gShowFortune, 오늘의 운세
Gui, Add, Button, x162 y269 w130 h40 gLaunchColorPicker, 컬러 픽커
Gui, Add, Button, x12 y319 w90 h40 , 연차관리
Gui, Add, Button, x232 y319 w90 h40 , 컷넘버 기재
Gui, Add, Button, x332 y319 w90 h40 , 개발중
Gui, Add, Button, x312 y269 w130 h40 , 개발중

Gui, Font, S10 norm, Verdana

Gui, Add, Progress, x162 y549 w280 h30 , 87
Gui, Add, Button, x352 y119 w90 h30 gLaunchDebugMode, 디버그 모드
Gui, Add, Button, x352 y159 w90 h30 , 사용설명서
Gui, Add, MonthCal, x182 y369 w230 h170 , 

Gui, Font, S8 CGRAY Italic, Verdana
Gui, Add, Text, x182 y629 w260 h20 +Right, Powered by__Bae

Gui, Font, S10, Verdana
Gui, Add, Button, x112 y319 w110 h40 , 익명으로 칭찬하기


Gui, Font, S7 Cgray, Verdana
Gui, Add, Text, x400 y39 w90 h30 , ver_0_2
; 메인 GUI 표시
Gui, Show, x572 y418 h664 w456, JBBJ 작업 마법사

; 한영 전환 기능 초기화
SetTimer, Check, 100
return

; 서브루틴 및 함수 정의
ShowMainGUI:
    Gui, Show
return

InitialSetup:
    PerformInitialSetup()
return

ShowSupportedPrograms:
    ShowSupportedProgramsList()
return

LaunchColorPicker:
    Run, G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\마우스컬러.ahk
return

Menuchcun:
    run, G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\저녁메뉴추천.ahk
Return


LaunchSVGConverter:
    Run, G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\05_svg\svg변환기\SVG_변환기_JBBJ.ahk
return

PlaySnakeGame:
    Run, G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\스네이크게임.ahk
return

ShowFortune:
    Run, G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\오늘의운세.ahk
return

ShowFeedbackWindow:
    Run, G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\피드백.ahk
return

LaunchDebugMode:
    Run, G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\디버그.ahk
return

; 한영 전환 기능
Check:
    MouseGetPos, cx, cy
    if (cx != lastX or cy != lastY) {
        ret := IME_CHECK("A")
        if (ret != 0) {  ; IME가 한글 상태일 때만 전환
            if WinActive("ahk_class 742DEA58-ED6B-4402-BC11-20DFC6D08040") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class Photoshop") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class Premiere Pro") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class LM_Wnd") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_24.5") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_24.4") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_24.3") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_24.7") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_24.6") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_24.7") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_24.8") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_25.0") {
                Send, {vk15sc138}                
            } else if WinActive("ahk_class AE_CApplication_25.1") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_25.2") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_25.3") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_25.4") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_25.5") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_25.6") {
                Send, {vk15sc138}
            } else if WinActive("ahk_class AE_CApplication_25.7") {
                Send, {vk15sc138}                
            } else if WinActive("ahk_class Adobe Animate 2024"){
                Send, {vk15sc138}
            }
        }
        lastX := cx
        lastY := cy
    }
return

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
        Gui, +Disabled
        MsgBox, 1, 설정 진행, 스크립트 사용을 위한 설정 변경을 진행합니다.`n동작 수행 동안 키보드 및 마우스를 조작하지 말아주세요.
        IfMsgBox, OK
        {
            Run, ms-settings:regionlanguage
            WinWait, 설정
            if WinExist("설정")
            {
                WinActivate
                Sleep, 3000  ; 설정 창이 완전히 로드될 때까지 대기 시간 증가
                
                ; 전체 키 입력 지연 설정
                SetKeyDelay, 100, 50
                
                Send, {Tab 3}
                Sleep, 2000

                ; Enter 입력 별도 처리
                Loop, 2 {
                    sendinput, {Enter}
                    sleep, 500
                    WinGetActiveStats, Title, Width, Height, X, Y
                    ToolTip, Enter %A_Index% sent, Width/2, % Height/2
                    sleep, 200
                    ToolTip,
                }
                
                ; Tab 입력을 개별적으로 처리
                Loop, 11 {
                    SendInput, {Tab}
                    Sleep, 500
                    WinGetActiveStats, Title, Width, Height, X, Y
                    ToolTip, Tab %A_Index% sent, % Width/2, % Height/2
                    Sleep, 200
                    ToolTip
                }
                
                Sleep, 500
                Loop, 2 {
                    sendinput, {Space}
                    sleep, 500
                    WinGetActiveStats, Title, Width, Height, X, Y
                    ToolTip, Space %A_Index% sent, Width/2, % Height/2
                    sleep, 200
                    ToolTip,
                }
                Sleep, 1000
                
                Loop, 7 {
                    SendInput, {Tab}
                    Sleep, 500
                    WinGetActiveStats, Title, Width, Height, X, Y
                    ToolTip, Tab %A_Index% sent, % Width/2, % Height/2
                    Sleep, 200
                    ToolTip
                }
                Loop, 2 {
                    sendinput, {Space}
                    sleep, 500
                    WinGetActiveStats, Title, Width, Height, X, Y
                    ToolTip, Space %A_Index% sent, Width/2, % Height/2
                    sleep, 200
                    ToolTip,
                }
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
        Gui, -Disabled
    }
}

; 지원 프로그램 목록 표시 함수
ShowSupportedProgramsList() {
    supportedPrograms := "지원 프로그램 목록`n`nAdobe After Effect (2024)`nAdobe After Effect (2025)`nAdobe Animate (2024)`nAdobe Premiere pro (2024)`nAdobe Premiere pro (2025)`nAdobe Photoshop (2024)`nMoho 14`nClip studio`n`n별도의 프로그램 지원 원하시면 빨간바지한테 말해주세요"
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
        
        ; 클립보드 저장
        ClipSaved := ClipboardAll
        
        ; 클립보드 비우고 복사 시도
        Clipboard := ""
        Send, ^c
        ClipWait, 0.5
        
        if !ErrorLevel
        {
            ; 클립보드 내용을 가져와서 정리
            folderPath := Clipboard
            folderPath := Trim(folderPath)  ; 앞뒤 공백 제거
            folderPath := RegExReplace(folderPath, "`r`n$")  ; 줄바꿈 제거
            folderPath := RegExReplace(folderPath, "`n$")    ; 라인피드 제거
            
            if FileExist(folderPath)
            {
                Run, explorer %folderPath%
            }
            else
            {
                MsgBox, 경로가 유효하지 않습니다: [%folderPath%]  ; 대괄호로 감싸서 보이지 않는 문자 확인 가능
            }
        }
        
        ; 클립보드 복원
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


; 창을 항상 위에 고정하는 기능 
!`::
    WinGet, activeWindow, ID, A
    if (alwaysOnTopWindow = activeWindow)
    {
        WinSet, AlwaysOnTop, Off, ahk_id %activeWindow%
        alwaysOnTopWindow := ""
    }
    else
    {
        if (alwaysOnTopWindow != "")
        {
            WinSet, AlwaysOnTop, Off, ahk_id %alwaysOnTopWindow%
        }
        WinSet, AlwaysOnTop, On, ahk_id %activeWindow%
        alwaysOnTopWindow := activeWindow
    }
return



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
        } else {
            Send, {%A_ThisHotkey%}
        }
    } else {
        Send, {%A_ThisHotkey%}
    }
return