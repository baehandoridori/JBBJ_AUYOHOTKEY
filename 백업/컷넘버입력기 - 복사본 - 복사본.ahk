#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; 전역변수 선언
global NumberFormat := "sc_" ; 기본값으로 sc_ 고정

; Create Main GUI
Gui, Main:Default
Gui, Add, Edit, x12 y89 w120 h30 vStartNum
Gui, Add, Edit, x192 y89 w120 h30 vEndNum
Gui, Add, Text, x142 y99 w40 h20, 부터
Gui, Add, Text, x322 y99 w40 h20, 까지
Gui, Add, Text, x92 y9 w180 h50 +Center, JBBJ 컷넘버링
Gui, Add, Text, x282 y329 w70 h30, powerd by_BAE
Gui, Add, Text, x12 y129 w340 h80, 위의 박스에 몇 번 부터 몇 번 까지 컷넘버를 입력할건지 설정 후`, 슬랙의 리스트 컷넘버 란을 클릭하고 나서 컷넘버 기입 버튼을 눌러주세요. 동작이 끝날때까진 마우스와 키보드에서 손 떼주시는 걸 권장합니다 (얼마안걸려요)
Gui, Add, GroupBox, x12 y229 w340 h140, 예시
Gui, Add, Edit, x12 y249 w120 h30 ReadOnly, 001
Gui, Add, Text, x142 y259 w40 h20, 부터
Gui, Add, Edit, x192 y249 w120 h30 ReadOnly, 020
Gui, Add, Text, x322 y259 w40 h20, 까지
Gui, Add, Text, x12 y289 w340 h30 +Center, sc_001 부터 sc_020 까지 자동으로 입력
Gui, Font, S10 CDefault Bold, Verdana
Gui, Add, Button, x82 y319 w180 h40 gWriteNumbers, 컷넘버 기입

Gui, Show, x654 y662 h370 w373, JBBJ 컷넘버링
Return

; Progress GUI
Gui, Progress:New, +AlwaysOnTop -Caption
Gui, Progress:Add, Progress, x10 y10 w200 h20 vProgressBar
Gui, Progress:Add, Text, x10 y35 w200 h20 vProgressText +Center, 진행중...
Gui, Progress:Add, Button, x60 y60 w100 h30 gStopScript, 중지
Gui, Progress:Font, s8

GuiClose:
ExitApp

StopScript:
ExitApp

WriteNumbers:
Gui, Submit, NoHide

if (StartNum = "" || EndNum = "") {
    MsgBox, 시작 번호와 끝 번호를 입력해주세요.
    return
}

; Find Slack window with "제작 시트"
WinGet, id, list, ahk_exe slack.exe
found := false
Loop, %id%
{
    this_id := id%A_Index%
    WinGetTitle, title, ahk_id %this_id%
    if (InStr(title, "제작 시트")) {
        WinActivate, ahk_id %this_id%
        found := true
        break
    }
}

if (!found) {
    MsgBox, 시트지 창을 찾지 못했습니다.
    return
}

; Show Progress GUI
Gui, Progress:Show, w220 h100, 진행 상황

; Write numbers
Sleep, 1000  ; Wait for window activation
startNum := StartNum + 0
endNum := EndNum + 0

loopCount := endNum - startNum + 1
Loop, %loopCount%
{
    ; Ensure Slack window is active
    WinActivate, ahk_id %this_id%
    
    ; Update progress bar
    progress := (A_Index / loopCount) * 100
    GuiControl, Progress:, ProgressBar, %progress%
    GuiControl, Progress:, ProgressText, 진행중... (%A_Index%/%loopCount%)
    
    currentNum := startNum + A_Index - 1
    formattedNum := Format("{:03d}", currentNum)
    SendInput, %NumberFormat%%formattedNum%
    Sleep, 300
    SendInput, {Enter}
    Sleep, 500
}

Gui, Progress:Destroy
MsgBox, 컷넘버 기입이 완료되었습니다.
return