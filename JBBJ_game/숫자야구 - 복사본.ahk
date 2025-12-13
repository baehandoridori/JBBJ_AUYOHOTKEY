#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off

; ---------------------------
; 전역 변수
; ---------------------------
global secretNumber := ""
global digitCount   := 3
global tryCount     := 0
global startTime    := 0
global historyText  := ""

; 스크립트 시작
showDifficultyGui()

; -----------------------------------------------
; (1) 난이도 선택 GUI
; -----------------------------------------------
showDifficultyGui() {
    global digitCount   ; 함수 시작시 global 선언
    
    guiDiff := Gui()
    guiDiff.OnEvent("Close", (*) => ExitApp())

    guiDiff.Add("Text",, "숫자 야구 난이도를 선택하세요.")

    guiDiff.Add("Radio", "vDiffRadio Section Checked", "3자리")
    guiDiff.Add("Radio", "xs", "4자리")
    guiDiff.Add("Radio", "xs", "5자리")

    btn := guiDiff.Add("Button", "xm wp Section", "게임 시작")
    
    ; 버튼 클릭 핸들러를 별도 함수로 정의
    CheckDifficulty(ctrl, info) {
        guiDiff.Submit()
        diffVal := guiDiff.Value.DiffRadio

        if (diffVal = 1)
            digitCount := 3
        else if (diffVal = 2)
            digitCount := 4
        else
            digitCount := 5

        guiDiff.Destroy()
        startMainGui()
    }

    ; 일반 함수 바인딩
    btn.OnEvent("Click", CheckDifficulty)

    guiDiff.Show("w300 h150", "난이도 선택")
}
; -----------------------------------------------
; (2) 메인 GUI 열기
; -----------------------------------------------
startMainGui() {
    global secretNumber, digitCount, tryCount, startTime, historyText

    ; 난수 생성
    secretNumber := generateRandomNumber(digitCount)
    tryCount     := 0
    historyText  := ""
    startTime    := A_TickCount

    gameGui := Gui()
    gameGui.OnEvent("Close", (*) => ExitApp())

    ; 난이도 / 경과 시간 표시
    gameGui.Add("Text", "xm ym", "난이도: " digitCount "자리 숫자 야구")
    lblTime := gameGui.Add("Text", "xm", "경과 시간: 0분 0초")

    ; 입력칸 + 확인 버튼
    inputGuess := gameGui.Add("Edit", "xm y+5 w200 vVarGuess")
    btnCheck   := gameGui.Add("Button", "x+5", "확인")
    btnCheck.OnEvent("Click", checkGuess)

    ; 검정 배경 + 흰 글씨 Edit
    ; +Background000000 = #000000(검정), cWhite=글자흰색, +ReadOnly=편집불가
    resultEdit := gameGui.Add("Edit", "xm y+10 w300 h350 vResultArea ReadOnly +Background000000 cWhite")

    ; 옆에 메모용 Edit
    memoEdit := gameGui.Add("Edit", "x+5 w200 h350 vMemoArea")

    gameGui.Show("w600 h500", "숫자 야구 게임")

    ; 경과 시간 타이머
    SetTimer(updateElapsedTime, 1000)
}

; -----------------------------------------------
; (3) 1초마다 경과 시간 표시
; -----------------------------------------------
updateElapsedTime(*) {
    global startTime
    gui := GuiFromEvent()

    now := A_TickCount
    diff := now - startTime
    sec := Floor(diff / 1000)
    min := Floor(sec / 60)
    sec := Mod(sec, 60)

    textStr := "경과 시간: " min "분 " sec "초"
    ; 2번째 컨트롤(Text) → Text 속성 변경
    gui.Control(2).Text := textStr
}

; -----------------------------------------------
; (4) "확인" 버튼 -> 숫자 검사 & 스트/볼/아웃
; -----------------------------------------------
checkGuess(ctrl, info) {
    global secretNumber, digitCount, tryCount, historyText

    gui := GuiFromEvent()
    guessVal := gui.Value.VarGuess

    ; 길이 검사
    if (StrLen(guessVal) != digitCount) {
        MsgBox("오류: " digitCount "자리 숫자를 입력하세요.")
        return
    }
    ; 중복 검사
    if (checkDuplicate(guessVal)) {
        MsgBox("오류: 중복된 숫자가 있습니다. 다시 입력하세요.")
        return
    }
    tryCount++

    strikeCount := 0
    ballCount   := 0

    for i in 1..digitCount {
        ch := SubStr(guessVal, i, 1)
        pos := InStr(secretNumber, ch)
        if (pos > 0) {
            if (pos = i)
                strikeCount++
            else
                ballCount++
        }
    }
    outCount := digitCount - (strikeCount + ballCount)

    line := Format("시도 {1}: {2} → {3}S, {4}B, {5}O", tryCount, guessVal, strikeCount, ballCount, outCount)
    historyText .= line . "`r`n"

    gui.Value.ResultArea := historyText

    ; 정답 여부
    if (strikeCount = digitCount) {
        totalSec := Floor((A_TickCount - startTime)/1000)
        MsgBox("축하합니다!"
             . "`n정답: " secretNumber
             . "`n시도 횟수: " tryCount
             . "`n소요 시간(초): " totalSec)
        gui.Destroy()
    }
}

; -----------------------------------------------
; [5] 난수 생성 + 중복 검사
; -----------------------------------------------
generateRandomNumber(count) {
    str := ""
    while (StrLen(str) < count) {
        Random r, 0, 9
        if !InStr(str, r)
            str .= r
    }
    return str
}

checkDuplicate(str) {
    for i in 1..StrLen(str) {
        c := SubStr(str, i, 1)
        rest := SubStr(str, i+1)
        if InStr(rest, c)
            return true
    }
    return false
}
