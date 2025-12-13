#Persistent
#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1

; 글로벌 변수 선언
global s_width := 20, s_height := 20, cell_size := 20
global snake := [{x: 5, y: 7}], dir := "RIGHT", food := {}, score := 0
global game_over := false, paused := false, snake_game_running := false
global game_started := false
global ScoreText, GameStateText, GameCanvas, SnakeGameHwnd
global logFilePath := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\JBBJ_게임\JBBJ_게임_게임스코어\스네이크게임 스코어\score_log.txt"

SetTimer, StartGame, -100
return

StartGame:
    RunSnakeGame()
return

RunSnakeGame() {
    global s_width, s_height, cell_size, snake, dir, food, score, game_over, paused, snake_game_running, game_started
    global ScoreText, GameStateText, GameCanvas, SnakeGameHwnd

    snake_game_running := true
    snake := [{x: 5, y: 7}]
    dir := "RIGHT"
    food := {}
    score := 0
    game_over := false
    paused := false
    game_started := false

    Gui, SnakeGame:New, +Resize +LastFound
    SnakeGameHwnd := WinExist()
    Gui, SnakeGame:Add, Text, x10 y10 w200 vScoreText, 점수: 0
    Gui, SnakeGame:Add, Text, x10 y+5 w200 vGameStateText, 방향키를 눌러 게임을 시작하세요.
    Gui, SnakeGame:Add, Button, x10 y+5 w100 gRestartGameButton, 재시작
    Gui, SnakeGame:Add, Button, x+10 w100 gShowScore, 점수 확인
    Gui, SnakeGame:Add, Button, x+10 w100 gCloseSnakeGameButton, 닫기

    canvas_width := s_width * cell_size
    canvas_height := s_height * cell_size
    Gui, SnakeGame:Add, Picture, x10 y+10 w%canvas_width% h%canvas_height% vGameCanvas

    total_width := canvas_width + 20
    total_height := canvas_height + 100
    Gui, SnakeGame:Show, w%total_width% h%total_height%, 스네이크 게임

    SetTimer, UpdateGame, 100

    GenerateFood()

    EnableSnakeHotkeys()
}

EnableSnakeHotkeys() {
    Hotkey, IfWinActive, ahk_id %SnakeGameHwnd%
    Hotkey, Up, SnakeUp, On
    Hotkey, Down, SnakeDown, On
    Hotkey, Left, SnakeLeft, On
    Hotkey, Right, SnakeRight, On
    Hotkey, p, TogglePause, On
    Hotkey, r, RestartGameHotkey, On
    Hotkey, IfWinActive
}

DisableSnakeHotkeys() {
    Hotkey, IfWinActive, ahk_id %SnakeGameHwnd%
    Hotkey, Up, Off
    Hotkey, Down, Off
    Hotkey, Left, Off
    Hotkey, Right, Off
    Hotkey, p, Off
    Hotkey, r, Off
    Hotkey, IfWinActive
}

SnakeGameGuiClose:
CloseSnakeGame:
    EndSnakeGame()
return

EndSnakeGame() {
    global snake_game_running, SnakeGameHwnd
    SetTimer, UpdateGame, Off
    DisableSnakeHotkeys()
    snake_game_running := false
    Gui, SnakeGame:Destroy
    SnakeGameHwnd := ""
    ExitApp  ; 스크립트 완전 종료
}

CloseSnakeGameButton:
    EndSnakeGame()
return

UpdateGame:
    if (!snake_game_running || game_over || paused || !game_started)
        return

    head := snake[1]
    new_head := {x: head.x, y: head.y}

    if (dir = "UP")
        new_head.y--
    else if (dir = "DOWN")
        new_head.y++
    else if (dir = "LEFT")
        new_head.x--
    else if (dir = "RIGHT")
        new_head.x++

    if (new_head.x < 0 || new_head.x >= s_width || new_head.y < 0 || new_head.y >= s_height) {
        game_over := true
        GameOver()
        return
    }

    for i, segment in snake {
        if (segment.x = new_head.x && segment.y = new_head.y) {
            game_over := true
            GameOver()
            return
        }
    }

    snake.InsertAt(1, new_head)

    if (new_head.x = food.x && new_head.y = food.y) {
        score++
        GuiControl, SnakeGame:, ScoreText, 점수: %score%
        GenerateFood()
    } else {
        snake.RemoveAt(snake.Length())
    }

    DrawGame()
return

SnakeUp:
    if (dir != "DOWN" && !paused) {
        if (!game_started) {
            StartGame()
        }
        dir := "UP"
    }
return

SnakeDown:
    if (dir != "UP" && !paused) {
        if (!game_started) {
            StartGame()
        }
        dir := "DOWN"
    }
return

SnakeLeft:
    if (dir != "RIGHT" && !paused) {
        if (!game_started) {
            StartGame()
        }
        dir := "LEFT"
    }
return

SnakeRight:
    if (dir != "LEFT" && !paused) {
        if (!game_started) {
            StartGame()
        }
        dir := "RIGHT"
    }
return

StartGame() {
    global game_started
    game_started := true
    GuiControl, SnakeGame:, GameStateText, 게임 중
}

TogglePause:
    paused := !paused
    if (paused)
        GuiControl, SnakeGame:, GameStateText, 일시정지. P 를 눌러 이어하세요.
    else
        GuiControl, SnakeGame:, GameStateText, 게임 중
return

RestartGameButton:
RestartGameHotkey:
    RestartGame()
return

RestartGame() {
    global snake, dir, score, game_over, paused, game_started
    snake := [{x: 5, y: 7}]
    dir := "RIGHT"
    score := 0
    game_over := false
    paused := false
    game_started := false
    GuiControl, SnakeGame:, ScoreText, 점수: 0
    GuiControl, SnakeGame:, GameStateText, 방향키를 눌러 게임을 시작하세요.
    GenerateFood()
    DrawGame()
}

GenerateFood() {
    global s_width, s_height, snake, food
    Loop {
        Random, food_x, 0, % s_width - 1
        Random, food_y, 0, % s_height - 1
        food := {x: food_x, y: food_y}
        valid := true
        for i, segment in snake {
            if (segment.x = food.x && segment.y = food.y) {
                valid := false
                break
            }
        }
        if (valid)
            break
    }
}

DrawGame() {
    global s_width, s_height, cell_size, snake, food, SnakeGameHwnd

    canvas_width := s_width * cell_size
    canvas_height := s_height * cell_size

    hdc := DllCall("CreateCompatibleDC", "Ptr", 0)
    hbm := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", canvas_width, "Int", canvas_height)
    obm := DllCall("SelectObject", "Ptr", hdc, "Ptr", hbm)

    VarSetCapacity(rect, 16, 0)
    NumPut(canvas_width, rect, 8, "Int")
    NumPut(canvas_height, rect, 12, "Int")
    hBrush := DllCall("CreateSolidBrush", "UInt", 0xFFFFFF)
    DllCall("FillRect", "Ptr", hdc, "Ptr", &rect, "Ptr", hBrush)
    DllCall("DeleteObject", "Ptr", hBrush)

    hBrush := DllCall("CreateSolidBrush", "UInt", 0x00FF00)
    for i, segment in snake {
        x := segment.x * cell_size
        y := segment.y * cell_size
        VarSetCapacity(rect, 16, 0)
        NumPut(x, rect, 0, "Int")
        NumPut(y, rect, 4, "Int")
        NumPut(x + cell_size, rect, 8, "Int")
        NumPut(y + cell_size, rect, 12, "Int")
        DllCall("FillRect", "Ptr", hdc, "Ptr", &rect, "Ptr", hBrush)
    }
    DllCall("DeleteObject", "Ptr", hBrush)

    hBrush := DllCall("CreateSolidBrush", "UInt", 0xFF0000)
    x := food.x * cell_size
    y := food.y * cell_size
    VarSetCapacity(rect, 16, 0)
    NumPut(x, rect, 0, "Int")
    NumPut(y, rect, 4, "Int")
    NumPut(x + cell_size, rect, 8, "Int")
    NumPut(y + cell_size, rect, 12, "Int")
    DllCall("FillRect", "Ptr", hdc, "Ptr", &rect, "Ptr", hBrush)
    DllCall("DeleteObject", "Ptr", hBrush)

    GuiControlGet, hwnd, SnakeGame:Hwnd, GameCanvas
    hdc_dest := DllCall("GetDC", "Ptr", hwnd)
    DllCall("BitBlt", "Ptr", hdc_dest, "Int", 0, "Int", 0, "Int", canvas_width, "Int", canvas_height, "Ptr", hdc, "Int", 0, "Int", 0, "UInt", 0xCC0020)
    DllCall("ReleaseDC", "Ptr", hwnd, "Ptr", hdc_dest)

    DllCall("SelectObject", "Ptr", hdc, "Ptr", obm)
    DllCall("DeleteObject", "Ptr", hbm)
    DllCall("DeleteDC", "Ptr", hdc)
}

GameOver() {
    global score, PlayerName

    Gui, ScoreInput:New, +AlwaysOnTop
    Gui, ScoreInput:Add, Text, x10 y10 w250, 게임 오버! 점수: %score%
    Gui, ScoreInput:Add, Text, x10 y+30 w250, 이름을 입력하세요:
    Gui, ScoreInput:Add, Edit, x10 y+60 w200 vPlayerName
    Gui, ScoreInput:Add, Button, x10 y+100 w80 gConfirmScore, 확인
    Gui, ScoreInput:Add, Button, x+10 w80 gCancelScore, 취소
    Gui, ScoreInput:Show
}

ConfirmScore() {
    global score, logFilePath, PlayerName

    Gui, ScoreInput:Submit, NoHide
    if (PlayerName = "") {
        MsgBox, 262144, 경고, 이름을 입력하세요!
        return
    }

    FormatTime, currentTime,, yyyyMMdd_HHmmss
    logEntry := currentTime . "_" . PlayerName . ", " . score

    FileAppend, %logEntry%`n, %logFilePath%

    MsgBox, 262208, 등록 성공, 점수가 성공적으로 등록되었습니다!

    Gui, ScoreInput:Destroy

    ; === [NEW/ADD] ===
    ; 1) 여기서 랭킹 계산
    newRank := CalculateRank(PlayerName, score)

    ; === [NEW/ADD] ===
    ; 2) 자랑하시겠습니까? -> 예/아니오
    ; MsgBox, 4 : Yes/No 메시지박스
    MsgBox, 4, 자랑하시겠습니까?, 현재 %newRank%위에 랭크되었습니다! 자랑(공유)하시겠습니까?
    IfMsgBox Yes
    {
        ; 예라면 웹후크 전송
        SendSlackWebhook("스네이크게임", PlayerName, score, newRank)
    }
    ; 아니오(No)라면 아무것도 안 하고 넘어감

    ; === [MODIFIED] ===
    ; 3) 이후 기존 로직대로 게임 재시작
    RestartGame()
}

CancelScore() {
    MsgBox, 262180, 점수 등록 취소, 점수를 등록하지 않을건가요?
    IfMsgBox Yes
    {
        Gui, ScoreInput:Destroy
        RestartGame()
    }
    Else
    {
        return
    }
}

ShowScore:
    global logFilePath

    if !FileExist(logFilePath) {
        MsgBox, 16, 오류, 점수 기록이 없습니다!
        return
    }

    FileRead, logData, %logFilePath%
    scoreList := []

    Loop, Parse, logData, `n, `r
    {
        If (A_LoopField <> "") {
            parts := StrSplit(A_LoopField, ",")
            if (parts.Length() >= 2) {
                name := RegExReplace(parts[1], ".*_(.+)$", "$1")
                score := Trim(parts[2])
                scoreList.Push({name: name, score: score})
            }
        }
    }

    scoreList := SortScores(scoreList)

    topScores := ""
    Loop, 10
    {
        If (A_Index > scoreList.Length())
            Break
        topScores .= A_Index . ". " . scoreList[A_Index].name . ": " . scoreList[A_Index].score . "`n"
    }

    Gui, ScoreDisplay:New, +AlwaysOnTop
    Gui, ScoreDisplay:Add, Edit, r10 w300 ReadOnly, %topScores%
    Gui, ScoreDisplay:Show
return

SortScores(scoreList) {
    n := scoreList.Length()
    Loop, % n - 1
    {
        i := A_Index
        Loop, % n - i
        {
            j := A_Index + i
            if (scoreList[j].score > scoreList[i].score) {
                temp := scoreList[i]
                scoreList[i] := scoreList[j]
                scoreList[j] := temp
            }
        }
    }
    return scoreList
}

; === [NEW/ADD] ===
; 1) 점수 랭킹을 계산해주는 함수
CalculateRank(playerName, playerScore)
{
    ; 이 함수는 로그 파일을 읽어들인 뒤, (playerName, playerScore)가 몇 위인지 반환한다.
    global logFilePath

    if !FileExist(logFilePath) {
        ; 로그 파일이 없다면 이번이 첫 기록이므로 1위
        return 1
    }

    FileRead, logData, %logFilePath%
    scoreList := []

    ; 로그 파싱
    Loop, Parse, logData, `n, `r
    {
        line := A_LoopField
        if (line = "")
            continue

        parts := StrSplit(line, ",")
        if (parts.Length() >= 2) {
            ; 예: "20230213_홍길동", " 5"
            name := RegExReplace(parts[1], ".*_(.+)$", "$1")
            scr := Trim(parts[2])
            scoreList.Push({name: name, score: scr})
        }
    }

    ; 점수 내림차순 정렬 (기존 SortScores 재활용)
    scoreList := SortScores(scoreList)

    ; 정렬된 리스트에서 (playerName, playerScore) 찾아 인덱스 + 1 (1위부터 시작)
    for index, item in scoreList
    {
        if (item.name = playerName && item.score = playerScore)
        {
            return index  ; AHK의 배열은 1부터 시작하므로 그대로 index 반환 시 이것이 곧 n위
        }
    }

    ; 혹시 못 찾으면 꼴찌(마지막+1)로 처리
    return scoreList.Length() + 1
}

; === [NEW/ADD] ===
; 2) 슬랙 웹후크를 전송하는 함수
SendSlackWebhook(gameName, gamerId, gameScore, gameRank)
{
    ; 파라미터 예시
    ; gameName  -> "스네이크게임"
    ; gamerId   -> PlayerName
    ; gameScore -> 999
    ; gameRank  -> 1
    webhookUrl := "https://hooks.slack.com/triggers/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"

    ; JSON 바디 구성
    jsonData := "{""game_name"":""" gameName """, ""game_score"":""" gameScore """, ""game_gamerid"":""" gamerId """, ""game_rank"":""" gameRank """}"

    ; Msxml2.XMLHTTP 객체 생성 후 POST 전송
    req := ComObjCreate("Msxml2.XMLHTTP")
    req.Open("POST", webhookUrl, false)
    req.setRequestHeader("Content-Type","application/json;charset=utf-8")
    req.Send(jsonData)

    ; 응답 상태 확인(필요 시)
    ; status := req.status
    ; responseText := req.responseText
    ; MsgBox, 상태: %status%`n응답: %responseText%
}
