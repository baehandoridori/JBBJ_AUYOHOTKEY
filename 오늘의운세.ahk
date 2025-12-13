#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1

; 스크립트를 UTF-8로 저장했음을 명시
FileEncoding, UTF-8

; 파일 경로를 global로 설정
global filePath := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\운세용\TODAY.txt"

; 아스키 아트 정의
global sharkArt := "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀`n"
    . "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀`n"
    . "⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀`n"
    . "⢠⣾⣿⣏⠉⠉⠉⠉⠉⠉⢡⣶⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠻⢿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⡄⠀`n"
    . "⠈⣿⣿⣿⣿⣦⣽⣦⡀⠀⠀⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⠀⠀`n"
    . "⠀⠘⢿⣿⣿⣿⣿⣿⣿⣦⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⠇⠀⠀`n"
    . "⠀⠀⠈⠻⣿⣿⣿⣿⡟⢿⠻⠛⠙⠉⠋⠛⠳⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⡟⠀⠀⠀`n"
    . "⠀⠀⠀⠀⠈⠙⢿⡇⣠⣤⣶⣶⣾⡉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣰⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠾⢇⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⠃⠀⠀⠀`n"
    . "⠀⠀⠀⠀⠀⠀⠀⠱⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠤⢤⣀⣀⣀⣀⣀⣀⣠⣤⣤⣤⣬⣭⣿⣿⠀⠀⠀⠀`n"
    . "⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⣶⣤⣄⣀⣀⣠⣴⣾⣿⣿⣿⣷⣤⣀⡀⠀⠀⠀⠀⠀⠀⣀⣀⣤⣾⣿⣿⣿⣿⡿⠿⠛⠛⠻⣿⣿⣿⣿⣇⠀⠀⠀`n"
    . "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣤⣤⣘⡛⠿⢿⡿⠟⠛⠉⠁⠀⠀⠀⠀⠀⠈⠻⣿⣿⣿⣦⠀⠀`n"
    . "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⢿⣿⣿⣿⣿⣿⣶⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⡄⠀`n"
    . "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⠿⠛⠉⠁⠀⠈⠉⠙⠛⠛⠻⠿⠿⠿⠿⠟⠛⠃⠀⠀⠀⠉⠉⠉⠛⠛⠛⠿⠿⠿⣶⣦⣄⡀⠀⠀⠀⠀⠀⠈⠙⠛⠂`n"
    . "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠿⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀"
    . "`n"
    . "`n"
    . "`n"
    . "                          당신은 상어에게 잡아먹혔습니다.`n"
    . "                    새 생명을 얻은 셈 치고 오늘 일 열심히 하십시오.`n"


; 파일 읽기 및 정보 추출 함수
ReadFortuneInfo() {
    if (!FileExist(filePath)) {
        MsgBox, 16, 오류, 파일을 찾을 수 없습니다: %filePath%
        return {tip: "파일 없음", fortune: "파일 없음", score: 0}
    }

    try {
        FileRead, content, %filePath%
        if (ErrorLevel) {
            MsgBox, 16, 오류, 파일 읽기 실패. ErrorLevel: %ErrorLevel%, A_LastError: %A_LastError%
            return {tip: "파일 읽기 오류", fortune: "파일 읽기 오류", score: 0}
        }

        fortuneBlocks := []
        blocks := StrSplit(content, "-----------------------------------------------")
        
        for index, block in blocks {
            if (block = "" || block = "`n" || block = "`r`n")
                continue
            
            fortune := ""
            score := 0
            tip := ""
            
            Loop, Parse, block, `n, `r
            {
                if (InStr(A_LoopField, "오늘의 운세 결과!"))
                    continue
                if (InStr(A_LoopField, "운세 점수")) {
                    RegExMatch(A_LoopField, "운세 점수 (\d+)/100", scoreMatch)
                    score := scoreMatch1
                    continue
                }
                if (InStr(A_LoopField, "팁 :")) {
                    tip := Trim(SubStr(A_LoopField, 4))
                    continue
                }
                if (A_LoopField != "")
                    fortune .= A_LoopField . "`n"
            }
            
            fortuneBlocks.Push({fortune: Trim(fortune), tip: tip, score: score})
        }

        if (fortuneBlocks.Length() == 0) {
            MsgBox, 16, 오류, 운세 블록을 찾을 수 없습니다.
            return {tip: "내용 없음", fortune: "내용 없음", score: 0}
        }

        Random, index, 1, % fortuneBlocks.Length()
        return fortuneBlocks[index]
    } catch e {
        MsgBox, 16, 오류, 파일 처리 중 오류 발생: %e%
        return {tip: "오류 발생", fortune: "오류 발생", score: 0}
    }
}

ShowSharkArt() {
    global sharkArt
    
    Gui, Shark:New, +AlwaysOnTop
    Gui, Shark:Font, s8 cBlack, Consolas  ; Consolas 폰트로 아스키아트 표시
    Gui, Shark:Add, Edit, x10 y10 w600 h400 ReadOnly, %sharkArt%
    Gui, Shark:Show, w480 h350, 특별 메시지
}

; GUI 업데이트 함수
UpdateGUI() {
    result := ReadFortuneInfo()
    
    ; 운세 업데이트
    GuiControl,, FortuneEdit, % result.fortune
    
    ; 팁 업데이트
    GuiControl,, TipText, % result.tip
    
    ; 점수 텍스트 업데이트
    GuiControl,, ScoreText, % result.score . "/100"
    
    ; 프로그레스 바 업데이트 및 색상 변경
    GuiControl,, ProgressBar, % result.score
    if (result.score <= 30)
        GuiControl, +cRed, ProgressBar
    else if (result.score <= 65)
        GuiControl, +cYellow, ProgressBar
    else if (result.score <= 80)
        GuiControl, +cLime, ProgressBar
    else
        GuiControl, +cBlue, ProgressBar
    
    ; 특정 운세에 대한 메시지 박스 표시
    if (InStr(result.fortune, "-당신은 상어에게 잡아먹혔습니다-")) {
        ShowSharkArt()
    }
}

; GUI 생성
Gui, Font, s10 cBlack, Verdana
Gui, Add, Text, x172 y9 w250 h40 +Center, STUDIO JBBJ 오늘의 운세

Gui, Font, s8 cGray Italic, Verdana
Gui, Add, Text, x480 y29 w120 h20, 재미로만 봐주세요

Gui, Font, s8 cBlack norm, Verdana
Gui, Add, Text, x462 y9 w120 h20 +Right, 만든놈:빨간바지

Gui, Font, s10 cBlack, Verdana
Gui, Add, GroupBox, x12 y49 w570 h180 +Center, 당신의 오늘 운세
Gui, Add, Edit, vFortuneEdit x22 y69 w550 h150 ReadOnly -E0x200

Gui, Add, Text, vScoreText x12 y239 w50 h20, 0/100
Gui, Add, Progress, vProgressBar x62 y239 w510 h20

Gui, Add, GroupBox, x12 y279 w570 h80 +Center, 오늘의 팁
Gui, Add, Text, vTipText x22 y299 w550 h50

Gui, Font, s10 cBlack, Verdana
Gui, Add, Button, x12 y369 w130 h40 gRefreshFortune, 다시보기
Gui, Add, Button, x452 y369 w130 h40 gGuiClose, 창 닫기

; GUI 표시
Gui, Show, x539 y630 h423 w598, 오늘의 운세

; 초기 GUI 업데이트
gosub, RefreshFortune

return

; 다시보기 버튼 클릭 이벤트
RefreshFortune:
    UpdateGUI()
return

GuiClose:
ExitApp