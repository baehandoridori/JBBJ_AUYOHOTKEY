#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off

; ------------------------------------------------------
; [0] 사용자 정의 종료 함수
; ------------------------------------------------------
MyExitApp() {
    ExitApp()
}

; ------------------------------------------------------
; [1] 전역 변수 선언
; ------------------------------------------------------
global secretNumber := ""    ; 랜덤 생성된 정답 숫자
global digitCount   := 3     ; 난이도(숫자 개수)
global startTime    := 0     ; 게임 시작 시점 (A_TickCount)
global tryCount     := 0     ; 시도 횟수
global difficultyGui := ""   ; 난이도 선택 GUI 객체
global gameGui      := ""    ; 메인 게임 GUI 객체

; ------------------------------------------------------
; [2] 난이도 선택 GUI (라디오 버튼 사용)
; ------------------------------------------------------
ShowDifficultySelection() {
    global difficultyGui
    difficultyGui := Gui()
    difficultyGui.SetFont("s12")
    difficultyGui.Add("Text", "x20 y20 w250 h30", "숫자 야구 난이도를 선택하세요:")
    ; 각 라디오 버튼에는 고유 변수명을 지정하여 그룹화
    difficultyGui.Add("Radio", "vRadio3 Checked x20 y60", "3자리")
    difficultyGui.Add("Radio", "vRadio4 x20 y90", "4자리")
    difficultyGui.Add("Radio", "vRadio5 x20 y120", "5자리")
    diffStart := difficultyGui.Add("Button", "x20 y160 w100 h30", "게임 시작")
    diffStart.OnEvent("Click", &StartGame)
    difficultyGui.OnEvent("Close", &MyExitApp)
    difficultyGui.Title := "난이도 선택"
    difficultyGui.Show("Center")
}

; ------------------------------------------------------
; [3] 난이도 선택 후 게임 시작
; ------------------------------------------------------
StartGame() {
    global difficultyGui, digitCount, secretNumber, startTime, tryCount
    selected := difficultyGui.Submit()
    if (selected.Radio3 = "1")
        digitCount := 3
    else if (selected.Radio4 = "1")
        digitCount := 4
    else if (selected.Radio5 = "1")
        digitCount := 5
    else
        digitCount := 3
    difficultyGui.Destroy()
    
    secretNumber := GenerateRandomNumber(digitCount)
    startTime := A_TickCount
    tryCount := 0
    
    CreateGameGui()
}

; ------------------------------------------------------
; [4] 메인 게임 GUI 생성 (처음에 보내준 GUI 배치를 적용)
; ------------------------------------------------------
CreateGameGui() {
    global gameGui, digitCount, startTime
    gameGui := Gui()
    gameGui.SetFont("s12")
    
    ; 숫자 버튼들 (좌표와 크기는 예시 그대로)
    gameGui.Add("Button", "x502 y129 w70 h70", "1").OnEvent("Click", &btnDigit)
    gameGui.Add("Button", "x582 y129 w70 h70", "2").OnEvent("Click", &btnDigit)
    gameGui.Add("Button", "x662 y129 w70 h70", "3").OnEvent("Click", &btnDigit)
    gameGui.Add("Button", "x502 y209 w70 h70", "4").OnEvent("Click", &btnDigit)
    gameGui.Add("Button", "x582 y209 w70 h70", "5").OnEvent("Click", &btnDigit)
    gameGui.Add("Button", "x662 y209 w70 h70", "6").OnEvent("Click", &btnDigit)
    gameGui.Add("Button", "x502 y289 w70 h70", "7").OnEvent("Click", &btnDigit)
    gameGui.Add("Button", "x582 y289 w70 h70", "8").OnEvent("Click", &btnDigit)
    gameGui.Add("Button", "x662 y289 w70 h70", "9").OnEvent("Click", &btnDigit)
    gameGui.Add("Button", "x582 y369 w70 h70", "0").OnEvent("Click", &btnDigit)
    gameGui.Add("Button", "x662 y369 w70 h70", "확인").OnEvent("Click", &CheckGuess)
    gameGui.Add("Button", "x502 y369 w70 h70", "Del").OnEvent("Click", &btnDel)
    
    ; 숫자 입력 Edit (사용자 입력)
    gameGui.Add("Edit", "vUserInput x542 y79 w140 h40", "")
    
    ; 그룹박스: 숫자 입력 영역
    gameGui.Add("GroupBox", "x482 y59 w270 h390", "숫자 입력")
    
    ; 결과 출력 Edit 컨트롤 (읽기 전용, 검은 배경, 흰 글씨)
    gameGui.Add("Edit", "vResultEdit x52 y59 w370 h590 ReadOnly BackgroundBlack cWhite", "")
    
    ; 메모용 Edit 컨트롤
    gameGui.Add("Edit", "vMemoEdit x482 y469 w270 h180", "")
    
    ; 힌트 모드 체크박스 (기본적으로 체크 해제)
    gameGui.Add("CheckBox", "vHintMode x652 y29 w100 h30", "힌트 모드")
    
    ; 숫자야구 룰 설명 Text (명확하고 직관적으로)
    rules := "
    (LTrim
    1) 컴퓨터는 중복되지 않는 숫자를 랜덤으로 선택합니다.
    2) 플레이어는 해당 숫자들을 추측하여 입력합니다.
    3) 숫자와 위치가 모두 맞으면 '스트라이크',
       숫자만 맞으면 '볼', 틀리면 '아웃'입니다.
    4) 입력한 숫자는 중복될 수 없습니다.
    )"
    gameGui.Add("Text", "x52 y19 w230 h30", rules)
    
    ; 경과 시간 텍스트
    gameGui.Add("Text", "vElapsedTime x332 y29 w160 h20", "경과 시간: 0초")
    
    gameGui.OnEvent("Close", &MyExitApp)
    gameGui.Title := "숫자 야구 게임"
    gameGui.Show("x849 y458 h675 w771")
    
    ; 1초마다 경과 시간 업데이트
    SetTimer(UpdateElapsedTime, 1000)
}

; ------------------------------------------------------
; [5] 숫자 버튼 클릭 이벤트: 입력창에 숫자 추가
; ------------------------------------------------------
btnDigit(ctrl) {
    global gameGui
    current := gameGui["UserInput"].Value
    gameGui["UserInput"].Value := current . ctrl.Text
}

; ------------------------------------------------------
; [6] Del 버튼 이벤트: 입력창 마지막 숫자 삭제
; ------------------------------------------------------
btnDel() {
    global gameGui
    current := gameGui["UserInput"].Value
    if StrLen(current) > 0
        gameGui["UserInput"].Value := SubStr(current, 1, StrLen(current) - 1)
}

; ------------------------------------------------------
; [7] 확인 버튼 이벤트: 입력 검사 및 판정
; ------------------------------------------------------
CheckGuess() {
    global gameGui, secretNumber, digitCount, tryCount, startTime
    userInput := gameGui["UserInput"].Value
    if (StrLen(userInput) != digitCount) {
        MsgBox("오류: " digitCount "자리 숫자를 입력하세요.", "오류", 48)
        return
    }
    if (CheckDuplicate(userInput)) {
        MsgBox("오류: 중복된 숫자가 있습니다. 다시 입력하세요.", "오류", 48)
        return
    }

    tryCount++
    strikeCount := 0
    ballCount := 0
    for index, digit in StrSplit(userInput, "") {
        pos := InStr(secretNumber, digit)
        if pos {
            if (pos = index)
                strikeCount++
            else
                ballCount++
        }
    }
    outCount := digitCount - (strikeCount + ballCount)

    currentResult := gameGui["ResultEdit"].Value
    ; 기존에 "On" 이라고 되어있던 부분을 "O`n"으로 수정
    newLine := Format("시도 {1}: {2} => {3} S, {4} B, {5} O`n", tryCount, userInput, strikeCount, ballCount, outCount)
    gameGui["ResultEdit"].Value := currentResult . newLine

    ; 메시지박스 포맷 문자열 수정 (n -> `n)
    if (strikeCount = digitCount) {
        SetTimer(UpdateElapsedTime, 0)
        totalTime := Floor((A_TickCount - startTime) / 1000)
        MsgBox(Format("정답: {1}`n시도 횟수: {2}`n소요 시간(초): {3}", secretNumber, tryCount, totalTime), "축하합니다!")
        gameGui.Destroy()
        ExitApp()
    }

    gameGui["UserInput"].Value := ""
}

; ------------------------------------------------------
; [8] 경과 시간 업데이트 (1초마다 호출)
; ------------------------------------------------------
UpdateElapsedTime() {
    global gameGui, startTime
    elapsed := Floor((A_TickCount - startTime) / 1000)
    gameGui["ElapsedTime"].Value := "경과 시간: " elapsed "초"
}

; ------------------------------------------------------
; [9] 중복 없는 임의의 숫자 생성 함수
; ------------------------------------------------------
GenerateRandomNumber(count) {
    randomNum := ""
    while (StrLen(randomNum) < count) {
        rand := Random(0, 9)
        if !InStr(randomNum, rand)
            randomNum .= rand
    }
    return randomNum
}

; ------------------------------------------------------
; [10] 문자열 중복 검사 함수
; ------------------------------------------------------
CheckDuplicate(str) {
    for index, char in StrSplit(str, "") {
        rest := SubStr(str, index + 1)
        if InStr(rest, char)
            return true
    }
    return false
}

; 시작: 난이도 선택 GUI 표시
ShowDifficultySelection()