#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1

; 전역 변수
global isActive := true
global displayRGB := false  ; 체크박스 상태 (false=HEX, true=RGB)
global colorList := []
global buttonHandles := []  ; {handle, color}

; 레이아웃 설정 (예: 이전 대화에서 설정한 값들)
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

Gui, +AlwaysOnTop
Gui, Add, Text, x250 y10 w240 h30 +Center, 컬러 피커 for JBBJ
Gui, Add, Text, x12 y40 w160 h30 vColorCode, 색상 코드 :
Gui, Add, CheckBox, x12 y65 w150 h30 vRGBCheck gToggleRGB, RGB 형식으로 보기
Gui, Font, s12, Verdana
Gui, Add, GroupBox, % ("x" . GroupX . " y" . GroupY . " w" . GroupW . " h" . GroupH . " cRed"), 컬러 히스토리
Gui, Add, Progress, % ("x" . PreviewX . " y" . PreviewY . " w" . PreviewW . " h" . PreviewH . " vColorSample -Smooth"), 100
Gui, Add, Button, % ("x" . posX_PauseResume . " y" . BottomY . " w" . BottomBtnW . " h" . BottomBtnH . " gPauseResume vPauseResumeBtn"), 재개/일시정지
Gui, Add, Button, % ("x" . posX_ClearHistory . " y" . BottomY . " w" . BottomBtnW . " h" . BottomBtnH . " gClearHistory"), 내역 초기화
Gui, Add, Button, % ("x" . posX_Exit . " y" . BottomY . " w" . BottomBtnW . " h" . BottomBtnH . " gCloseApp"), 종료

Gui, Show, % ("x903 y605 h" . GuiHeight . " w" . GuiWidth), 컬러 피커 for JBBJ
SetTimer, UpdateColorInfo, 50
return

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

ClearHistory:
Gui, Destroy
colorList := []
buttonHandles := []
Gosub, ReInitGUI
return

ReInitGUI:
Gui, +AlwaysOnTop
Gui, Add, Text, x12 y10 w240 h30 +Center, 컬러 피커 for JBBJ
Gui, Add, Text, x12 y40 w160 h30 vColorCode, 색상 코드 :
Gui, Add, CheckBox, x12 y70 w150 h30 vRGBCheck gToggleRGB, RGB 형식으로 보기
Gui, Font, s12, Verdana
Gui, Add, GroupBox, % ("x" . GroupX . " y" . GroupY . " w" . GroupW . " h" . GroupH . " cRed"), 컬러 히스토리
Gui, Add, Progress, % ("x" . PreviewX . " y" . PreviewY . " w" . PreviewW . " h" . PreviewH . " vColorSample -Smooth"),100
Gui, Add, Button, % ("x" . posX_PauseResume . " y" . BottomY . " w" . BottomBtnW . " h" . BottomBtnH . " gPauseResume vPauseResumeBtn"), 재개/일시정지
Gui, Add, Button, % ("x" . posX_ClearHistory . " y" . BottomY . " w" . BottomBtnW . " h" . BottomBtnH . " gClearHistory"), 내역 초기화
Gui, Add, Button, % ("x" . posX_Exit . " y" . BottomY . " w" . BottomBtnW . " h" . BottomBtnH . " gCloseApp"), 종료
Gui, Show, % ("x903 y605 h" . GuiHeight . " w" . GuiWidth), 컬러 피커 for JBBJ
SetTimer, UpdateColorInfo, 50
return

ToggleRGB:
Gui, Submit, NoHide
displayRGB := RGBCheck
UpdateAllButtonLabels()
return

AddColorToHistory(colorCode) {
    global colorList, displayRGB, StartX, StartY, ButtonHeight, ButtonWidth, ButtonGap, MaxRows, buttonHandles
    colorList.Push(colorCode)
    idx := colorList.Count()

    row := Mod(idx - 1, MaxRows)
    col := Floor((idx - 1) / MaxRows)

    xPos := StartX + col*(ButtonWidth + ButtonGap)
    yPos := StartY + row*(ButtonHeight + ButtonGap)
    btnText := displayRGB ? HexToRGBText(colorCode) : "#" . colorCode

    ; v옵션 없이 gClickColorBtn와 hwndhCtrl만 사용
    Gui, Font, s9, Verdana
    Gui, Add, Button, % ("x" . xPos . " y" . yPos . " w" . ButtonWidth . " h" . ButtonHeight . " gClickColorBtn hwndhCtrl"), %btnText%
    buttonHandles.Push({handle: hCtrl, color: colorCode})

    Gui, Show, NoActivate
}

UpdateAllButtonLabels() {
    global buttonHandles, displayRGB
    for k, info in buttonHandles {
        cCode := info.color
        newLabel := displayRGB ? HexToRGBText(cCode) : "#" . cCode
        SetWindowText(info.handle, newLabel)
    }
}

ClickColorBtn:
; A_GuiControl 반환값으로는 ClassNN 같은 식별자가 온다.
; handle를 식별하기 위해 buttonHandles를 순회하고, SetWindowText 했을때 
; 버튼 텍스트를 바로 가져올 수 없어 handle 기반으로 찾는다.

; 현재는 handle을 기반으로 클릭한 버튼 식별이 필요하므로 GuiControlGet이 필요 없음
; hwnd을 직접 얻을수 있는 방법:
controlHwnd := ""
GuiControlGet, controlHwnd, Hwnd, %A_GuiControl%

pickedColor := ""
for k, info in buttonHandles {
    if (info.handle = controlHwnd) {
        pickedColor := info.color
        break
    }
}

if (pickedColor != "") {
    ; 컬러코드를 프리뷰 및 상단 텍스트에 반영
    UpdateColorSample(pickedColor)
    displayText := displayRGB ? HexToRGBText(pickedColor) : "#" . pickedColor
    GuiControl,, ColorCode, % ("색상 코드 : " . displayText)
    ; 클립보드 복사 추가(원한다면)
    Clipboard := displayText
    ToolTip, % ("클립보드에 복사됨: " . displayText)
    SetTimer, RemoveToolTip, 1000
}
return

RemoveToolTip:
ToolTip
SetTimer, RemoveToolTip, Off
return

HexToRGBText(colorCode) {
    r := "0x" . SubStr(colorCode, 1, 2)
    g := "0x" . SubStr(colorCode, 3, 2)
    b := "0x" . SubStr(colorCode, 5, 2)
    return "rgb(" . (r+0) . "," . (g+0) . "," . (b+0) . ")"
}

CloseApp:
ExitApp

GuiClose:
ExitApp
