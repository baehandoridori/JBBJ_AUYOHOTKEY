#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off


; - 시간 중지 버튼

; ------------------------------------------------------
; [1] 전역 변수 선언
; ------------------------------------------------------
global secretNumber := ""    ; 랜덤 생성된 정답 숫자
global digitCount   := 3     ; 난이도(숫자 개수)
global startTime    := 0     ; 게임 시작 시점(A_TickCount)
global tryCount     := 0     ; 시도 횟수
global MainGui     := ""     ; 메인 GUI 객체
global GameGui     := ""     ; 게임 GUI 객체

; ------------------------------------------------------
; [2] 난이도 선택 GUI
; ------------------------------------------------------
MainGui := Gui()
MainGui.Add("Text",, "숫자 야구 난이도를 선택하세요.")
MainGui.Add("Radio", "vDifficulty Checked", "3자리")
MainGui.Add("Radio",, "4자리")
MainGui.Add("Radio",, "5자리")
StartButton := MainGui.Add("Button",, "게임 시작")
StartButton.OnEvent("Click", StartGame)
MainGui.OnEvent("Close", (*) => ExitApp())
MainGui.Show()

; ------------------------------------------------------
; [3] 난이도 선택 후 메인 게임창 열기
; ------------------------------------------------------
StartGame(*)
{
    global MainGui, GameGui, secretNumber, digitCount, startTime, tryCount

    ; 난이도 선택값 가져오기
    selected := MainGui.Submit(false)
    digitCount := selected.Difficulty = 1 ? 3 : selected.Difficulty = 2 ? 4 : 5

    ; 난이도 선택 GUI 닫기
    MainGui.Destroy()

    ; 중복 없는 임의의 숫자 생성
    secretNumber := GenerateRandomNumber(digitCount)
    startTime := A_TickCount
    tryCount := 0

    ; 메인 게임 GUI
    GameGui := Gui()
    GameGui.MarginX := 10
    GameGui.MarginY := 10
    
    ; 게임 정보
    GameGui.Add("Text",, "난이도: " digitCount "자리 숫자 야구")
    TimeText := GameGui.Add("Text", "vElapsedTimeText", "경과 시간: 0분 0초")
    
    ; 입력 필드
    InputEdit := GameGui.Add("Edit", "vUserGuess w200")
    CheckButton := GameGui.Add("Button", "x+5", "확인")
    CheckButton.OnEvent("Click", CheckGuess)

    ; Enter 키 이벤트 추가
    InputEdit.OnEvent("Change", OnInputChange)

    ; 결과 표시 ListView
    LV := GameGui.Add("ListView", "x10 y100 w300 h350 -Multi -Hdr Background000000 cWhite", ["결과"])
    LV.ModifyCol(1, 280)  ; 열 너비 조정

    ; 메모 영역
    GameGui.Add("Edit", "x+10 y100 w250 h350 vMemoArea")

    ; GUI 설정 및 표시
    GameGui.OnEvent("Close", (*) => ExitApp())
    GameGui.Show("w600 h500")

    ; 1초마다 경과 시간 표기
    SetTimer(UpdateElapsedTime, 1000)
}

; ------------------------------------------------------
; [4] 입력 필드 변경 이벤트 (Enter 키 처리)
; ------------------------------------------------------
OnInputChange(Edit, *)
{
    if (GetKeyState("Enter")) {
        CheckGuess()
    }
}

; ------------------------------------------------------
; [5] 매 초마다 경과 시간 표시
; ------------------------------------------------------
UpdateElapsedTime()
{
    global GameGui, startTime
    elapsedSec := Floor((A_TickCount - startTime) / 1000)
    elapsedMin := Floor(elapsedSec / 60)
    elapsedSec := Mod(elapsedSec, 60)
    GameGui["ElapsedTimeText"].Value := "경과 시간: " elapsedMin "분 " elapsedSec "초"
}

; ------------------------------------------------------
; [6] "확인" 버튼 클릭 시 - 숫자 입력 검사 & 판정
; ------------------------------------------------------
CheckGuess(*)
{
    global GameGui, secretNumber, digitCount, tryCount
    
    userInput := GameGui["UserGuess"].Value

    ; 자리 수 확인
    if (StrLen(userInput) != digitCount) {
        MsgBox("오류: " digitCount "자리 숫자를 입력하세요.", "오류", 48)
        return
    }

    ; 숫자 중복 검사
    if CheckDuplicate(userInput) {
        MsgBox("오류: 중복된 숫자가 있습니다. 다시 입력하세요.", "오류", 48)
        return
    }

    ; 시도 횟수 증가
    tryCount++

    ; 스트라이크 / 볼 / 아웃 계산
    strikeCount := 0
    ballCount := 0
    Loop Parse, userInput
    {
        digit := A_LoopField
        pos := InStr(secretNumber, digit)
        if (pos > 0)
            if (pos = A_Index)
                strikeCount++
            else
                ballCount++
    }
    outCount := digitCount - (strikeCount + ballCount)

    ; 결과를 ListView에 추가
    tryText := Format("    시도 {}: {}", tryCount, userInput)
    resultText := Format("    {} S {} B {} O", strikeCount, ballCount, outCount)
    
    ; 새 항목을 맨 아래에 추가
    LV := GameGui["SysListView321"]
    LV.Add(, tryText)
    LV.Add(, resultText)
    LV.Add(, "")  ; 빈 줄 추가

    ; 확실한 스크롤 처리
    lastIndex := LV.GetCount()
    LV.Modify(lastIndex, "Focus")  ; 마지막 항목에 포커스
    LV.Modify(lastIndex, "Select") ; 마지막 항목 선택
    LV.Modify(lastIndex, "Vis")    ; 마지막 항목이 보이도록 스크롤
    PostMessage(0x115, 7, 0, LV)   ; WM_VSCROLL with SB_BOTTOM

    ; 정답 확인
    if (strikeCount = digitCount) {
        SetTimer(UpdateElapsedTime, 0)
        totalTime := (A_TickCount - startTime) / 1000
        MsgBox(Format("
        (
            정답: {1}
            시도 횟수: {2}
            소요 시간(초): {3}
        )", secretNumber, tryCount, totalTime), "축하합니다!")
        GameGui.Destroy()
    }

    ; 입력 필드 초기화
    GameGui["UserGuess"].Value := ""
}

; ------------------------------------------------------
; [7] 난이도(digitCount) 중복 없는 임의 숫자 생성
; ------------------------------------------------------
GenerateRandomNumber(count)
{
    randomNum := ""
    while (StrLen(randomNum) < count)
    {
        rand := Random(0, 9)
        if !InStr(randomNum, rand)
            randomNum .= rand
    }
    return randomNum
}

; ------------------------------------------------------
; [8] 문자열 중복 검사
; ------------------------------------------------------
CheckDuplicate(str)
{
    Loop Parse, str
    {
        c := A_LoopField
        rest := SubStr(str, A_Index + 1)
        if InStr(rest, c)
            return true
    }
    return false
}