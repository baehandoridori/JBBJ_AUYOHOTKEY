#Persistent
#NoEnv
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
SetBatchLines, -1

; -------------------------
; 전역 변수 (타임 트래커)
; -------------------------
global totalUsage := 0
global lastCheck := A_TickCount
global lastActiveProcess := ""
global usageTimes := {}        ; 프로세스별 사용시간

; -------------------------
; 별칭 매핑 딕셔너리 (alias.ini에서 로드)
; -------------------------
global processAliases := {}

; ----------------------------------------------------
; 트레이 아이콘 설정
; ----------------------------------------------------
Menu, Tray, NoStandard
Menu, Tray, Add, 메인 창 열기, ShowMainGUI
Menu, Tray, Add, 종료, ExitScript
Menu, Tray, Default, 메인 창 열기
Menu, Tray, Icon, Shell32.dll, 283

; ----------------------------------------------------
; GUI 생성
; ----------------------------------------------------
Gui, Font, S14 CDefault, Verdana
Gui, Add, Text, x152 y9 w160 h20 , JBBJ 작업 마법사
Gui, Font, S10 CDefault, Verdana
Gui, Add, Text, x12 y49 w340 h20 , 여러분의 작업 편의성을 위해 제작한 JBBJ 작업 마법사입니다.
Gui, Add, Text, x12 y29 w70 h20 , 안녕하세요.

Gui, Font, S12 CDefault, Verdana
Gui, Add, GroupBox, x12 y69 w330 h190 , 기본 기능

Gui, Font, S8 CDefault, Verdana
Gui, Add, Text, x22 y119 w310 h50 , 자동으로 한/영 전환 명령을 내려`n작업 효율을 높입니다.
Gui, Add, Text, x22 y199 w310 h50 , CapsLock 두 번으로 탐색기 열기 가능!
Gui, Font, S13 Cgreen Bold, Verdana
Gui, Add, Text, x22 y89 w110 h30 , 자동 한/영전환
Gui, Add, Text, x22 y169 w150 h30 , 파일 경로 쉽게열기

Gui, Font, S8 norm, Verdana
Gui, Add, Button, x132 y89 w80 h30 , 초기 설정
Gui, Add, Button, x212 y89 w120 h30 , 지원 프로그램 목록
Gui, Add, CheckBox, x352 y69 w90 h30 , CheckBox

Gui, Font, cRed
Gui, Add, CheckBox, x352 y99 w150 h30 vFileShareChecked Checked , 파일공유_JBBJ
Gui, Font

Gui, Add, Button, x12 y589 w140 h40 , 피드백 전송
Gui, Add, Button, x302 y589 w140 h40 gGuiClose, 창 닫기
Gui, Add, Button, x12 y269 w130 h40 , SVG변환기
Gui, Add, GroupBox, x12 y369 w140 h210 , 딴짓하기
Gui, Add, Button, x22 y399 w120 h50 , 딴짓하기
Gui, Add, Button, x22 y459 w120 h50 , 저녁메뉴 추천
Gui, Add, Button, x22 y519 w120 h50 , 오늘의 운세
Gui, Add, Button, x162 y269 w130 h40 , 컬러 픽커
Gui, Add, Button, x12 y319 w90 h40 , 연차관리
Gui, Add, Button, x232 y319 w110 h40 , 컷넘버 기재
Gui, Add, Button, x332 y319 w110 h40 , 개발중
Gui, Add, Button, x312 y269 w130 h40 , 개발중

Gui, Font, S8 CGRAY Italic, Verdana
Gui, Add, Text, x182 y629 w260 h20 +Right, Powered by__Bae

Gui, Font, S10, Verdana
Gui, Add, Button, x112 y319 w110 h40 , 익명으로 칭찬하기

Gui, Font, S7 Cgray, Verdana
Gui, Add, Text, x400 y39 w90 h30 , ver_0_2

; ----------------------------------------------------
; 오늘 작업 시간 (Progress + Label + 상위 4프로그램)
; ----------------------------------------------------
Gui, Add, GroupBox, x162 y369 w280 h140 , 오늘 작업 시간
Gui, Add, Progress, x172 y399 w260 h20 vTimeTrackerProgress Range0-28800
Gui, Add, Text,     x172 y425 w260 h20 vTimeTrackerLabel, 0:00:00 / 8:00:00
Gui, Add, Text,     x172 y445 w260 h60 vTopProgramLabel

Gui, Show, w456 h664, JBBJ 작업 마법사

; ----------------------------------------------------
; (1) 별칭 로드: alias.ini 파일에서 processAliases 딕셔너리 구성
; ----------------------------------------------------
LoadAliases()

; ----------------------------------------------------
; (2) 1초마다 작업 시간 누적 & 순위 표시
; ----------------------------------------------------
SetTimer, TrackTime, 1000
return

ShowMainGUI:
    Gui, Show
return

GuiClose:
GuiEscape:
    Gui, Hide
return

; ----------------------------------------------------
; 타임 트래커 (1초 간격)
; ----------------------------------------------------
TrackTime:
global totalUsage, lastCheck, lastActiveProcess, usageTimes
{
    currentTick := A_TickCount
    diff := currentTick - lastCheck
    lastCheck := currentTick
    if (diff < 0)
        return

    deltaSec := diff / 1000.0

    ; 1) 직전 활성 프로세스 시간 누적
    if (lastActiveProcess != "")
    {
        if (!usageTimes.HasKey(lastActiveProcess))
            usageTimes[lastActiveProcess] := 0
        usageTimes[lastActiveProcess] += deltaSec
    }

    ; 2) 현재 활성 프로세스 파악
    WinGet, currentHwnd, ID, A
    WinGet, currentProcess, ProcessName, ahk_id %currentHwnd%
    if (currentProcess = "")
        currentProcess := "UnknownProcess"

    ; .exe 확장자 제거, 대소문자 변환 (ex: "Chrome.exe" -> "chrome")
    currentProcess := RegExReplace(currentProcess, "\.exe$", "", 1)
    StringLower, currentProcess, currentProcess

    lastActiveProcess := currentProcess

    ; 3) 전체 사용 시간 증가
    totalUsage += deltaSec
    if (totalUsage > 28800)
        totalUsage := 28800

    ; 4) ProgressBar 업데이트
    GuiControl,, TimeTrackerProgress, % Floor(totalUsage)

    ; 5) "HH:MM:SS / 8:00:00" 표시
    formatted := FormatSeconds(totalUsage) " / 8:00:00"
    GuiControl,, TimeTrackerLabel, % formatted

    ; 6) 상위 4개 추출 (사용 시간 많은 순)
    top4 := GetTopN(usageTimes, 4)

    displayText := ""
    loop, % top4.Count()
    {
        idx := A_Index
        item := top4[idx]
        
        ; 별칭 치환
        realName := GetAliasOrName(item.proc)
        displayText .= idx "위: " realName " - " FormatSeconds(item.time) "`n"
    }
    GuiControl,, TopProgramLabel, % displayText
}
return

; ----------------------------------------------------
; 상위 N개 프로그램 추출 (사용 시간이 많은 순)
; ----------------------------------------------------
GetTopN(usageMap, N) {
    arr := []
    for proc, sec in usageMap {
        arr.Push({ "proc": proc, "time": sec })
    }

    ; [중요] Sort 대신 직접 "가장 큰 time"부터 가져오는 selection 방식
    result := []
    Loop, % N {
        maxIndex := 0
        maxTime := -1
        ; arr 에서 time이 가장 큰 항목 찾기
        for i, obj in arr {
            if (obj.time > maxTime) {
                maxTime := obj.time
                maxIndex := i
            }
        }
        if (maxIndex = 0)
            break  ; 더 이상 데이터가 없음

        result.Push(arr[maxIndex])
        arr.RemoveAt(maxIndex)
    }
    return result
}

; ----------------------------------------------------
; 별칭 치환
; ----------------------------------------------------
GetAliasOrName(procKey) {
    global processAliases
    if (processAliases.HasKey(procKey)) {
        return processAliases[procKey]
    } else {
        return procKey
    }
}

; ----------------------------------------------------
; 초 -> HH:MM:SS
; ----------------------------------------------------
FormatSeconds(sec) {
    h := Floor(sec / 3600)
    m := Floor(Mod(sec, 3600) / 60)
    s := Floor(Mod(sec, 60))
    return Format("{:02}:{:02}:{:02}", h, m, s)
}

; ----------------------------------------------------
; alias.ini 로드: [Alias] 섹션에서 key=value 읽어오기
; ----------------------------------------------------
LoadAliases() {
    global processAliases

    aliasFile := A_ScriptDir "\alias.ini"
    if !FileExist(aliasFile) {
        MsgBox, 48, 알림, alias.ini 파일이 없습니다. 기본 alias만 사용합니다.
        ; 필요 시 processAliases에 기본값
        processAliases["chrome"]    := "크롬"
        processAliases["explorer"]  := "파일 탐색기"
        processAliases["afterfx"]   := "애프터이펙트"
        processAliases["photoshop"] := "포토샵"
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
}

ExitScript:
    ExitApp
return
