#Requires AutoHotkey v2.0
#SingleInstance Force

; ------------------------------------------------------
; [1] 전역 변수
; ------------------------------------------------------
global secretNumber := ""
global digitCount := 3
global startTime := 0
global tryCount := 0

; 점수 로그 경로
global logFilePath := A_ScriptDir . "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\JBBJ_게임\JBBJ_게임_게임스코어\숫자야구 스코어\score_log.txt"

; 힌트 사용 여부
global hintUsed := false

; 숫자별 결과 저장 (스트라이크/볼/아웃 상태)
global digitStatusMap := Map()

; 시도 기록 저장용 배열 (힌트모드 토글시 결과창 재구성에 사용)
global tryHistory := []

; GUI 객체 저장
global mainGui := ""
global hBtn := Map()

; ------------------------------------------------------
; 난이도 선택 GUI (#1)
; ------------------------------------------------------
difficultyGui := Gui("+AlwaysOnTop", "난이도 선택")
difficultyGui.SetFont("s10")
difficultyGui.Add("Text", "x20 y20 w280 h30", "숫자 야구 난이도를 선택하세요.")

radio3 := difficultyGui.Add("Radio", "vRadio3 Checked x20 y60", "3자리")
radio4 := difficultyGui.Add("Radio", "vRadio4 x20 y90", "4자리")
radio5 := difficultyGui.Add("Radio", "vRadio5 x20 y120", "5자리")
startBtn := difficultyGui.Add("Button", "x20 y160 w100 h30", "게임 시작")
startBtn.OnEvent("Click", StartGame)

difficultyGui.OnEvent("Close", (*) => ExitApp())
difficultyGui.Show()

; ------------------------------------------------------
; [2] 난이도 선택 후 메인 게임 GUI
; ------------------------------------------------------
StartGame(*)
{
    global digitCount, secretNumber, startTime, tryCount, digitStatusMap, hintUsed, tryHistory, mainGui, hBtn
    
    ; 난이도 설정
    diffValues := difficultyGui.Submit()
    if (diffValues.Radio3)
        digitCount := 3
    else if (diffValues.Radio4)
        digitCount := 4
    else
        digitCount := 5

    difficultyGui.Destroy()

    ; 게임 데이터 초기화
    tryCount := 0
    secretNumber := GenerateRandomNumber(digitCount)
    startTime := A_TickCount
    digitStatusMap := Map()
    tryHistory := []
    hintUsed := false

    ; 메인 게임 GUI 생성
    mainGui := Gui("+Resize", "숫자 야구 게임")
    mainGui.SetFont("s12")
    
    ; (A) 숫자 버튼
    mainGui.SetFont("bold")  ; 'wBold' 대신 'bold' 사용
    btn1 := mainGui.Add("Button", "x502 y129 w70 h70", "1")
    btn2 := mainGui.Add("Button", "x582 y129 w70 h70", "2")
    btn3 := mainGui.Add("Button", "x662 y129 w70 h70", "3")
    btn4 := mainGui.Add("Button", "x502 y209 w70 h70", "4")
    btn5 := mainGui.Add("Button", "x582 y209 w70 h70", "5")
    btn6 := mainGui.Add("Button", "x662 y209 w70 h70", "6")
    btn7 := mainGui.Add("Button", "x502 y289 w70 h70", "7")
    btn8 := mainGui.Add("Button", "x582 y289 w70 h70", "8")
    btn9 := mainGui.Add("Button", "x662 y289 w70 h70", "9")
    btn0 := mainGui.Add("Button", "x582 y369 w70 h70", "0")
    btnOk := mainGui.Add("Button", "x662 y369 w70 h70", "확인")
    btnDel := mainGui.Add("Button", "x502 y369 w70 h70", "Del")
    mainGui.SetFont("norm")  ; 'wNormal' 대신 'norm' 사용

    ; 숫자 버튼 이벤트 연결
    btn0.OnEvent("Click", (*) => AddDigitToInput("0"))
    btn1.OnEvent("Click", (*) => AddDigitToInput("1"))
    btn2.OnEvent("Click", (*) => AddDigitToInput("2"))
    btn3.OnEvent("Click", (*) => AddDigitToInput("3"))
    btn4.OnEvent("Click", (*) => AddDigitToInput("4"))
    btn5.OnEvent("Click", (*) => AddDigitToInput("5"))
    btn6.OnEvent("Click", (*) => AddDigitToInput("6"))
    btn7.OnEvent("Click", (*) => AddDigitToInput("7"))
    btn8.OnEvent("Click", (*) => AddDigitToInput("8"))
    btn9.OnEvent("Click", (*) => AddDigitToInput("9"))
    btnOk.OnEvent("Click", CheckGuess)
    btnDel.OnEvent("Click", Del)

    ; 숫자 버튼 핸들 저장
    hBtn := Map()
    hBtn["0"] := btn0.Hwnd
    hBtn["1"] := btn1.Hwnd
    hBtn["2"] := btn2.Hwnd
    hBtn["3"] := btn3.Hwnd
    hBtn["4"] := btn4.Hwnd
    hBtn["5"] := btn5.Hwnd
    hBtn["6"] := btn6.Hwnd
    hBtn["7"] := btn7.Hwnd
    hBtn["8"] := btn8.Hwnd
    hBtn["9"] := btn9.Hwnd

    ; (B) 입력 Edit
    userInput := mainGui.Add("Edit", "x542 y79 w140 h40")

    ; (C) 그룹박스
    mainGui.Add("GroupBox", "x482 y59 w270 h390", "숫자 입력")

    ; (D) 결과창 - Edit 컨트롤 사용 (RichEdit 대신)
    resultEdit := mainGui.Add("Edit", "x52 y59 w370 h590 +ReadOnly +Multi")
    ; 흰색 배경 설정
    resultEdit.Opt("Background" . Format("{:X}", 0xFFFFFF))

    ; (E) 메모용 Edit
    memoEdit := mainGui.Add("Edit", "x482 y469 w270 h180 +Multi")

    ; (F) 힌트 모드
    hintMode := mainGui.Add("CheckBox", "x652 y29 w80 h30", "힌트 모드")
    hintMode.OnEvent("Click", ToggleHint)

    ; (G) 점수보기 버튼
    scoreBtn := mainGui.Add("Button", "x752 y29 w80 h30", "점수보기")
    scoreBtn.OnEvent("Click", ShowScore)

    ; (H) 재시작 버튼
    restartBtn := mainGui.Add("Button", "x752 y69 w80 h30", "재시작")
    restartBtn.OnEvent("Click", RestartGame)

    ; (I) 룰 설명
    mainGui.Add("Text", "x52 y19 w400 h30", 
        "1) 컴퓨터는 중복되지 않는 숫자를 랜덤으로 선택합니다.`n" 
        "2) 플레이어는 해당 숫자를 추측하여 입력합니다.`n"
        "3) 숫자와 위치가 모두 맞으면 '스트라이크', 숫자만 맞으면 '볼', 틀리면 '아웃'입니다.`n"
        "4) 입력한 숫자는 중복될 수 없습니다.")

    ; (J) 경과 시간
    timeText := mainGui.Add("Text", "x332 y29 w160 h20", "경과 시간: 0초")

    ; 객체 참조 저장
    mainGui.userInput := userInput
    mainGui.resultEdit := resultEdit
    mainGui.memoEdit := memoEdit
    mainGui.hintMode := hintMode
    mainGui.timeText := timeText

    mainGui.OnEvent("Close", (*) => ExitApp())
    mainGui.Show()

    ; 타이머 시작
    SetTimer(UpdateTime, 1000)
}

; ------------------------------------------------------
; [3] 매 초마다 경과 시간 갱신
; ------------------------------------------------------
UpdateTime(*)
{
    global startTime, mainGui
    
    elapsed := Floor((A_TickCount - startTime) / 1000)
    minutes := Floor(elapsed / 60)
    seconds := Mod(elapsed, 60)
    mainGui.timeText.Value := "경과 시간: " . minutes . "분 " . seconds . "초"
}

; ------------------------------------------------------
; [4] 숫자를 입력창에 추가하는 함수
; ------------------------------------------------------
AddDigitToInput(digit)
{
    global digitCount, mainGui
    
    curValue := mainGui.userInput.Value
    curValue := curValue . digit
    
    if (StrLen(curValue) > digitCount)
    {
        MsgBox(digitCount . "자리까지만 입력 가능합니다.", "오류", 48)
        curValue := SubStr(curValue, 1, digitCount)
    }
    
    mainGui.userInput.Value := curValue
}

; ------------------------------------------------------
; [5] Del 버튼
; ------------------------------------------------------
Del(*)
{
    global mainGui
    
    curValue := mainGui.userInput.Value
    if (StrLen(curValue) > 0)
    {
        curValue := SubStr(curValue, 1, StrLen(curValue) - 1)
        mainGui.userInput.Value := curValue
    }
}

; ------------------------------------------------------
; [6] 확인 버튼 (판정)
; ------------------------------------------------------
CheckGuess(*)
{
    global mainGui, secretNumber, digitCount, tryCount, tryHistory, digitStatusMap, hintUsed
    
    userInput := mainGui.userInput.Value
    
    if (StrLen(userInput) != digitCount)
    {
        MsgBox(digitCount . "자리 숫자를 입력하세요.", "오류", 48)
        return
    }
    if (CheckDuplicate(userInput))
    {
        MsgBox("중복된 숫자가 있습니다. 다시 입력하세요.", "오류", 48)
        return
    }

    tryCount++

    ; 스트라이크/볼/아웃 계산
    strikeCount := 0
    ballCount := 0
    
    Loop Parse, userInput
    {
        currentDigit := A_LoopField
        pos := InStr(secretNumber, currentDigit)
        if (pos > 0)
        {
            if (pos = A_Index)
                strikeCount++
            else
                ballCount++
        }
    }
    outCount := digitCount - (strikeCount + ballCount)

    ; 숫자별 상태 업데이트 (스트라이크/볼/아웃)
    Loop Parse, userInput
    {
        currentDigit := A_LoopField
        pos := InStr(secretNumber, currentDigit)
        
        if (pos = 0)  ; 아웃인 경우
        {
            digitStatusMap[currentDigit] := "OUT"
        }
        else if (pos = A_Index)  ; 스트라이크인 경우
        {
            digitStatusMap[currentDigit] := "STRIKE"
        }
        else  ; 볼인 경우
        {
            ; 이미 STRIKE로 기록된 숫자가 있다면 상태를 변경하지 않음
            if (!digitStatusMap.Has(currentDigit) || digitStatusMap[currentDigit] != "STRIKE")
                digitStatusMap[currentDigit] := "BALL"
        }
    }

    ; 시도 기록에 추가
    tryInfo := {input: userInput, strike: strikeCount, ball: ballCount, out: outCount}
    tryHistory.Push(tryInfo)

    ; 결과창 업데이트
    UpdateResultDisplay()

    ; 정답 체크
    if (strikeCount = digitCount)
    {
        SetTimer(UpdateTime, 0)
        totalTime := Floor((A_TickCount - startTime) / 1000)
        finalScore := CalculateScore(totalTime, tryCount, hintUsed)
        GameOver(finalScore)
        return
    }

    ; 힌트 모드 갱신
    UpdateHintButtons()
    mainGui.userInput.Value := ""
}

; ------------------------------------------------------
; 결과창 업데이트 함수 (일반 Edit 사용, 상태 표기)
; ------------------------------------------------------
UpdateResultDisplay()
{
    global tryHistory, digitStatusMap, secretNumber, mainGui
    
    ; 결과창 초기화
    resultText := ""
    
    hintModeActive := mainGui.hintMode.Value
    
    ; 모든 시도 결과 표시
    For idx, gameEntry in tryHistory
    {
        ; 시도 번호 및 입력 숫자
        resultLine := "시도 " . idx . ": "
        
        ; 숫자 표시 (힌트 모드일 때 상태 표시)
        if (hintModeActive)
        {
            Loop Parse, gameEntry.input
            {
                currentDigit := A_LoopField
                pos := InStr(secretNumber, currentDigit)
                
                if (pos = 0)  ; 아웃
                {
                    resultLine .= currentDigit . "(X) "
                }
                else if (pos = A_Index)  ; 스트라이크
                {
                    resultLine .= currentDigit . "(S) "
                }
                else  ; 볼
                {
                    resultLine .= currentDigit . "(B) "
                }
            }
        }
        else
        {
            resultLine .= gameEntry.input
        }
        
        ; 결과 추가
        resultLine .= " => " . gameEntry.strike . " S, " . gameEntry.ball . " B, " . gameEntry.out . " O`r`n"
        
        resultText .= resultLine
    }
    
    ; 결과창에 표시
    mainGui.resultEdit.Value := resultText
}

; ------------------------------------------------------
; [7] 중복 없는 임의 숫자 생성
; ------------------------------------------------------
GenerateRandomNumber(count)
{
    randomNum := ""
    while (StrLen(randomNum) < count)
    {
        r := Random(0, 9)
        if !InStr(randomNum, r)
            randomNum := randomNum . r
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

; ------------------------------------------------------
; [9] 힌트 모드 체크박스
; ------------------------------------------------------
ToggleHint(*)
{
    global mainGui, hintUsed
    
    if (mainGui.hintMode.Value)
        hintUsed := true
        
    ; 버튼 색상 및 눌림 효과 업데이트
    UpdateHintButtons()
    
    ; 결과창 업데이트
    UpdateResultDisplay()
}

; ------------------------------------------------------
; 힌트 모드 버튼 색상 업데이트 함수
; ------------------------------------------------------
UpdateHintButtons()
{
    global digitStatusMap, hBtn, mainGui
    
    hintState := mainGui.hintMode.Value

    if (hintState)
    {
        ; 힌트 모드가 활성화된 경우 모든 숫자 버튼의 색상을 업데이트
        for btnDigit, btnHwnd in hBtn
        {
            control := GuiCtrlFromHwnd(btnHwnd)
            if (!control)
                continue
                
            if (digitStatusMap.Has(btnDigit))
            {
                btnStatus := digitStatusMap[btnDigit]
                
                if (btnStatus = "STRIKE")
                {
                    ; 스트라이크(위치+숫자 일치): 노란색 (FFD700)
                    control.Opt("+BackgroundFFD700")
                    ; 눌림 효과 설정
                    SendMessage(0xF3, 1, 0, , "ahk_id " . btnHwnd)  ; BM_SETSTATE = 0xF3
                }
                else if (btnStatus = "BALL")
                {
                    ; 볼(숫자만 일치): 초록색 (32CD32)
                    control.Opt("+Background32CD32")
                    ; 눌림 효과 설정
                    SendMessage(0xF3, 1, 0, , "ahk_id " . btnHwnd)  ; BM_SETSTATE = 0xF3
                }
                else if (btnStatus = "OUT")
                {
                    ; 아웃(완전 불일치): 어두운 붉은색 (B22222)
                    control.Opt("+BackgroundB22222")
                    ; 눌림 효과 해제
                    SendMessage(0xF3, 0, 0, , "ahk_id " . btnHwnd)
                }
            }
            else
            {
                ; 아직 시도하지 않은 숫자: 기본 배경색으로 복원
                control.Opt("+Background")
                ; 눌림 효과 해제
                SendMessage(0xF3, 0, 0, , "ahk_id " . btnHwnd)
            }
        }
    }
    else
    {
        ; 힌트 모드가 비활성화된 경우 모든 버튼을 기본 배경색으로 복원
        for btnDigit, btnHwnd in hBtn
        {
            control := GuiCtrlFromHwnd(btnHwnd)
            if (control)
            {
                control.Opt("+Background")
                ; 눌림 효과 해제
                SendMessage(0xF3, 0, 0, , "ahk_id " . btnHwnd)
            }
        }
    }
}

; ------------------------------------------------------
; 점수 계산 함수
; ------------------------------------------------------
CalculateScore(timeSecCalc, triesCalc, usedHintCalc)
{
    baseScoreCalc := 10000
    timePenaltyCalc := timeSecCalc * 3
    tryPenaltyCalc := (triesCalc - 1) * 300
    resultCalc := baseScoreCalc - timePenaltyCalc - tryPenaltyCalc
    
    if (usedHintCalc)
        resultCalc := Floor(resultCalc * 0.5)

    if (resultCalc < 0)
        resultCalc := 0
        
    return resultCalc
}

; ------------------------------------------------------
; 게임 종료 GUI - 닉네임 입력 & 로그 저장
; ------------------------------------------------------
GameOver(finalScore)
{
    global digitCount
    
    scoreGui := Gui("+AlwaysOnTop", "게임 종료")
    scoreGui.SetFont("s10")
    scoreGui.Add("Text", "x10 y10 w240", "게임 종료! 점수: " . finalScore)
    scoreGui.Add("Text", "x10 y40 w240", "닉네임을 입력하세요.(공백 없이)")
    playerNameEdit := scoreGui.Add("Edit", "x10 y70 w220")
    
    confirmBtn := scoreGui.Add("Button", "x10 y110 w80 h30", "확인")
    cancelBtn := scoreGui.Add("Button", "x+10 w80 h30", "취소")
    
    ; 익명 함수를 사용하여 매개변수 전달
    confirmBtn.OnEvent("Click", (*) => ConfirmScore(finalScore, playerNameEdit, scoreGui))
    cancelBtn.OnEvent("Click", (*) => (scoreGui.Destroy(), ExitApp()))
    
    scoreGui.OnEvent("Close", (*) => (scoreGui.Destroy(), ExitApp()))
    scoreGui.Show()
}

; "확인" 버튼 - 점수 저장 함수 수정
ConfirmScore(finalScore, playerNameEdit, scoreGui, *)
{
    global digitCount
    
    playerName := playerNameEdit.Value
    
    if (playerName = "")
    {
        MsgBox("닉네임을 입력하세요!", "경고", 48)
        return
    }

    cs_DateTime := FormatTime(, "yyyy-MM-dd_HH:mm")
    ; 로그 파일에 '난이도 n' 형식으로 표기
    cs_LogEntry := cs_DateTime . " " . playerName . " " . finalScore . " 난이도 " . digitCount
    
    ; 점수 저장 시도
    success := SaveScore(cs_LogEntry)
    
    ; 먼저 GUI 닫기
    scoreGui.Destroy()
    
    if (!success) {
        MsgBox("로그 파일에 점수를 저장할 수 없습니다. 기본 점수 파일을 사용합니다.", "알림", 48)
    }
    
    cs_NewRank := CalculateRank(playerName, finalScore, digitCount)
    
    MsgBox("점수가 등록되었습니다!`n현재 난이도(" . digitCount . ")에서 " . cs_NewRank . "위 입니다.", "등록 완료", 64)

    ; 자랑할지 묻기
    cs_MsgText := "현재 " . cs_NewRank . "위에 랭크되었습니다! 슬랙(Webhook)으로 자랑하시겠습니까?"
    if (MsgBox(cs_MsgText, "자랑하시겠습니까?", 4) = "Yes")
    {
        ; 웹후크에 '숫자야구_난이도 n' 형식으로 표기
        SendSlackWebhook("숫자야구_난이도 " . digitCount, playerName, cs_NewRank, finalScore)
    }

    RestartGame()
}

SaveScore(scoreEntry)
{
    global logFilePath
    
    try {
        ; 디렉토리가 존재하는지 확인
        pathInfo := SplitPath(logFilePath)
        outDir := pathInfo.Dir
        if (outDir && !DirExist(outDir))
            DirCreate(outDir)
            
        FileAppend(scoreEntry . "`r`n", logFilePath, "UTF-8")
        return true
    } catch {
        ; 기본 위치에 저장 시도
        try {
            logFilePath := A_ScriptDir . "\score_log.txt"
            FileAppend(scoreEntry . "`r`n", logFilePath, "UTF-8")
            return true
        } catch {
            return false
        }
    }
}
; ------------------------------------------------------
; 점수보기 버튼 (ShowScore)
; ------------------------------------------------------
ShowScore(*)
{
    global logFilePath, digitCount
    
    if !FileExist(logFilePath)
    {
        MsgBox("아직 점수 기록이 없습니다!", "오류", 16)
        return
    }

    try {
        ss_LogData := FileRead(logFilePath)
    } catch {
        MsgBox("점수 파일을 열 수 없습니다!", "오류", 16)
        return
    }

    ss_ScoreArray := []
    Loop Parse, ss_LogData, "`n", "`r"
    {
        ss_Line := Trim(A_LoopField)
        if (ss_Line = "")
            continue

        ss_Tokens := StrSplit(ss_Line, " ")
        if (ss_Tokens.Length < 5)
            continue

        ss_Dt := ss_Tokens[1]
        ss_Nick := ss_Tokens[2]
        ss_Score := ss_Tokens[3]
        ss_Diff := ss_Tokens[5]  ; 5번째 토큰이 난이도 숫자

        if (ss_Diff = digitCount)
        {
            ss_ScoreNum := ss_Score + 0
            ss_ScoreArray.Push({nick: ss_Nick, score: ss_ScoreNum, dt: ss_Dt})
        }
    }

    ss_ScoreArray := SortScoresAscending(ss_ScoreArray)

    ss_DisplayText := ""
    Loop 10
    {
        if (A_Index > ss_ScoreArray.Length)
            break
        ss_Item := ss_ScoreArray[A_Index]
        ss_DisplayText .= A_Index . "위 - " . ss_Item.nick
            . " (" . ss_Item.score . "점, " . ss_Item.dt . ")" . "`r`n"
    }

    if (ss_DisplayText = "")
        ss_DisplayText := "해당 난이도의 기록이 없습니다."

    scoreDisplayGui := Gui("+AlwaysOnTop", "점수 목록 (난이도 " . digitCount . ")")
    scoreDisplayGui.Add("Edit", "r10 w300 ReadOnly", ss_DisplayText)
    scoreDisplayGui.Show()
}

; ------------------------------------------------------
; 점수 오름차순 정렬 함수
; ------------------------------------------------------
SortScoresAscending(sort_Arr)
{
    sort_Cnt := sort_Arr.Length
    
    if (sort_Cnt <= 1)
        return sort_Arr
        
    Loop sort_Cnt - 1
    {
        sort_Idx := A_Index
        Loop sort_Cnt - sort_Idx
        {
            sort_J := A_Index
            if (sort_Arr[sort_J].score > sort_Arr[sort_J+1].score)
            {
                sort_Temp := sort_Arr[sort_J]
                sort_Arr[sort_J] := sort_Arr[sort_J+1]
                sort_Arr[sort_J+1] := sort_Temp
            }
        }
    }
    return sort_Arr
}

; ------------------------------------------------------
; 랭킹 계산 함수 (난이도별 오름차순)
; ------------------------------------------------------
CalculateRank(cr_PlayerName, cr_PlayerScore, cr_Diff)
{
    global logFilePath
    
    if !FileExist(logFilePath)
        return 1

    try {
        cr_LogData := FileRead(logFilePath)
    } catch {
        return 1
    }

    cr_TempArr := []
    Loop Parse, cr_LogData, "`n", "`r"
    {
        cr_Line := Trim(A_LoopField)
        if (cr_Line = "")
            continue

        cr_Tokens := StrSplit(cr_Line, " ")
        if (cr_Tokens.Length < 5)  ; 토큰 수가 최소 5개 이상이어야 함
            continue

        cr_Dt := cr_Tokens[1]
        cr_Nick := cr_Tokens[2]
        cr_Score := cr_Tokens[3]
        ; '난이도' 단어와 숫자를 분리하여 처리
        cr_Difficulty := cr_Tokens[5]  ; 이제 '난이도' 뒤의 숫자가 5번째 토큰

        if (cr_Difficulty = cr_Diff)
        {
            cr_ScoreNum := cr_Score + 0
            cr_TempArr.Push({nick: cr_Nick, score: cr_ScoreNum})
        }
    }

    cr_TempArr := SortScoresAscending(cr_TempArr)

    for cr_Idx, cr_Item in cr_TempArr
    {
        if (cr_Item.nick = cr_PlayerName && cr_Item.score = cr_PlayerScore)
            return cr_Idx
    }
    return cr_TempArr.Length + 1
}

; ------------------------------------------------------
; 슬랙 웹후크 전송 (JSON 키 맞추기)
; ------------------------------------------------------
SendSlackWebhook(gameName, gameGamerId, gameRank, gameScore)
{
    webhookUrl := "https://hooks.slack.com/triggers/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"

    ; JSON 데이터 생성
    jsonData := '{"game_gamerid":"' . gameGamerId
             . '", "game_rank":"' . gameRank
             . '", "game_name":"' . gameName
             . '", "game_score":"' . gameScore
             . '"}'

    try {
        xhr := ComObject("Msxml2.XMLHTTP")
        xhr.Open("POST", webhookUrl, false)
        xhr.setRequestHeader("Content-Type", "application/json;charset=utf-8")
        xhr.Send(jsonData)
    } catch {
        MsgBox("슬랙 알림 전송에 실패했습니다.", "오류", 16)
    }
}

; ------------------------------------------------------
; 게임 재시작 함수
; ------------------------------------------------------
RestartGame(*)
{
    global digitCount, secretNumber, startTime, tryCount, digitStatusMap, hintUsed, tryHistory, mainGui, hBtn
    
    ; 게임 데이터 초기화
    tryCount := 0
    secretNumber := GenerateRandomNumber(digitCount)
    startTime := A_TickCount
    digitStatusMap := Map()
    tryHistory := []
    hintUsed := false
    
    ; GUI 컨트롤 초기화
    mainGui.resultEdit.Value := ""  ; 결과창 비우기
    mainGui.userInput.Value := ""   ; 입력창 비우기
    mainGui.memoEdit.Value := ""    ; 메모창 비우기
    mainGui.hintMode.Value := 0     ; 힌트모드 해제
    
    ; 힌트 버튼 색상 초기화
    for btnDigit, btnHwnd in hBtn
    {
        control := GuiCtrlFromHwnd(btnHwnd)
        if (control)
        {
            control.Opt("+Background")
            ; 눌림 효과 해제
            SendMessage(0xF3, 0, 0, , "ahk_id " . btnHwnd)
        }
    }
    
    ; 타이머 재시작
    SetTimer(UpdateTime, 1000)
}