#Persistent
#NoEnv
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
SetBatchLines, -1

; =============================================================================
; [ 전역 변수 선언 - 메인 기능용 + 타임 트래커용 ]
; =============================================================================

; --- 메인 스크립트용 전역 ---
global lastX := 0
global lastY := 0
global lastCapsPress := 0
global alwaysOnTopWindow := ""
global fileSharePID := 0  ; 파일공유_JBBJ 체크박스용 PID 관리

; --- 추가: 옵션 토글을 위한 전역 체크박스 상태
global checkAutoIME := 1         ; 자동 한영전환 토글 (기본 On)
global checkEasyOpen := 1        ; 경로 쉽게열기 토글 (기본 On)
global checkAlwaysOnTop := 1     ; alwaysOnTop 토글 (기본 On)

; --- 타임 트래커(ProgressBar)용 전역 ---
global totalUsage := 0           ; 전체 누적 사용 시간(초)
global lastCheck := A_TickCount  ; 마지막 체크 시각(밀리초)
global lastActiveProcess := ""   ; 직전에 활성화되었던 프로세스
global usageTimes := {}          ; 프로세스별 사용 시간 (딕셔너리)

; --- 별칭 매핑 딕셔너리 ---
global processAliases := {}      ; alias.ini에서 key=value를 읽어와 저장

; =============================================================================
; [트레이 아이콘 설정] - 메인 스크립트 로직 유지
; =============================================================================
Menu, Tray, NoStandard
Menu, Tray, Add, 메인 창 열기, ShowMainGUI
Menu, Tray, Add, 종료, ExitScript
Menu, Tray, Default, 메인 창 열기
Menu, Tray, Icon, Shell32.dll, 283

; =============================================================================
; [GUI 생성 - 메인]
; =============================================================================
Gui, Font, S14 CDefault, Verdana
Gui, Add, Text, x152 y9 w160 h20 , JBBJ 작업 마법사
Gui, Font, S10 CDefault, Verdana
Gui, Add, Text, x12 y49 w340 h20 , 여러분의 작업의 편의성을 위해 제작한 JBBJ 작업 마법사입니다.
Gui, Add, Text, x12 y29 w70 h20 , 안녕하세요.

Gui, Font, S12 CDefault, Verdana
Gui, Add, GroupBox, x12 y69 w330 h190 , 기본 기능

Gui, Font, S8 CDefault, Verdana
Gui, Add, Text, x22 y119 w310 h50 , 단축키를 입력할 때 한글로 입력되는 경우를 방지해 줍니다. 지원 프로그램 목록을 참고해주세요.
Gui, Add, Text, x22 y199 w310 h50 , 경로 선택 후 Caps Lock 키를 두번 누르면 해당 경로가 파일 탐색기에 열립니다. 파일 경로를 Ctrl + C 로 복사한 후 Caps lock 키를 두 번 눌러도 됩니다.
Gui, Font, S13 Cgreen Bold, Verdana
Gui, Add, Text, x22 y89 w110 h30 , 자동 한/영전환
Gui, Add, Text, x22 y169 w150 h30 , 파일 경로 쉽게열기

Gui, Font, S8 norm, Verdana
Gui, Add, Button, x132 y89 w80 h30 gInitialSetup, 초기 설정
Gui, Add, Button, x212 y89 w120 h30 gShowSupportedPrograms, 지원 프로그램 목록
Gui, Add, CheckBox, x352 y69 w90 h30 , CheckBox

; 파일공유_JBBJ 체크박스 추가 (붉은색, 기본 체크)
Gui, Font, cRed
Gui, Add, CheckBox, x352 y99 w150 h30 vFileShareChecked Checked gFileShareToggle, 파일공유_JBBJ
Gui, Font

; ------------------------------------------------------------------------------
; ★ 추가: 3개의 체크박스 (글자색 초록, 기본 체크) ★
;           자동 한영전환 / 경로 쉽게열기 / alwaysOnTop 토글
;           모두 gOptionToggle 레이블을 연결해, 상태 바뀔 때 반영
; ------------------------------------------------------------------------------
Gui, Font, cGreen               ; 글자색 초록
Gui, Add, CheckBox, x352 y129 w150 h20 vCheckAutoIME   Checked gOptionToggle, 자동 한영전환
Gui, Add, CheckBox, x352 y149 w150 h20 vCheckEasyOpen  Checked gOptionToggle, 경로 쉽게열기
Gui, Add, CheckBox, x352 y169 w150 h20 vCheckAlwaysOnTop Checked gOptionToggle, AlwaysOnTop
Gui, Font

; ------------------------------------------------------------------------------
Gui, Add, Button, x12 y589 w140 h40 gShowFeedbackWindow, 피드백 전송
Gui, Add, Button, x302 y589 w140 h40 gGuiClose, 창 닫기
Gui, Add, Button, x12 y269 w130 h40 gLaunchSVGConverter, SVG변환기
Gui, Add, GroupBox, x12 y369 w140 h210 , 딴짓하기
Gui, Add, Button, x22 y399 w120 h50 gPlaySnakeGame, 딴짓하기
Gui, Add, Button, x22 y459 w120 h50 gMenuchcun, 저녁메뉴 추천
Gui, Add, Button, x22 y519 w120 h50 gShowFortune, 오늘의 운세
Gui, Add, Button, x162 y269 w130 h40 gLaunchColorPicker, 컬러 픽커
Gui, Add, Button, x12 y319 w90 h40 , 연차관리
Gui, Add, Button, x232 y319 w90 h40 gCutnumberinsert, 컷넘버 기재
Gui, Add, Button, x332 y319 w110 h40 gOpenUserGuide, 사용설명서
Gui, Add, Button, x312 y269 w130 h40 , 개발중

Gui, Font, S10, Verdana
Gui, Add, Button, x112 y319 w110 h40 gAnonymous_praise , 익명으로 칭찬하기

Gui, Font, S8 CGRAY Italic, Verdana
Gui, Add, Text, x182 y629 w260 h20 +Right, Powered by__Bae



Gui, Font, S7 Cgray, Verdana
Gui, Add, Text, x400 y39 w90 h30 , ver_0_2

; =============================================================================
; [GUI 추가: 오늘 작업 시간 (Progress + Label + 상위 4프로그램)]
;    - 타임 트래커를 위한 그룹박스/컨트롤
;    - x162 y369 w280 h140 (딴짓하기 오른쪽 영역)
; =============================================================================
Gui, Add, GroupBox, x162 y369 w280 h140 , 오늘 작업 시간
Gui, Add, Progress, x172 y389 w260 h20 vTimeTrackerProgress Range0-28800
Gui, Add, Text,     x172 y415 w260 h20 vTimeTrackerLabel, 0:00:00 / 8:00:00
Gui, Add, Text,     x172 y435 w260 h60 vTopProgramLabel

; 메인 GUI 표시
Gui, Show, x572 y418 h664 w456, JBBJ 작업 마법사
Gui, Submit, NoHide

; 체크박스 상태에 따라 파일공유_JBBJ 스크립트 실행
if (FileShareChecked = 1) {
    Run, "%A_AhkPath%" "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\경로공유_최종.ahk",, fileSharePID
}

; =============================================================================
; [한영 전환 기능 초기화] - 기존 메인 스크립트
; =============================================================================
SetTimer, Check, 100  ; 0.1초 간격

; =============================================================================
; (1) 별칭 로드: alias.ini (ANSI 저장 권장)
; =============================================================================
LoadAliases()

; =============================================================================
; (2) 1초마다 작업 시간 누적 & 상위 4개 표시
; =============================================================================
SetTimer, TrackTime, 1000
return

; -----------------------------------------------------------------------------
;  [ 체크박스 변경 시 - OptionToggle 라벨 ]
;   - 체크박스 상태를 Gui -> 전역 변수로 반영
; -----------------------------------------------------------------------------
OptionToggle:
Gui, Submit, NoHide
return


; -----------------------------------------------------------------------------
;                           [ 메인 스크립트 서브루틴들 ]
; -----------------------------------------------------------------------------

ShowMainGUI:
    Gui, Show
return

Anonymous_praise:
    Run, G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\익명_칭찬합시다.ahk
return

InitialSetup:
    PerformInitialSetup()
return

OpenUserGuide:
    ; 사용설명서 링크(슬랙 캔버스) 열기
    Run, https://studio-jbbj.slack.com/docs/T03HKE9MNCV/F086ZGRSBB4
return

ShowSupportedPrograms:
    ShowSupportedProgramsList()
return

Cutnumberinsert:
    Run,  G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\컷넘버입력기.ahk
Return


LaunchColorPicker:
    Run, G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\마우스컬러_V1_4.ahk
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

; -----------------------------------------------------------------------------
; [ 한영 전환 기능 ]
; -----------------------------------------------------------------------------
Check:
    ; << 자동 한영전환이 꺼져있다면(CheckAutoIME=0), 아래 로직 스킵 >>
    if (checkAutoIME != 1)
        return

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

IME_CHECK(WinTitle) {
    WinGet, hWnd, ID, %WinTitle%
    Return Send_ImeControl(ImmGetDefaultIMEWnd(hWnd), 0x005, "")
}

Send_ImeControl(DefaultIMEWnd, wParam, lParam) {
    DetectSave := A_DetectHiddenWindows
    DetectHiddenWindows, ON
    SendMessage 0x283, wParam, lParam,, ahk_id %DefaultIMEWnd%
    if (DetectSave <> A_DetectHiddenWindows)
        DetectHiddenWindows, %DetectSave%
    return ErrorLevel
}

ImmGetDefaultIMEWnd(hWnd) {
    return DllCall("imm32\ImmGetDefaultIMEWnd", Uint, hWnd, Uint)
}

; -----------------------------------------------------------------------------
; [초기 사용자 설정 기능] - 기존 유지
; -----------------------------------------------------------------------------
CheckInitialSetup() {
    if (!FileExist("config.ini")) {
        MsgBox, 4, 초기 설정, 초기 설정이 필요합니다. 지금 설정하시겠습니까?
        IfMsgBox, Yes
        {
            PerformInitialSetup()
        }
    }
}

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
                Sleep, 3000
                SetKeyDelay, 100, 50
                Send, {Tab 3}
                Sleep, 2000

                Loop, 2 {
                    sendinput, {Enter}
                    sleep, 500
                }

                Loop, 11 {
                    SendInput, {Tab}
                    Sleep, 500
                }

                Sleep, 500
                Loop, 2 {
                    sendinput, {Space}
                    sleep, 500
                }
                Sleep, 1000

                Loop, 7 {
                    SendInput, {Tab}
                    Sleep, 500
                }
                Loop, 2 {
                    sendinput, {Space}
                    sleep, 500
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

ShowSupportedProgramsList() {
    supportedPrograms := "지원 프로그램 목록`n`nAdobe After Effect (2024)`nAdobe After Effect (2025)`nAdobe Animate (2024)`nAdobe Premiere pro (2024)`nAdobe Premiere pro (2025)`nAdobe Photoshop (2024)`nMoho 14`nClip studio`n`n별도의 프로그램 지원 원하시면 빨간바지한테 말해주세요"
    MsgBox, %supportedPrograms%
}

; -----------------------------------------------------------------------------
; [스크립트 종료 함수]
; -----------------------------------------------------------------------------
ExitScript:
    ExitApp
return

; -----------------------------------------------------------------------------
; [GUI 닫기 처리]
; -----------------------------------------------------------------------------
GuiClose:
GuiEscape:
    Gui, Hide
return

; -----------------------------------------------------------------------------
; [CapsLock 더블탭으로 경로 열기]
; -----------------------------------------------------------------------------
CapsLock::
    ; << 경로 쉽게열기가 꺼져있다면(checkEasyOpen=0), 아래 로직 스킵 >>
    if (checkEasyOpen != 1)
        return

    currentTime := A_TickCount
    if (currentTime - lastCapsPress < 300)
    {
        KeyWait, CapsLock
        ClipSaved := ClipboardAll
        Clipboard := ""
        Send, ^c
        ClipWait, 0.5

        if !ErrorLevel
        {
            folderPath := Clipboard
            folderPath := Trim(folderPath)
            folderPath := RegExReplace(folderPath, "`r`n$")
            folderPath := RegExReplace(folderPath, "`n$")

            if FileExist(folderPath)
            {
                Run, explorer %folderPath%
            }
            else
            {
                MsgBox, 경로가 유효하지 않습니다: [%folderPath%]
            }
        }
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

; -----------------------------------------------------------------------------
; [창을 항상 위에 고정하는 기능] (Alt+`)
; -----------------------------------------------------------------------------
!`::
    ; << alwaysOnTop이 꺼져있다면(checkAlwaysOnTop=0), 아래 로직 스킵 >>
    if (checkAlwaysOnTop != 1)
        return

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

; -----------------------------------------------------------------------------
; [한/영 전환 충돌 방지용 단축키]
; -----------------------------------------------------------------------------
;^Enter::
;NumpadEnter::
;    ret := IME_CHECK("A")
;    if (ret != 0) {
;        if WinActive("ahk_class 742DEA58-ED6B-4402-BC11-20DFC6D08040") 
;        or WinActive("ahk_class Photoshop") 
;        or WinActive("ahk_class Premiere Pro") {
;            Send, {%A_ThisHotkey%}
;            Send, {vk15sc138}
;        } else {
;            Send, {%A_ThisHotkey%}
;        }
;    } else {
;        Send, {%A_ThisHotkey%}
;    }
;return

; -----------------------------------------------------------------------------
; [파일공유_JBBJ 체크박스 토글 라벨]
; -----------------------------------------------------------------------------
FileShareToggle:
    Gui, Submit, NoHide
    if (FileShareChecked = 1) {
        if (fileSharePID = 0) {
            Run, "%A_AhkPath%" "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\경로공유_최종.ahk",, fileSharePID
        }
    } else {
        if (fileSharePID != 0) {
            Process, Close, %fileSharePID%
            fileSharePID := 0
        }
    }
return


; =============================================================================
;                [ 타임 트래커: TrackTime 서브루틴 & 함수들 ]
; =============================================================================

/*
 타임 트래커 기능 설명:
 - 1초마다 (SetTimer, TrackTime, 1000) 호출
 - 현재 활성 프로그램(프로세스 이름)을 파악해 사용 시간을 누적
 - usageTimes 딕셔너리에 { key=프로세스, value=누적초 }
 - 약 2분간(120초) 아무 입력이 없으면 "afk"(자리비움)으로 전환하여 시간 누적
 - 다시 움직임이 생기면 활성화된 창(프로세스) 추적 재개
 - 가장 많이 사용된 프로그램 순으로 상위 4개를 GUI에 표시
 - alias.ini 통해 "chrome=크롬" 등 별칭 치환
*/
TrackTime:
global totalUsage, lastCheck, lastActiveProcess, usageTimes
{
    currentTick := A_TickCount
    diff := currentTick - lastCheck
    lastCheck := currentTick
    if (diff < 0)
        return

    deltaSec := diff / 1000.0

    ; (A) 직전 활성 프로세스 시간 누적
    if (lastActiveProcess != "")
    {
        if (!usageTimes.HasKey(lastActiveProcess))
            usageTimes[lastActiveProcess] := 0
        usageTimes[lastActiveProcess] += deltaSec
    }

    ; (A-1) 3분(180초) 이상 아무 입력이 없으면 afk, 아니면 실제 활성 창 추적
    idleTime := A_TimeIdle
    if (idleTime >= 120000)  ; 2분 = 120,000ms
    {
        currentProcess := "afk"
    }
    else
    {
        ; (B) 현재 활성 프로세스 파악
        WinGet, currentHwnd, ID, A
        WinGet, currentProcess, ProcessName, ahk_id %currentHwnd%
        if (currentProcess = "")
            currentProcess := "UnknownProcess"
        currentProcess := RegExReplace(currentProcess, "\.exe$", "", 1)
        StringLower, currentProcess, currentProcess
    }

    lastActiveProcess := currentProcess

    ; (C) 전체 사용 시간
    totalUsage += deltaSec
    if (totalUsage > 28800)
        totalUsage := 28800  ; 8시간 초과 시 고정

    ; (D) ProgressBar 업데이트
    GuiControl,, TimeTrackerProgress, % Floor(totalUsage)

    ; (E) "HH:MM:SS / 8:00:00" 라벨
    formatted := FormatSeconds(totalUsage) " / 8:00:00"
    GuiControl,, TimeTrackerLabel, % formatted

    ; (F) 상위 4~5개(사용 시간 많은 순) 추출 후 별칭 적용
    top5 := GetTopN(usageTimes, 5)
    displayText := ""
    loop, % top5.Count()
    {
        idx := A_Index
        item := top5[idx]
        aliasName := GetAliasOrName(item.proc)
        displayText .= idx "위: " aliasName " - " FormatSeconds(item.time) "`n"
    }
    GuiControl,, TopProgramLabel, % displayText
}
return


/*
 GetTopN(usageMap, N):
  - usageMap 딕셔너리를 배열(arr)로 변환
  - time이 가장 큰 항목부터 차례로 result에 넣어
  - 결과 배열을 반환
*/
GetTopN(usageMap, N) {
    arr := []
    for proc, sec in usageMap {
        arr.Push({ "proc": proc, "time": sec })
    }

    result := []
    Loop, % N {
        maxIndex := 0
        maxTime := -1
        ; arr에서 time이 가장 큰 항목 찾기
        for i, obj in arr {
            if (obj.time > maxTime) {
                maxTime := obj.time
                maxIndex := i
            }
        }
        if (maxIndex = 0)
            break
        result.Push(arr[maxIndex])
        arr.RemoveAt(maxIndex)
    }
    return result
}

/*
 GetAliasOrName(procKey):
  - alias.ini에서 로드된 processAliases 딕셔너리에
    procKey(소문자)가 존재하면 그 별칭을,
    없으면 원본 procKey 그대로 반환
*/
GetAliasOrName(procKey) {
    global processAliases
    if (processAliases.HasKey(procKey)) {
        return processAliases[procKey]
    } else {
        return procKey
    }
}

/*
 FormatSeconds(sec):
  - 초(숫자)를 HH:MM:SS 문자열로 변환
*/
FormatSeconds(sec) {
    h := Floor(sec / 3600)
    m := Floor(Mod(sec, 3600) / 60)
    s := Floor(Mod(sec, 60))
    return Format("{:02}:{:02}:{:02}", h, m, s)
}

/*
 LoadAliases():
  - A_ScriptDir\alias.ini 파일에서 [Alias] 섹션을 읽어
    processAliases 딕셔너리에 저장
  - alias.ini가 없으면 기본값(크롬, 탐색기 등) 등록 후 종료
  - "afk" = "자리비움"도 등록
  - 한글 별칭이 깨지지 않도록 alias.ini는 ANSI 인코딩 권장
*/
LoadAliases() {
    global processAliases

    aliasFile := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\alias.ini"
    if !FileExist(aliasFile) {
        MsgBox, 48, 알림, alias.ini 파일이 없습니다. 기본 alias만 사용합니다.
        processAliases["chrome"]    := "크롬"
        processAliases["explorer"]  := "파일 탐색기"
        processAliases["afterfx"]   := "애프터이펙트"
        processAliases["photoshop"] := "포토샵"
        processAliases["clipstudiopaint"] := "클립스튜디오"
        processAliases["slack"]     := "슬랙"
        processAliases["moho"]      := "모호"
        processAliases["animate"]   := "애니메이트"
        processAliases["explorer.exe"] := "파일 탐색기"
        ; AFK(자리비움) 별칭 추가
        processAliases["afk"]       := "자리비움"
        return
    }

    content := ""
    IniRead, content, %aliasFile%, Alias
    if (ErrorLevel) {
        MsgBox, 16, 에러, alias.ini 파일에서 [Alias] 섹션을 읽을 수 없습니다.
        return
    }

    loop, parse, content, `n, `r
    {
        line := Trim(A_LoopField)
        if (line = "")
            continue

        pos := InStr(line, "=")
        if (pos) {
            k := SubStr(line, 1, pos-1)
            v := SubStr(line, pos+1)
            StringLower, k, k
            processAliases[Trim(k)] := Trim(v)
        }
    }

    ; AFK(자리비움)도 혹시 없으면 기본등록
    if (!processAliases.HasKey("afk")) {
        processAliases["afk"] := "자리비움"
    }
}