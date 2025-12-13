#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1

; 전역 변수
global isActive := true
global displayRGB := false      ; 체크박스 상태 (false=HEX, true=RGB)
global magnifierPID := 0        ; 돋보기 프로세스 PID
global colorList := []
global buttonHandles := []  ; {handle, color}

; 레이아웃 설정
GuiWidth := 800
GuiHeight := 500

GroupX := 110
GroupY := 90
GroupW := 500
GroupH := 350

MaxRows := 9
ButtonWidth := 120
ButtonHeight := 30
ButtonGap := 5
StartX := GroupX + 10
StartY := GroupY + 20

PreviewX := GroupX + GroupW + 20
PreviewY := 110
PreviewW := 150
PreviewH := 150

BottomBtnW := 100
BottomBtnH := 35
BottomGap := 10
TotalBottomWidth := BottomBtnW*3 + BottomGap*2
BottomStartX := (GuiWidth - TotalBottomWidth)/2
BottomY := 450

posX_PauseResume := BottomStartX
posX_ClearHistory := BottomStartX + BottomBtnW + BottomGap
posX_Exit := BottomStartX + BottomBtnW*2 + BottomGap*2

SetWindowText(hWnd, text) {
    return DllCall("SetWindowText", "ptr", hWnd, "str", text)
}

; 메인 GUI
Gui, +AlwaysOnTop
Gui, Add, Text, x250 y10 w240 h30 +Center, 컬러 피커 for JBBJ
Gui, Add, Text, x12 y40 w160 h30 vColorCode, 색상 코드 :
Gui, Add, CheckBox, x12 y65 w150 h30 vRGBCheck gToggleRGB, RGB 형식으로 보기

; --- 돋보기 체크박스 추가 예시 (좌표는 원하는 대로 수정) ---
Gui, Add, CheckBox, x12 y95 w80 h30 vMagnifierCheck gToggleMagnifier, 돋보기 기능
; -------------------------------------------------------------

Gui, Font, s12, Verdana
Gui, Add, GroupBox, % ("x" . GroupX . " y" . GroupY . " w" . GroupW . " h" . GroupH . " cRed"), 컬러 히스토리
Gui, Add, Progress, % ("x" . PreviewX . " y" . PreviewY . " w" . PreviewW . " h" . PreviewH . " vColorSample -Smooth"), 100
Gui, Add, Button, % ("x" . posX_PauseResume . " y" . BottomY . " w" . BottomBtnW . " h" . BottomBtnH . " gPauseResume vPauseResumeBtn"), 재개/일시정지
Gui, Add, Button, % ("x" . posX_ClearHistory . " y" . BottomY . " w" . BottomBtnW . " h" . BottomBtnH . " gClearHistory"), 내역 초기화
Gui, Add, Button, % ("x" . posX_Exit . " y" . BottomY . " w" . BottomBtnW . " h" . BottomBtnH . " gCloseApp"), 종료

Gui, Show, % ("x903 y605 h" . GuiHeight . " w" . GuiWidth), 컬러 피커 for JBBJ
SetTimer, UpdateColorInfo, 50
return

; -----------------------------------------------------------------------------
; 주 타이머 - 현재 마우스 위치의 색상 갱신
; -----------------------------------------------------------------------------
UpdateColorInfo:
if (!isActive)
    return

MouseGetPos, mouseX, mouseY
PixelGetColor, color, %mouseX%, %mouseY%, RGB
colorCode := SubStr(color, 3)

displayText := displayRGB ? HexToRGBText(colorCode) : "#" . colorCode
GuiControl,, ColorCode, % ("색상 코드 : " . displayText)
UpdateColorSample(colorCode)

ttX := mouseX + 10
ttY := mouseY + 10
tooltipText := displayText . "`n" . GenerateColorSample(colorCode)
ToolTip, %tooltipText%, %ttX%, %ttY%
return

; -----------------------------------------------------------------------------
; 색상 샘플(Progress)에 반영
; -----------------------------------------------------------------------------
UpdateColorSample(colorCode) {
    GuiControl, +c%colorCode%, ColorSample
    GuiControl,, ColorSample, 100
}

; -----------------------------------------------------------------------------
; 툴팁에 색상 블럭처럼 보이게 하기 위한 문자열 생성
; -----------------------------------------------------------------------------
GenerateColorSample(colorCode) {
    sampleText := ""
    Loop, 3 {
        sampleText .= "■■■■■`n"
    }
    return sampleText
}

; -----------------------------------------------------------------------------
; 마우스 왼쪽 클릭 시, 색상 복사 + 히스토리에 추가 + 픽킹 일시정지
; -----------------------------------------------------------------------------
#If isActive
LButton::
MouseGetPos, clickX, clickY
PixelGetColor, color, %clickX%, %clickY%, RGB
colorCode := SubStr(color, 3)
Clipboard := "#" . colorCode
AddColorToHistory(colorCode)
UpdateColorSample(colorCode)
SetTimer, UpdateColorInfo, Off
isActive := false
GuiControl,, PauseResumeBtn, 재개/일시정지
ToolTip
return
#If

; -----------------------------------------------------------------------------
; 일시정지/재개 버튼
; -----------------------------------------------------------------------------
PauseResume:
if (isActive) {
    SetTimer, UpdateColorInfo, Off
    isActive := false
    GuiControl,, PauseResumeBtn, 재개/일시정지
    ToolTip
} else {
    SetTimer, UpdateColorInfo, 50
    isActive := true
    GuiControl,, PauseResumeBtn, 재개/일시정지
}
return

; -----------------------------------------------------------------------------
; ** 스페이스바로 일시정지/재개 토글 **
; 컬러 피커 GUI가 활성화 상태일 때만 동작하도록 설정
; -----------------------------------------------------------------------------
#If WinActive("컬러 피커 for JBBJ")
Space::
    Gosub, PauseResume
return
#If

; -----------------------------------------------------------------------------
; 히스토리 초기화
; -----------------------------------------------------------------------------
ClearHistory:
Gui, Destroy
colorList := []
buttonHandles := []
Gosub, ReInitGUI
return

; GUI 재생성
ReInitGUI:
Gui, +AlwaysOnTop
Gui, Add, Text, x12 y10 w240 h30 +Center, 컬러 피커 for JBBJ
Gui, Add, Text, x12 y40 w160 h30 vColorCode, 색상 코드 :
Gui, Add, CheckBox, x12 y70 w150 h30 vRGBCheck gToggleRGB, RGB 형식으로 보기

; 돋보기 체크박스 재생성 (좌표 수정 가능)
Gui, Add, CheckBox, x12 y100 w150 h30 vMagnifierCheck gToggleMagnifier, 돋보기 기능

Gui, Font, s12, Verdana
Gui, Add, GroupBox, % ("x" . GroupX . " y" . GroupY . " w" . GroupW . " h" . GroupH . " cRed"), 컬러 히스토리
Gui, Add, Progress, % ("x" . PreviewX . " y" . PreviewY . " w" . PreviewW . " h" . PreviewH . " vColorSample -Smooth"),100
Gui, Add, Button, % ("x" . posX_PauseResume . " y" . BottomY . " w" . BottomBtnW . " h" . BottomBtnH . " gPauseResume vPauseResumeBtn"), 재개/일시정지
Gui, Add, Button, % ("x" . posX_ClearHistory . " y" . BottomY . " w" . BottomBtnW . " h" . BottomBtnH . " gClearHistory"), 내역 초기화
Gui, Add, Button, % ("x" . posX_Exit . " y" . BottomY . " w" . BottomBtnW . " h" . BottomBtnH . " gCloseApp"), 종료
Gui, Show, % ("x903 y605 h" . GuiHeight . " w" . GuiWidth), 컬러 피커 for JBBJ
SetTimer, UpdateColorInfo, 50
return

; -----------------------------------------------------------------------------
; 돋보기 체크박스 토글 시
; -----------------------------------------------------------------------------
ToggleRGB:
Gui, Submit, NoHide
displayRGB := RGBCheck
UpdateAllButtonLabels()
return

ToggleMagnifier:    ; 기존 스크립트에서 가져온 돋보기 토글 기능
Gui, Submit, NoHide
if (MagnifierCheck) {
    ; 아래 경로를 실제 돋보기.ahk가 있는 경로로 수정하세요.
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

; -----------------------------------------------------------------------------
; 새로 색상 픽킹 시 히스토리에 버튼 추가
; -----------------------------------------------------------------------------
AddColorToHistory(colorCode) {
    global colorList, displayRGB, StartX, StartY, ButtonHeight, ButtonWidth, ButtonGap, MaxRows, buttonHandles
    colorList.Push(colorCode)
    idx := colorList.Count()

    row := Mod(idx - 1, MaxRows)
    col := Floor((idx - 1) / MaxRows)

    xPos := StartX + col*(ButtonWidth + ButtonGap)
    yPos := StartY + row*(ButtonHeight + ButtonGap)
    btnText := displayRGB ? HexToRGBText(colorCode) : "#" . colorCode

    Gui, Font, s9, Verdana
    Gui, Add, Button, % ("x" . xPos . " y" . yPos . " w" . ButtonWidth . " h" . ButtonHeight . " gClickColorBtn hwndhCtrl"), %btnText%
    buttonHandles.Push({handle: hCtrl, color: colorCode})

    Gui, Show, NoActivate
}

; -----------------------------------------------------------------------------
; 히스토리 버튼들의 라벨 업데이트 (HEX <-> RGB)
; -----------------------------------------------------------------------------
UpdateAllButtonLabels() {
    global buttonHandles, displayRGB
    for k, info in buttonHandles {
        cCode := info.color
        newLabel := displayRGB ? HexToRGBText(cCode) : "#" . cCode
        SetWindowText(info.handle, newLabel)
    }
}

; -----------------------------------------------------------------------------
; 히스토리 버튼 클릭 시 해당 색상으로 프리뷰 세팅 + 클립보드 복사
; -----------------------------------------------------------------------------
ClickColorBtn:
GuiControlGet, controlHwnd, Hwnd, %A_GuiControl%
pickedColor := ""
for k, info in buttonHandles {
    if (info.handle = controlHwnd) {
        pickedColor := info.color
        break
    }
}
if (pickedColor != "") {
    UpdateColorSample(pickedColor)
    displayText := displayRGB ? HexToRGBText(pickedColor) : "#" . pickedColor
    GuiControl,, ColorCode, % ("색상 코드 : " . displayText)
    Clipboard := displayText
    ToolTip, % ("클립보드에 복사됨: " . displayText)
    SetTimer, RemoveToolTip, 1000
}
return

RemoveToolTip:
ToolTip
SetTimer, RemoveToolTip, Off
return

; -----------------------------------------------------------------------------
; HEX 문자열을 RGB 형식으로 변환
; -----------------------------------------------------------------------------
HexToRGBText(colorCode) {
    r := "0x" . SubStr(colorCode, 1, 2)
    g := "0x" . SubStr(colorCode, 3, 2)
    b := "0x" . SubStr(colorCode, 5, 2)
    return "rgb(" . (r+0) . "," . (g+0) . "," . (b+0) . ")"
}

; -----------------------------------------------------------------------------
; 종료 처리
; -----------------------------------------------------------------------------
CloseApp:
ExitApp

GuiClose:
if (magnifierPID) {
    Process, Close, %magnifierPID%
}
ExitApp
