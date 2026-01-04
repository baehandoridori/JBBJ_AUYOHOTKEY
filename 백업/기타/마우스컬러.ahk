#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1

; 전역 변수
global isActive := true
global magnifierPID := 0

; GUI 생성
Gui, +AlwaysOnTop
Gui, Add, Text, x12 y19 w240 h20 +Center, 컬러 피커 for JBBJ
Gui, Add, Text, x12 y39 w160 h20 vColorCode, 색상 코드 :
Gui, Add, CheckBox, x172 y39 w90 h20 vMagnifierCheck gToggleMagnifier, 돋보기 기능
Gui, Font, S12 CDefault, Verdana
Gui, Add, Text, x92 y59 w90 h20, 컬러 내역
Gui, Font, S8 CDefault, Verdana
Gui, Add, Edit, x12 y79 w140 h160 vColorHistory ReadOnly VScroll
Gui, Add, Progress, x162 y79 w100 h90 vColorSample -Smooth, 100
; 버튼용 폰트 설정
Gui, Font, S8, Verdana

Gui, Add, Button, x12 y339 w70 h30 gPauseResume vPauseResumeBtn, 일시정지
Gui, Add, Button, x102 y339 w70 h30 gClearHistory, 내역 초기화
Gui, Add, Button, x192 y339 w70 h30 gExitApp, 종료

Gui, Show, x903 y605 h380 w277, 컬러 피커 for JBBJ

; 메인 루프
SetTimer, UpdateColorInfo, 50
return

UpdateColorInfo:
if (!isActive)
    return

MouseGetPos, mouseX, mouseY
PixelGetColor, color, %mouseX%, %mouseY%, RGB
colorCode := SubStr(color, 3)  ; 0x 제거
GuiControl,, ColorCode, 색상 코드 : #%colorCode%
UpdateColorSample(colorCode)

; 툴팁 업데이트
tooltipText := "#" . colorCode . "`n"
tooltipText .= GenerateColorSample(colorCode)
ToolTip, %tooltipText%, mouseX + 10, mouseY + 10

return

UpdateColorSample(colorCode) {
    GuiControl, +c%colorCode%, ColorSample
    GuiControl,, ColorSample, 100
}

GenerateColorSample(colorCode) {
    sampleText := ""
    Loop, 3 {
        sampleText .= "■■■■■`n"
    }
    return sampleText
}

; 마우스 클릭 이벤트 (색상 복사 및 일시정지)
#If isActive
LButton::
MouseGetPos, clickX, clickY
PixelGetColor, color, %clickX%, %clickY%, RGB
colorCode := SubStr(color, 3)  ; 0x 제거
Clipboard := "#" . colorCode
AddColorToHistory(colorCode)
UpdateColorSample(colorCode)
SetTimer, UpdateColorInfo, Off
isActive := false
GuiControl,, PauseResumeBtn, 재개
ToolTip  ; 툴팁 제거
return
#If

PauseResume:
if (isActive) {
    SetTimer, UpdateColorInfo, Off
    isActive := false
    GuiControl,, PauseResumeBtn, 재개
    ToolTip  ; 툴팁 제거
} else {
    SetTimer, UpdateColorInfo, 50
    isActive := true
    GuiControl,, PauseResumeBtn, 일시정지
}
return

ClearHistory:
GuiControl,, ColorHistory
return

ToggleMagnifier:
Gui, Submit, NoHide
if (MagnifierCheck) {
    Run, G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\돋보기.ahk,, UseErrorLevel, magnifierPID
    if (ErrorLevel) {
        MsgBox, 돋보기 스크립트를 실행할 수 없습니다.
        GuiControl,, MagnifierCheck, 0
    }
} else {
    if (magnifierPID) {
        Process, Close, %magnifierPID%
        magnifierPID := 0
    }
}
return

AddColorToHistory(colorCode) {
    GuiControlGet, currentHistory,, ColorHistory
    newHistory := "#" . colorCode . "`n" . currentHistory
    GuiControl,, ColorHistory, %newHistory%
}

GuiClose:
ExitApp:
if (magnifierPID) {
    Process, Close, %magnifierPID%
}
ToolTip  ; 툴팁 제거
ExitApp