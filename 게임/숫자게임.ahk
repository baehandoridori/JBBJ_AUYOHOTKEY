#Persistent               ; // 스크립트가 계속 실행 상태를 유지하도록
#NoEnv                    ; // 환경 변수 사용 방식을 간소화
#SingleInstance, Force    ; // 여러 번 실행 시 이전 스크립트 종료
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1        ; // v1에서만 동작. (v2에서 실행하면 오류)

; // -----------------------------
; //      글로벌 변수들
; // -----------------------------
global board             := []
global score             := 0
global gameStarted       := false
global startTime         := 0
global elapsedTime       := 0
global gameOver          := false
global tileSize          := 60
global spaceSize         := 8
global boardSize         := 4
global mainGuiHwnd       := ""
global timerInterval     := 800
global timeUpdateInterval:= 1000
global logFilePath := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\JBBJ_게임\JBBJ_게임_게임스코어\2040스코어\score_log.txt"

; // 전역 폰트 핸들(딱 한 번 생성 후 재사용)
global g_hFont := 0

; // GUI 컨트롤 변수들
global ScoreText
global TimeText
global BoardCanvas

; // -----------------------------
; //      스크립트 시작
; // -----------------------------
SetTimer, LaunchGame, -50
return

LaunchGame:
    InitGame()
return

; // -----------------------------
; //      InitGame()
; // -----------------------------
InitGame() {
    global board, score, gameOver, gameStarted
    global mainGuiHwnd, tileSize, spaceSize, boardSize
    global ScoreText, TimeText, BoardCanvas
    global g_hFont

    ; // 보드 초기화
    board := []
    Loop, % boardSize {
        r := A_Index
        tempRow := []
        Loop, % boardSize {
            c := A_Index
            tempRow.Push(0)
        }
        board.Push(tempRow)
    }

    score := 0
    gameOver := false
    gameStarted := false

    Gui, 2048Game:New, +Resize +LastFound
    mainGuiHwnd := WinExist()

    ; // 상단부 텍스트
    Gui, 2048Game:Add, Text, xm ym w300 vScoreText, 점수: 0
    Gui, 2048Game:Add, Text, xm y+20 w300 vTimeText, 시간: 00:00

    ; // 버튼들
    Gui, 2048Game:Add, Button, xm y+30 w80 gRestartGameLabel, 재시작
    Gui, 2048Game:Add, Button, x+10 w80 gShowScore, 점수확인
    Gui, 2048Game:Add, Button, x+10 w80 gCloseGame, 닫기

    ; // 보드 표시 영역(Picture)
    boardPixelSize := tileSize*boardSize + spaceSize*(boardSize+1)
    Gui, 2048Game:Add, Picture, xm y+10 w%boardPixelSize% h%boardPixelSize% 0x400000 vBoardCanvas,

    totalWidth  := boardPixelSize + 50
    totalHeight := boardPixelSize + 150
    Gui, 2048Game:Show, w%totalWidth% h%totalHeight%, 2048 게임

    SetHotkeysOn()

    ; // 전역 폰트 핸들을 아직 만들지 않았다면, 여기서 한 번만 생성
    ; // 첫 번째 인자를 -값으로 주어 픽셀 단위 고정 (예: -32)
    if (!g_hFont) {
        g_hFont := DllCall("CreateFont"
            , "Int", -32      ; // 음수 → 32px 높이
            , "Int", 0
            , "Int", 0
            , "Int", 0
            , "Uint", 700     ; // 굵기(400=normal)
            , "Uint", 0
            , "Uint", 0
            , "Uint", 0
            , "Uint", 0
            , "Uint", 0
            , "Uint", 0
            , "Uint", 0
            , "Str", "Arial"
            , "Ptr")
    }

    ; // 타일 초기 2개 생성
    GenerateTile()
    GenerateTile()
    DrawBoard()

    ; // 1초마다 시간 갱신
    SetTimer, UpdateTime, %timeUpdateInterval%
}

; // -----------------------------
; //      핫키 설정
; // -----------------------------
SetHotkeysOn() {
    global mainGuiHwnd
    Hotkey, IfWinActive, ahk_id %mainGuiHwnd%
    Hotkey, Up, MoveUp, On
    Hotkey, Down, MoveDown, On
    Hotkey, Left, MoveLeft, On
    Hotkey, Right, MoveRight, On
    Hotkey, IfWinActive
}

SetHotkeysOff() {
    global mainGuiHwnd
    Hotkey, IfWinActive, ahk_id %mainGuiHwnd%
    Hotkey, Up, Off
    Hotkey, Down, Off
    Hotkey, Left, Off
    Hotkey, Right, Off
    Hotkey, IfWinActive
}

; // -----------------------------
; //      타일 생성 로직
; // -----------------------------
GenerateTile() {
    global board, boardSize

    emptyCells := []
    Loop, % boardSize {
        r := A_Index
        thisRow := board[r]
        Loop, % boardSize {
            c := A_Index
            if (thisRow[c] = 0) {
                emptyCells.Push({r: r, c: c})
            }
        }
    }
    if (emptyCells.Length() = 0)
        return

    Random, idx, 1, % emptyCells.Length()
    chosen := emptyCells[idx]

    Random, tileChance, 1, 10
    newTile := (tileChance = 1) ? 4 : 2
    board[chosen.r][chosen.c] := newTile
}

; // -----------------------------
; //   UpdateTime (타이머)
; // -----------------------------
UpdateTime:
    global gameStarted, startTime
    if (!gameStarted) {
        GuiControl, 2048Game:, TimeText, 시간: 00:00
        return
    }
    now := A_TickCount
    elapsedMs := now - startTime
    seconds := Floor(elapsedMs / 1000)
    minutes := Floor(seconds / 60)
    seconds := Mod(seconds, 60)

    timeText := Format("{:02}:{:02}", minutes, seconds)
    GuiControl, 2048Game:, TimeText, 시간: %timeText%
return

; // -----------------------------
; //   방향키 이동 레이블
; // -----------------------------
MoveUp:
    StartGameTimerCheck()
    if (HandleMove("UP")) {
        AfterMove()
    }
return

MoveDown:
    StartGameTimerCheck()
    if (HandleMove("DOWN")) {
        AfterMove()
    }
return

MoveLeft:
    StartGameTimerCheck()
    if (HandleMove("LEFT")) {
        AfterMove()
    }
return

MoveRight:
    StartGameTimerCheck()
    if (HandleMove("RIGHT")) {
        AfterMove()
    }
return

; // -----------------------------
; //   HandleMove(direction)
; // -----------------------------
HandleMove(direction) {
    global board, score, boardSize

    oldBoard := CopyBoard(board)

    if (direction = "UP") {
        Loop, % boardSize {
            c := A_Index
            colArray := []
            Loop, % boardSize {
                r := A_Index
                val := board[r][c]
                if (val != 0)
                    colArray.Push(val)
            }
            merged := MergeArray(colArray)
            Loop, % boardSize {
                r := A_Index
                if (r <= merged.Length())
                    board[r][c] := merged[r]
                else
                    board[r][c] := 0
            }
        }
    }
    else if (direction = "DOWN") {
        Loop, % boardSize {
            c := A_Index
            colArray := []
            Loop, % boardSize {
                r := boardSize - A_Index + 1
                val := board[r][c]
                if (val != 0)
                    colArray.Push(val)
            }
            merged := MergeArray(colArray)
            Loop, % boardSize {
                r := boardSize - A_Index + 1
                idx := boardSize - r + 1
                if (idx <= merged.Length())
                    board[r][c] := merged[idx]
                else
                    board[r][c] := 0
            }
        }
    }
    else if (direction = "LEFT") {
        Loop, % boardSize {
            r := A_Index
            rowArray := []
            thisRow := board[r]
            Loop, % boardSize {
                c := A_Index
                val := thisRow[c]
                if (val != 0)
                    rowArray.Push(val)
            }
            merged := MergeArray(rowArray)
            Loop, % boardSize {
                c := A_Index
                if (c <= merged.Length())
                    board[r][c] := merged[c]
                else
                    board[r][c] := 0
            }
        }
    }
    else if (direction = "RIGHT") {
        Loop, % boardSize {
            r := A_Index
            rowArray := []
            thisRow := board[r]
            Loop, % boardSize {
                c := boardSize - A_Index + 1
                val := thisRow[c]
                if (val != 0)
                    rowArray.Push(val)
            }
            merged := MergeArray(rowArray)
            Loop, % boardSize {
                c := boardSize - A_Index + 1
                idx := boardSize - c + 1
                if (idx <= merged.Length())
                    board[r][c] := merged[idx]
                else
                    board[r][c] := 0
            }
        }
    }

    return !IsSameBoard(board, oldBoard)
}

; // -----------------------------
; //   MergeArray(a)
; // -----------------------------
MergeArray(a) {
    global score
    out := []
    idx := 1
    while (idx <= a.Length()) {
        if (idx < a.Length() && a[idx] = a[idx+1]) {
            mergedVal := a[idx] * 2
            score += mergedVal
            out.Push(mergedVal)
            idx += 2
        } else {
            out.Push(a[idx])
            idx++
        }
    }
    return out
}

; // -----------------------------
; //   AfterMove()
; // -----------------------------
AfterMove() {
    global board, score, gameOver
    GenerateTile()
    DrawBoard()
    UpdateScoreGUI()

    if (CheckWin()) {
        gameOver := true
        GameOver()
        return
    }
    if (IsBoardFull() && !CanMove()) {
        gameOver := true
        GameOver()
    }
}

CheckWin() {
    global board
    for r, row in board {
        for c, val in row {
            if (val >= 2048)
                return true
        }
    }
    return false
}

IsBoardFull() {
    global board
    for r, row in board {
        for c, val in row {
            if (val = 0)
                return false
        }
    }
    return true
}

CanMove() {
    global board, boardSize
    Loop, % boardSize {
        r := A_Index
        Loop, % boardSize {
            c := A_Index
            val := board[r][c]
            if (r < boardSize && board[r+1][c] = val && val != 0)
                return true
            if (c < boardSize && board[r][c+1] = val && val != 0)
                return true
        }
    }
    return false
}

; // -----------------------------
; //   DrawBoard()
; // -----------------------------
DrawBoard() {
    global board, boardSize, tileSize, spaceSize

    boardPixelSize := tileSize*boardSize + spaceSize*(boardSize+1)

    hdc := DllCall("CreateCompatibleDC", "Ptr", 0)
    hbm := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", boardPixelSize, "Int", boardPixelSize)
    obm := DllCall("SelectObject", "Ptr", hdc, "Ptr", hbm)

    backgroundColor := 0xCCC0B4
    FillRect(hdc, 0, 0, boardPixelSize, boardPixelSize, backgroundColor)

    Loop, % boardSize {
        r := A_Index
        thisRow := board[r]
        Loop, % boardSize {
            c := A_Index
            val := thisRow[c]
            x := spaceSize + (c-1)*(tileSize + spaceSize)
            y := spaceSize + (r-1)*(tileSize + spaceSize)

            if (val = 0) {
                tileColor := 0xCDC1B4
            } else {
                tileColor := GetTileColor(val)
            }
            FillRect(hdc, x, y, tileSize, tileSize, tileColor)

            if (val != 0) {
                DrawTextCenter(hdc, x, y, tileSize, tileSize, val)
            }
        }
    }

    GuiControlGet, bHwnd, 2048Game:Hwnd, BoardCanvas
    hdc_dest := DllCall("GetDC", "Ptr", bHwnd)
    DllCall("BitBlt", "Ptr", hdc_dest, "Int", 0, "Int", 0
          , "Int", boardPixelSize, "Int", boardPixelSize
          , "Ptr", hdc, "Int", 0, "Int", 0, "UInt", 0xCC0020)
    DllCall("ReleaseDC", "Ptr", bHwnd, "Ptr", hdc_dest)

    DllCall("SelectObject", "Ptr", hdc, "Ptr", obm)
    DllCall("DeleteObject", "Ptr", hbm)
    DllCall("DeleteDC", "Ptr", hdc)
}

FillRect(hdc, x, y, w, h, color) {
    VarSetCapacity(rect, 16, 0)
    NumPut(x, rect, 0, "Int")
    NumPut(y, rect, 4, "Int")
    NumPut(x + w, rect, 8, "Int")
    NumPut(y + h, rect, 12, "Int")
    hBrush := DllCall("CreateSolidBrush", "UInt", color, "Ptr")
    DllCall("FillRect", "Ptr", hdc, "Ptr", &rect, "Ptr", hBrush)
    DllCall("DeleteObject", "Ptr", hBrush)
}

GetTileColor(val) {
    switch val {
    case 2:    return 0xEEE4DA
    case 4:    return 0xEDE0C8
    case 8:    return 0xF2B179
    case 16:   return 0xF59563
    case 32:   return 0xF67C5F
    case 64:   return 0xF65E3B
    case 128:  return 0xEDCF72
    case 256:  return 0xEDCC61
    case 512:  return 0xEDC850
    case 1024: return 0xEDC53F
    case 2048: return 0xEDC22E
    default:   return 0x3C3A32
    }
}

; // DrawTextCenter(): g_hFont 재사용
DrawTextCenter(hdc, x, y, w, h, textValue) {
    global g_hFont

    fontColor := 0x000000
    DllCall("SetTextColor", "Ptr", hdc, "Int", fontColor)
    DllCall("SetBkMode", "Ptr", hdc, "Int", 1)  ; // 투명 모드

    ; // ★ 새 폰트를 만들지 않고, 전역 g_hFont 사용
    oldFont := DllCall("SelectObject", "Ptr", hdc, "Ptr", g_hFont)

    VarSetCapacity(rc, 16, 0)
    NumPut(x, rc, 0, "Int")
    NumPut(y, rc, 4, "Int")
    NumPut(x + w, rc, 8, "Int")
    NumPut(y + h, rc, 12, "Int")

    DT_CENTER := 0x00000001
    DT_VCENTER := 0x00000004
    DT_SINGLELINE := 0x00000020
    style := DT_CENTER | DT_VCENTER | DT_SINGLELINE

    DllCall("DrawText", "Ptr", hdc, "Str", textValue, "Int", -1
                     , "Ptr", &rc, "Int", style)

    DllCall("SelectObject", "Ptr", hdc, "Ptr", oldFont)
}

; // -----------------------------
; //   보조 함수들
; // -----------------------------
IsSameBoard(b1, b2) {
    for r, row in b1 {
        for c, val in row {
            if (val != b2[r][c])
                return false
        }
    }
    return true
}

CopyBoard(src) {
    newBoard := []
    for r, row in src {
        newRow := []
        for c, val in row {
            newRow.Push(val)
        }
        newBoard.Push(newRow)
    }
    return newBoard
}

UpdateScoreGUI() {
    global score
    GuiControl, 2048Game:, ScoreText, 점수: %score%
}

StartGameTimerCheck() {
    global gameStarted, startTime
    if (!gameStarted) {
        gameStarted := true
        startTime := A_TickCount
    }
}

; // -----------------------------
; //   게임 종료 및 점수 저장
; // -----------------------------
GameOver() {
    global score

    Gui, ScoreInput:New, +AlwaysOnTop
    Gui, ScoreInput:Add, Text, x10 y10 w250, 게임 종료! 점수: %score%
    Gui, ScoreInput:Add, Text, x10 y+30 w250, 닉네임을 입력하세요.
    Gui, ScoreInput:Add, Text, x10 y+10 w250, 띄어쓰기 하면 제대로 입력 안됩니다!
    Gui, ScoreInput:Add, Edit, x10 y+60 w200 vPlayerName
    Gui, ScoreInput:Add, Button, x10 y+100 w80 gConfirmScore, 확인
    Gui, ScoreInput:Add, Button, x+10 w80 gCancelScore, 취소
    Gui, ScoreInput:Show
}

ConfirmScore() {
    global score, logFilePath, PlayerName
    
    Gui, ScoreInput:Submit, NoHide
    if (PlayerName = "") {
        MsgBox, 48, 경고, 닉네임을 입력하세요!
        return
    }
    
    ; 파일에 저장하기 전에 랭킹 계산
    newRank := CalculateRank(PlayerName, score)
    
    ; 점수 파일에 저장
    FormatTime, currentDateTime,, yyyy-MM-dd_HH:mm
    logEntry := currentDateTime . " " . PlayerName . " " . score
    FileAppend, %logEntry%`r`n, %logFilePath%, UTF-8
    
    MsgBox, 262208, 등록, 점수가 등록되었습니다!
    Gui, ScoreInput:Destroy
    
    ; 랭킹 표시 및 공유 기능
    MsgBox, 4, 자랑하시겠습니까?, 현재 %newRank%위에 랭크되었습니다! 자랑(공유)하시겠습니까?
    IfMsgBox Yes
    {
        SendSlackWebhook("2048 게임", PlayerName, score, newRank)
    }
    
    RestartGame()
}

CancelScore() {
    Gui, ScoreInput:Destroy
    RestartGame()
}

; // -----------------------------
; //   재시작 / 닫기 / 점수확인
; // -----------------------------
RestartGameLabel:
RestartGame()
return

RestartGame() {
    global gameStarted, score, gameOver
    SetHotkeysOff()
    Gui, 2048Game:Destroy
    Gui, ScoreInput:Destroy
    Gui, ScoreDisplay:Destroy
    InitGame()
}

; // 스크립트 완전 종료 시 폰트 핸들도 해제
CloseGame:
    global g_hFont
    if (g_hFont) {
        DllCall("DeleteObject", "Ptr", g_hFont)
        g_hFont := 0
    }
    ExitApp

ShowScore:
    global logFilePath

    if !FileExist(logFilePath) {
        MsgBox, 16, 오류, 아직 점수 기록이 없습니다!
        return
    }

    FileRead, logData, %logFilePath%
    if (ErrorLevel) {
        MsgBox, 16, 오류, 점수 파일을 열 수 없습니다!
        return
    }

    scoreArray := []
    Loop, Parse, logData, `n, `r
    {
        line := Trim(A_LoopField)
        if (line = "")
            continue
        tokens := StrSplit(line, " ")
        if (tokens.Length() < 3)
            continue

        dt := tokens[1]
        nick := tokens[2]
        sc := tokens[3]
        scNum := sc+0
        scoreArray.Push({nick: nick, score: scNum})
    }

    scoreArray := SortScores(scoreArray)

    topScores := ""
    Loop, 10 {
        if (A_Index > scoreArray.Length())
            break
        item := scoreArray[A_Index]
        topScores .= A_Index . ". " . item.nick . ": " . item.score . "`r`n"
    }
    if (topScores = "")
        topScores := "기록이 없습니다."

    Gui, ScoreDisplay:New, +AlwaysOnTop
    Gui, ScoreDisplay:Add, Edit, r10 w250 ReadOnly, %topScores%
    Gui, ScoreDisplay:Show
return

SortScores(arr) {
    Loop, % arr.Length()-1
    {
        ; j는 1부터 (총길이 - A_Index)까지 반복
        Loop, % arr.Length()-A_Index
        {
            if (arr[A_Index].score < arr[A_Index+1].score)
            {
                temp := arr[A_Index]
                arr[A_Index] := arr[A_Index+1]
                arr[A_Index+1] := temp
            }
        }
    }
    return arr
}
2048GameGuiClose:
    ; // 윈도우 x 버튼 눌렀을 때도 CloseGame 호출
    GoSub, CloseGame
return

; === [NEW/ADD] ===
; 3) 랭킹 계산 함수
CalculateRank(playerName, playerScore)
{
    global logFilePath
    
    if !FileExist(logFilePath) {
        return 1 ; 파일이 없으면 1위
    }
    
    FileRead, logData, %logFilePath%
    if (ErrorLevel) {
        return 1 ; 파일을 읽지 못하면 1위로 처리
    }
    
    ; 모든 점수를 배열에 저장
    scoreArray := []
    Loop, Parse, logData, `n, `r
    {
        line := Trim(A_LoopField)
        if (line = "")
            continue
        tokens := StrSplit(line, " ")
        if (tokens.Length() < 3)
            continue
        
        nick := tokens[2]
        sc := tokens[3]
        scNum := sc+0
        scoreArray.Push({nick: nick, score: scNum})
    }
    
    ; 현재 플레이어 점수 추가 (아직 파일에 저장되지 않은 상태로 계산)
    scoreArray.Push({nick: playerName, score: playerScore})
    
    ; 점수 내림차순 정렬
    scoreArray := SortScores(scoreArray)
    
    ; 정렬된 리스트에서 플레이어 점수의 순위 찾기
    for idx, item in scoreArray {
        if (item.nick = playerName && item.score = playerScore) {
            return idx ; 인덱스가 순위
        }
    }
    
    return scoreArray.Length() ; 찾지 못한 경우 (일어나면 안 됨)
}

; === [NEW/ADD] ===
; 4) 슬랙 웹후크 전송 함수
SendSlackWebhook(gameName, gamerId, gameScore, gameRank)
{
    webhookUrl := "https://hooks.slack.com/triggers/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"
    jsonData := "{""game_name"":""" gameName """, ""game_score"":""" gameScore """, ""game_gamerid"":""" gamerId """, ""game_rank"":""" gameRank """}"

    req := ComObjCreate("Msxml2.XMLHTTP")
    req.Open("POST", webhookUrl, false)
    req.setRequestHeader("Content-Type","application/json;charset=utf-8")
    req.Send(jsonData)

    ; ; // 필요하다면 응답 확인 가능
    ; status := req.status
    ; responseText := req.responseText
    ; MsgBox, 상태: %status%n응답: %responseText%
}
