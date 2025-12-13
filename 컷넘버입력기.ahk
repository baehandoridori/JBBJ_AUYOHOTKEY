#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; 전역변수 선언
global NumberFormat := "sc_" ; 기본값으로 sc_ 고정
global PrefixInput := "sc_" ; PrefixInput 초기값도 설정

; Create Main GUI
Gui, Main:Default
Gui, Add, Edit, x90 y89 w50 h30 vStartNum
Gui, Add, Edit, x190 y89 w50 h30 vEndNum
Gui, Add, Text, x152 y99 w40 h20, 부터
Gui, Add, Text, x250 y99 w40 h20, 까지
Gui, Add, Text, x92 y9 w180 h50 +Center, JBBJ 씬번호 기입 도우미
Gui, Add, Text, x282 y329 w70 h30, powerd by_BAE

; 접두사 선택 UI 추가
Gui, Add, Text, x85 y54 w70 h20, 접두사:
Gui, Add, Edit, x132 y49 w80 h20 vPrefixInput gUpdatePrefix, %NumberFormat%
Gui, Add, Button, x222 y49 w60 h20 gSetPrefix, 적용

Gui, Add, Text, x12 y129 w340 h80, 위의 박스에 몇 번 부터 몇 번 까지 컷넘버를 입력할건지 설정 후, 슬랙의 리스트 컷넘버 란을 클릭하고 나서 컷넘버 기입 버튼을 눌러주세요. 동작이 끝날때까진 마우스와 키보드에서 손 떼주시는 걸 권장합니다 (얼마안걸려요)

; 메인 GUI에 프로그레스 바 추가
Gui, Add, Progress, x12 y209 w340 h15 vMainProgressBar c0078D7, 0
Gui, Add, Text, x12 y189 w340 h20 +Center vMainProgressText, 진행 상황: 0`%

Gui, Add, GroupBox, x12 y229 w340 h140, 예시
Gui, Add, Edit, x90 y249 w50 h30 ReadOnly, 001
Gui, Add, Text, x152 y259 w40 h20, 부터
Gui, Add, Edit, x190 y249 w50 h30 ReadOnly, 020
Gui, Add, Text, x250 y259 w40 h20, 까지
Gui, Add, Text, x12 y289 w340 h30 +Center, sc_001 부터 sc_020 까지 자동으로 입력
Gui, Font, S10 CDefault Bold, Verdana
Gui, Add, Button, x82 y319 w180 h40 gWriteNumbers, 컷넘버 기입

Gui, Show, x654 y662 h370 w373, JBBJ_씬번호써줘
Gui, Submit, NoHide 
Return

MainGuiClose:
ExitApp
Return

UpdatePrefix:
Gui, Submit, NoHide
NumberFormat := PrefixInput
return

; 접두사 설정 함수
SetPrefix:
Gui, Submit, NoHide
NumberFormat := PrefixInput
return

WriteNumbers:
Gui, Submit, NoHide

if (NumberFormat = "") {
    NumberFormat := "sc_"
}

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

; 프로그레스 초기화
GuiControl,, MainProgressBar, 0
GuiControl,, MainProgressText, 진행 상황: 0`%

Sleep, 1000  ; Wait for window activation
startNum := StartNum + 0
endNum := EndNum + 0

loopCount := endNum - startNum + 1

Loop, %loopCount%
{
    ; Update progress bar
    progress := Round((A_Index / loopCount) * 100)
    GuiControl,, MainProgressBar, %progress%
    GuiControl,, MainProgressText, % "진행 상황: " . progress . "`%"

    ; Slack 창 활성화
    WinActivate, ahk_id %this_id%
    
    currentNum := startNum + A_Index - 1
    formattedNum := Format("{:03d}", currentNum)

    ; 클립보드를 사용한 접두사 입력
    oldClipboard := ClipboardAll  ; 현재 클립보드 내용 백업
    Clipboard := NumberFormat     ; 접두사를 클립보드에 복사
    SendInput, {Enter}
    Sleep, 100
    SendInput, ^v                 ; 접두사 붙여넣기
    Sleep, 100
    SendInput, %formattedNum%     ; 번호 입력
    Sleep, 200
    SendInput, {Enter}           ; 엔터
    Sleep, 400
    Clipboard := oldClipboard    ; 클립보드 복원
}

MsgBox, 컷넘버 기입이 완료되었습니다.

; 완료 메시지 후 프로그레스 초기화
GuiControl,, MainProgressBar, 0
GuiControl,, MainProgressText, 진행 상황: 0`%
return