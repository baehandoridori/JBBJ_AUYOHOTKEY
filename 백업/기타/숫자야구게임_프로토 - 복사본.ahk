#NoEnv
#Warn
#SingleInstance Force

; ------------------------------------------------------
; [1] 전역 변수
; ------------------------------------------------------
global secretNumber   := ""
global digitCount     := 3
global startTime      := 0
global tryCount       := 0

; 점수 로그 경로
global logFilePath := "G:\공유 드라이브\...\score_log.txt"

; 힌트 사용 여부
global hintUsed := false

; 스트라이크/볼로 확인된 숫자
global discoveredDigitsSet := {}

; ------------------------------------------------------
; 난이도 선택 GUI (#1)
; ------------------------------------------------------
Gui, +AlwaysOnTop +LabelDiffGui
Gui, Font, s10
Gui, Add, Text, x20 y20 w280 h30, 숫자 야구 난이도를 선택하세요.

Gui, Add, Radio, vRadio3 Checked x20 y60, 3자리
Gui, Add, Radio, vRadio4          x20 y90, 4자리
Gui, Add, Radio, vRadio5          x20 y120, 5자리
Gui, Add, Button, x20 y160 w100 h30 gStartGame, 게임 시작
Gui, Show,, 난이도 선택
return

DiffGuiGuiClose:
ExitApp

; ------------------------------------------------------
; [2] 난이도 선택 후 메인 게임 GUI
; ------------------------------------------------------
StartGame:
Gui, Submit, NoHide
if (Radio3 = 1)
    digitCount := 3
else if (Radio4 = 1)
    digitCount := 4
else
    digitCount := 5

Gui, Destroy

tryCount := 0
secretNumber := GenerateRandomNumber(digitCount)
startTime := A_TickCount
discoveredDigitsSet := {}
hintUsed := false

Gui, 2: +LabelGameGui
Gui, 2: Font, s12

; (A) 숫자 버튼
Gui, 2: Font, wBold
Gui, 2: Add, Button, x502 y129 w70 h70 gDigit1 vBtn1, 1
Gui, 2: Add, Button, x582 y129 w70 h70 gDigit2 vBtn2, 2
Gui, 2: Add, Button, x662 y129 w70 h70 gDigit3 vBtn3, 3
Gui, 2: Add, Button, x502 y209 w70 h70 gDigit4 vBtn4, 4
Gui, 2: Add, Button, x582 y209 w70 h70 gDigit5 vBtn5, 5
Gui, 2: Add, Button, x662 y209 w70 h70 gDigit6 vBtn6, 6
Gui, 2: Add, Button, x502 y289 w70 h70 gDigit7 vBtn7, 7
Gui, 2: Add, Button, x582 y289 w70 h70 gDigit8 vBtn8, 8
Gui, 2: Add, Button, x662 y289 w70 h70 gDigit9 vBtn9, 9
Gui, 2: Add, Button, x582 y369 w70 h70 gDigit0 vBtn0, 0
Gui, 2: Add, Button, x662 y369 w70 h70 gCheckGuess, 확인
Gui, 2: Add, Button, x502 y369 w70 h70 gDel, Del
Gui, 2: Font, wNormal

; (B) 입력 Edit
Gui, 2: Add, Edit, x542 y79 w140 h40 vUserInput

; (C) 그룹박스
Gui, 2: Add, GroupBox, x482 y59 w270 h390, 숫자 입력

; (D) 결과창 (글자 검정, 배경 흰색)
Gui, 2: Add, Edit, x52 y59 w370 h590 vResultEdit +ReadOnly cBlack

; (E) 메모용 Edit
Gui, 2: Add, Edit, x482 y469 w270 h180 vMemoEdit

; (F) 힌트 모드
Gui, 2: Add, CheckBox, x652 y29 w80 h30 vHintMode gToggleHint, 힌트 모드

; (G) 점수보기 버튼
Gui, 2: Add, Button, x752 y29 w80 h30 gShowScore, 점수보기

Gui, 2: Add, Button, x752 y69 w80 h30 gRestartGame, 재시작

; (H) 룰 설명
Gui, 2: Add, Text, x52 y19 w230 h30,
(
1) 컴퓨터는 중복되지 않는 숫자를 랜덤으로 선택합니다.
2) 플레이어는 해당 숫자를 추측하여 입력합니다.
3) 숫자와 위치가 모두 맞으면 '스트라이크', 숫자만 맞으면 '볼', 틀리면 '아웃'입니다.
4) 입력한 숫자는 중복될 수 없습니다.
)

; (I) 경과 시간
Gui, 2: Add, Text, x332 y29 w160 h20 vTimeText, 경과 시간: 0초

Gui, 2: Show, , 숫자 야구 게임

; 결과창 배경 흰색(EM_SETBKGNDCOLOR)
GuiControlGet, hEdit, 2: Hwnd, ResultEdit
if (hEdit)
    SendMessage, 0x701, 0, 0xFFFFFF,, ahk_id %hEdit%

; 숫자 버튼 HWND 수집
global hBtn := {}
For k, v in ["Btn0","Btn1","Btn2","Btn3","Btn4","Btn5","Btn6","Btn7","Btn8","Btn9"]
{
    GuiControlGet, tempHwnd, 2: Hwnd, %v%
    hBtn[SubStr(v,4)] := tempHwnd
}

SetTimer, UpdateTime, 1000
return

GameGuiGuiClose:
ExitApp

; ------------------------------------------------------
; [3] 매 초마다 경과 시간 갱신
; ------------------------------------------------------
UpdateTime:
elapsed := Floor((A_TickCount - startTime) / 1000)
minutes := Floor(elapsed / 60)
seconds := Mod(elapsed, 60)
GuiControl, 2:, TimeText, 경과 시간: %minutes%분 %seconds%초
return

; ------------------------------------------------------
; [4] 숫자 버튼 클릭 시
; ------------------------------------------------------
Digit0:
Digit1:
Digit2:
Digit3:
Digit4:
Digit5:
Digit6:
Digit7:
Digit8:
Digit9:
GuiControlGet, curValue, 2:, UserInput
curValue .= SubStr(A_ThisLabel, 6)  ; Digit0 -> "0", Digit1 -> "1", ...
if (StrLen(curValue) > digitCount)
{
    MsgBox, 0x4030, 오류, %digitCount%자리까지만 입력 가능합니다.
    curValue := SubStr(curValue, 1, digitCount)
}
GuiControl, 2:, UserInput, %curValue%
return

; ------------------------------------------------------
; [5] Del 버튼
; ------------------------------------------------------
Del:
GuiControlGet, curValue, 2:, UserInput
if (StrLen(curValue) > 0)
{
    curValue := SubStr(curValue, 1, StrLen(curValue) - 1)
    GuiControl, 2:, UserInput, %curValue%
}
return

; ------------------------------------------------------
; [6] 확인 버튼 (판정)
; ------------------------------------------------------
CheckGuess:
GuiControlGet, userInput, 2:, UserInput
if (StrLen(userInput) != digitCount)
{
    MsgBox, 0x4030, 오류, %digitCount%자리 숫자를 입력하세요.
    return
}
if (CheckDuplicate(userInput))
{
    MsgBox, 0x4030, 오류, 중복된 숫자가 있습니다. 다시 입력하세요.
    return
}

tryCount++

; 스트라이크/볼/아웃 계산
strikeCount := 0
ballCount := 0
Loop, Parse, userInput
{
    digit := A_LoopField
    pos := InStr(secretNumber, digit)
    if (pos > 0)
    {
        if (pos = A_Index)
            strikeCount++
        else
            ballCount++
    }
}
outCount := digitCount - (strikeCount + ballCount)

; 발견된 숫자 등록
Loop, Parse, userInput
{
    curDigit := A_LoopField
    pos := InStr(secretNumber, curDigit)
    if (pos > 0)
        discoveredDigitsSet[curDigit] := true
}

; 결과창
GuiControlGet, curResult, 2:, ResultEdit
newLine := "시도 " tryCount ": " userInput " => " strikeCount " S, " ballCount " B, " outCount " O`r`n"
GuiControl, 2:, ResultEdit, % curResult . newLine

; 정답 체크
if (strikeCount = digitCount)
{
    SetTimer, UpdateTime, Off
    totalTime := Floor((A_TickCount - startTime) / 1000)
    finalScore := CalculateScore(totalTime, tryCount, hintUsed)
    GameOver(finalScore)
    return
}

; 힌트 모드 갱신
UpdateHintButtons()
GuiControl, 2:, UserInput
return

; ------------------------------------------------------
; [7] 중복 없는 임의 숫자 생성
; ------------------------------------------------------
GenerateRandomNumber(count)
{
    randomNum := ""
    while (StrLen(randomNum) < count)
    {
        Random, r, 0, 9
        if !InStr(randomNum, r)
            randomNum .= r
    }
    return randomNum
}

; ------------------------------------------------------
; [8] 문자열 중복 검사
; ------------------------------------------------------
CheckDuplicate(str)
{
    Loop, Parse, str
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
ToggleHint:
GuiControlGet, hint_State, 2:, HintMode
if (hint_State = 1)
    hintUsed := true
UpdateHintButtons()
return

; ------------------------------------------------------
; 힌트 모드 버튼 눌림 표시 함수
; ------------------------------------------------------
UpdateHintButtons()
{
    global discoveredDigitsSet, hBtn
    
    GuiControlGet, uhb_HintState, 2:, HintMode

    if (uhb_HintState = 1)
    {
        for eDigitCalc, hControlCalc in hBtn
        {
            if (discoveredDigitsSet.HasKey(eDigitCalc))
                SendMessage, 0xF3, 1, 0,, ahk_id %hControlCalc%
            else
                SendMessage, 0xF3, 0, 0,, ahk_id %hControlCalc%
        }
    }
    else
    {
        for eDigitCalc, hControlCalc in hBtn
        {
            SendMessage, 0xF3, 0, 0,, ahk_id %hControlCalc%
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
    tryPenaltyCalc  := (triesCalc - 1) * 300
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
    Gui, ScoreInput:New, +AlwaysOnTop +LabelScoreInputGui
    Gui, Font, s10
    Gui, ScoreInput:Add, Text, x10 y10 w240, 게임 종료! 점수: %finalScore%
    Gui, ScoreInput:Add, Text, x10 y40 w240, 닉네임을 입력하세요.(공백 없이)
    Gui, ScoreInput:Add, Edit, x10 y70 w220 vPlayerName
    Gui, ScoreInput:Add, Button, x10 y110 w80 h30 gConfirmScore, 확인
    Gui, ScoreInput:Add, Button, x+10 w80 h30 gCancelScoreLabel, 취소

    global g_finalScore := finalScore
    Gui, ScoreInput:Show, w250 h160, 게임 종료
}

ScoreInputGuiClose:
    ; x 버튼 → 취소
    GoSub, CancelScoreLabel
return

; "취소" 버튼
CancelScoreLabel:
CancelScoreFunc()
return

CancelScoreFunc()
{
    Gui, ScoreInput:Destroy
    ExitApp
}

; "확인" 버튼
ConfirmScore:
{
    global logFilePath, g_finalScore, digitCount
    Gui, ScoreInput:Submit, NoHide

    if (PlayerName = "")
    {
        MsgBox, 48, 경고, 닉네임을 입력하세요!
        return
    }

    FormatTime, cs_DateTime,, yyyy-MM-dd_HH:mm
    cs_LogEntry := cs_DateTime . " " . PlayerName . " " . g_finalScore . " " . digitCount
    FileAppend, %cs_LogEntry%`r`n, %logFilePath%, UTF-8

    cs_NewRank := CalculateRank(PlayerName, g_finalScore, digitCount)

    ; 한 줄로 작성해야 "This line does not contain a recognized action" 에러 안 뜸
    MsgBox, 4160, 등록 완료, 점수가 등록되었습니다!`n현재 난이도(%digitCount%)에서 %cs_NewRank%위 입니다.

    Gui, ScoreInput:Destroy

    ; 자랑할지 묻기 (한 줄로 정리 or 변수로)
    cs_MsgText := "현재 " . cs_NewRank . "위에 랭크되었습니다! 슬랙(Webhook)으로 자랑하시겠습니까?"
    MsgBox, 4, 자랑하시겠습니까?, %cs_MsgText%
    IfMsgBox Yes
    {
        ; 예: "숫자야구" = game_name, PlayerName = game_gamerid, g_finalScore = game_score, cs_NewRank = game_rank
        SendSlackWebhook("숫자야구", PlayerName, cs_NewRank, g_finalScore)
    }

    Gui, ScoreInput:Destroy
    RestartGame()  ; 새로운 함수 호출
}

; ------------------------------------------------------
; 점수보기 버튼 (ShowScore)
; ------------------------------------------------------
ShowScore:
{
    global logFilePath, digitCount
    
    if !FileExist(logFilePath)
    {
        MsgBox, 16, 오류, 아직 점수 기록이 없습니다!
        return
    }

    FileRead, ss_LogData, %logFilePath%
    if (ErrorLevel)
    {
        MsgBox, 16, 오류, 점수 파일을 열 수 없습니다!
        return
    }

    ss_ScoreArray := []
    Loop, Parse, ss_LogData, `n, `r
    {
        ss_Line := Trim(A_LoopField)
        if (ss_Line = "")
            continue

        ss_Tokens := StrSplit(ss_Line, " ")
        if (ss_Tokens.Length() < 4)
            continue

        ss_Dt   := ss_Tokens[1]
        ss_Nick := ss_Tokens[2]
        ss_Score := ss_Tokens[3]
        ss_Diff := ss_Tokens[4]

        if (ss_Diff = digitCount)
        {
            ss_ScoreNum := ss_Score + 0
            ss_ScoreArray.Push({nick: ss_Nick, score: ss_ScoreNum, dt: ss_Dt})
        }
    }

    ss_ScoreArray := SortScoresAscending(ss_ScoreArray)

    ss_DisplayText := ""
    Loop, 10
    {
        if (A_Index > ss_ScoreArray.Length())
            break
        ss_Item := ss_ScoreArray[A_Index]
        ss_DisplayText .= A_Index . "위 - " . ss_Item.nick
            . " (" . ss_Item.score . "점, " . ss_Item.dt . ")" . "`r`n"
    }

    if (ss_DisplayText = "")
        ss_DisplayText := "해당 난이도의 기록이 없습니다."

    Gui, ScoreDisplay:New, +AlwaysOnTop
    Gui, ScoreDisplay:Add, Edit, r10 w300 ReadOnly, %ss_DisplayText%
    Gui, ScoreDisplay:Show, , 점수 목록 (난이도 %digitCount%)
}
return

; ------------------------------------------------------
; 점수 오름차순 정렬 함수
; ------------------------------------------------------
SortScoresAscending(sort_Arr)
{
    sort_Cnt := sort_Arr.Length()
    Loop, % sort_Cnt - 1
    {
        sort_Idx := A_Index
        Loop, % sort_Cnt - sort_Idx
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

    FileRead, cr_LogData, %logFilePath%
    if (ErrorLevel)
        return 1

    cr_TempArr := []
    Loop, Parse, cr_LogData, `n, `r
    {
        cr_Line := Trim(A_LoopField)
        if (cr_Line = "")
            continue

        cr_Tokens := StrSplit(cr_Line, " ")
        if (cr_Tokens.Length() < 4)
            continue

        cr_Dt   := cr_Tokens[1]
        cr_Nick := cr_Tokens[2]
        cr_Score := cr_Tokens[3]
        cr_Difficulty := cr_Tokens[4]

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
    return cr_TempArr.Length() + 1
}

; ------------------------------------------------------
; 슬랙 웹후크 전송 (JSON 키 맞추기)
; ------------------------------------------------------
SendSlackWebhook(gameName, gameGamerId, gameRank, gameScore)
{
    /*
      원하는 JSON 구조 (예시):
      {
        "game_gamerid": "...",
        "game_rank": "...",
        "game_name": "...",
        "game_score": "..."
      }
    */

    webhookUrl := "https://hooks.slack.com/triggers/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"

    ; AHK에서 따옴표(")를 넣기 위해선 "" 로 Escape
    jsonData := "{""game_gamerid"":""" gameGamerId
             . """, ""game_rank"":""" gameRank
             . """, ""game_name"":""" gameName
             . """, ""game_score"":""" gameScore
             . """}"

    req := ComObjCreate("Msxml2.XMLHTTP")
    req.Open("POST", webhookUrl, false)
    req.setRequestHeader("Content-Type","application/json;charset=utf-8")
    req.Send(jsonData)
}

; ------------------------------------------------------
; 게임 재시작 레이블
; ------------------------------------------------------
RestartGame:
    RestartGame()
return

; ------------------------------------------------------
; 게임 재시작 함수
; ------------------------------------------------------
RestartGame()
{
    global digitCount, tryCount, startTime, hintUsed
    
    ; 게임 데이터 초기화
    tryCount := 0
    secretNumber := GenerateRandomNumber(digitCount)
    startTime := A_TickCount
    discoveredDigitsSet := {}
    hintUsed := false
    
    ; GUI 컨트롤 초기화
    GuiControl, 2:, ResultEdit, ; 결과창 비우기
    GuiControl, 2:, UserInput,  ; 입력창 비우기
    GuiControl, 2:, MemoEdit,   ; 메모창 비우기
    GuiControl, 2:, HintMode, 0 ; 힌트모드 해제
    
    ; 힌트 버튼 표시 갱신
    UpdateHintButtons()
    
    ; 타이머 재시작
    SetTimer, UpdateTime, 1000
}