#Persistent
#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1

/*  
    2048 게임 구현 예시
    - 방향키(↑, ↓, ←, →)로 조작
    - 첫 방향키 입력 순간부터 시간 체크
    - 게임 종료 시 팝업창에 닉네임 입력 후 score_log.txt에 기록
    - [재시작], [점수확인], [닫기] 버튼
    - score_log.txt 에는 [저장된 날짜] [닉네임] [점수] 형식으로 기록
    - 점수확인 창을 통해 score_log.txt에서 상위 10개 기록(닉네임 + 점수만) 표시
    - 기록 파일 경로:
      G:\공유 드라이브\개인작업일지 모음\개인작업일지배한솔\02업무\프로젝트\07_오토핫키 한솔프로젝트\new\2040스코어\score_log.txt
*/

// 글로벌 변수들
global board := []             ; 4x4 보드(2차원 배열 흉내)
global score := 0              ; 점수
global gameStarted := false     ; 첫 방향키 입력 시점을 체크하기 위함
global startTime := 0          ; 게임 시작(첫 방향키 입력) 시각(A_TickCount)
global elapsedTime := 0        ; 진행 시간(초 단위 표시)
global gameOver := false
global tileSize := 60          ; 각 타일의 GUI 표시 크기
global spaceSize := 8          ; 타일 간 간격
global boardSize := 4          ; 4x4 보드
global mainGuiHwnd := ""
global timerInterval := 800    ; 타이머로 이동 처리 시에 사용할 수도 있지만, 여기선 기본 로직으로 이동
global timeUpdateInterval := 1000  ; 1초마다 시간 갱신
global logFilePath := "G:\공유 드라이브\개인작업일지 모음\개인작업일지배한솔\02업무\프로젝트\07_오토핫키 한솔프로젝트\new\2040스코어\score_log.txt"

; 스크립트 시작 시 메인 GUI 실행
SetTimer, LaunchGame, -50
return

LaunchGame:
    InitGame()
return

; -- 1) 초기 세팅 및 메인 GUI 구성 --------------------------------------------------
InitGame() {
    global mainGuiHwnd, board, score, gameOver, gameStarted
    global tileSize, spaceSize, boardSize

    ; 보드 초기화
    board := []
    for r in range(1, boardSize) {
        tempRow := []
        for c in range(1, boardSize) {
            tempRow.Push(0)
        }
        board.Push(tempRow)
    }
    score := 0
    gameOver := false
    gameStarted := false

    ; GUI 생성
    Gui, 2048Game:New, +Resize +LastFound
    mainGuiHwnd := WinExist()

    ; 상단부: 점수, 경과시간, 버튼들
    Gui, 2048Game:Add, Text, xm ym w300 vScoreText, 점수: 0
    Gui, 2048Game:Add, Text, x+20 ym w300 vTimeText, 시간: 00:00
    Gui, 2048Game:Add, Button, xm y+30 w80 gRestartGame, 재시작
    Gui, 2048Game:Add, Button, x+10 w80 gShowScore, 점수확인
    Gui, 2048Game:Add, Button, x+10 w80 gCloseGame, 닫기

    ; 보드 그릴 영역(픽쳐 or 단순 백그라운드)
    ; 여유 폭/높이 계산
    boardPixelSize := tileSize*boardSize + spaceSize*(boardSize+1)
    Gui, 2048Game:Add, Picture, xm y+10 w%boardPixelSize% h%boardPixelSize% 0x400000 vBoardCanvas,  ; 빈 그림
    ; 0x400000: SS_NOTIFY (마우스 클릭 등 이벤트가 필요하다면)

    ; 적당히 GUI 크기 조절
    totalWidth := boardPixelSize + 50
    totalHeight := boardPixelSize + 150
    Gui, 2048Game:Show, w%totalWidth% h%totalHeight%, 2048 Game (AutoHotkey)

    ; 방향키 핫키 설정
    SetHotkeysOn()
    
    ; 최초 2개의 타일 생성
    GenerateTile()
    GenerateTile()

    ; 보드 그리기
    DrawBoard()

    ; 시간 갱신 타이머 시작(1초마다 경과 시간을 업데이트)
    SetTimer, UpdateTime, %timeUpdateInterval%
}

; 핫키 설정
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

; -- 2) 타일 생성 로직 ------------------------------------------------------------
GenerateTile() {
    global board, boardSize

    emptyCells := []
    for r, row in board {
        for c, val in row {
            if (val = 0)
                emptyCells.Push({r: r, c: c})
        }
    }
    if (emptyCells.Length() = 0)
        return  ; 생성 불가

    Random, idx, 1, % emptyCells.Length()
    chosen := emptyCells[idx]

    ; 2 또는 4 생성(일반적으로 4가 나올 확률 10% 정도)
    Random, tileChance, 1, 10
    newTile := (tileChance = 1) ? 4 : 2  ; 1/10 확률로 4
    board[chosen.r][chosen.c] := newTile
}

; -- 3) 시간 갱신 -----------------------------------------------------------
UpdateTime:
    global gameStarted, startTime
    if (!gameStarted)
    {
        GuiControl, 2048Game:, TimeText, 시간: 00:00
        return
    }
    now := A_TickCount
    elapsedMs := now - startTime
    seconds := Floor(elapsedMs / 1000)
    minutes := Floor(seconds / 60)
    seconds := Mod(seconds, 60)

    ; 포맷: MM:SS
    timeText := Format("{:02}:{:02}", minutes, seconds)
    GuiControl, 2048Game:, TimeText, 시간: %timeText%
return

; -- 4) 방향키 이동 ----------------------------------------------------------
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

; 실제 이동+병합 처리 함수
HandleMove(direction) {
    global board, score, boardSize
    
    oldBoard := CopyBoard(board)

    if (direction = "UP") {
        For c in range(1, boardSize) {
            ; 열 단위로 위로 이동
            colArray := []
            For r in range(1, boardSize) {
                val := board[r][c]
                if (val != 0)
                    colArray.Push(val)
            }
            ; merge
            merged := MergeArray(colArray)
            ; 병합된 결과 다시 보드에 반영
            padCount := boardSize - merged.Length()
            For i in range(1, padCount)
                merged.Push(0)
            ; merged 를 보드에 쓰기(위에서부터 채워넣음)
            for r in range(1, boardSize) {
                board[r][c] := (r <= merged.Length()) ? merged[r] : 0
            }
        }
    }
    else if (direction = "DOWN") {
        For c in range(1, boardSize) {
            colArray := []
            For r in range(boardSize, 1, -1) {
                val := board[r][c]
                if (val != 0)
                    colArray.Push(val)
            }
            merged := MergeArray(colArray)
            padCount := boardSize - merged.Length()
            For i in range(1, padCount)
                merged.Push(0)
            ; merged 를 다시 아래쪽부터 보드에 쓰기
            for r in range(boardSize, 1, -1) {
                idx := boardSize - r + 1
                board[r][c] := (idx <= merged.Length()) ? merged[idx] : 0
            }
        }
    }
    else if (direction = "LEFT") {
        For r in range(1, boardSize) {
            rowArray := []
            For c in range(1, boardSize) {
                val := board[r][c]
                if (val != 0)
                    rowArray.Push(val)
            }
            merged := MergeArray(rowArray)
            padCount := boardSize - merged.Length()
            For i in range(1, padCount)
                merged.Push(0)
            for c in range(1, boardSize) {
                board[r][c] := (c <= merged.Length()) ? merged[c] : 0
            }
        }
    }
    else if (direction = "RIGHT") {
        For r in range(1, boardSize) {
            rowArray := []
            For c in range(boardSize, 1, -1) {
                val := board[r][c]
                if (val != 0)
                    rowArray.Push(val)
            }
            merged := MergeArray(rowArray)
            padCount := boardSize - merged.Length()
            For i in range(1, padCount)
                merged.Push(0)
            ; 병합한 걸 다시 오른쪽부터 채움
            for c in range(boardSize, 1, -1) {
                idx := boardSize - c + 1
                board[r][c] := (idx <= merged.Length()) ? merged[idx] : 0
            }
        }
    }

    ; 새로운 board가 이전과 달라졌는지?
    return !IsSameBoard(board, oldBoard)
}

; 배열에서 인접 동일값 병합 처리
MergeArray(a) {
    global score
    out := []
    idx := 1
    while (idx <= a.Length()) {
        if (idx < a.Length() && a[idx] = a[idx+1]) {
            mergedVal := a[idx] * 2
            score += mergedVal  ; 점수 증가
            out.Push(mergedVal)
            idx += 2
        } else {
            out.Push(a[idx])
            idx++
        }
    }
    return out
}

; -- 이동 후 처리 (새 타일 생성, 보드 그림 갱신, 승패 판단) --------------------
AfterMove() {
    global board, score, gameOver

    GenerateTile()   ; 새로운 타일 1개 생성
    DrawBoard()
    UpdateScoreGUI()

    ; 승리 체크(2048이 생겼는지) - 예시이므로 별도의 승리 처리 대신 계속 진행
    if (CheckWin()) {
        ; 2048 달성했으나 여기서는 바로 게임오버처럼 처리
        ; 원본 게임은 계속 진행 가능/스킵 가능.
        gameOver := true
        GameOver()
        return
    }

    ; 이동 불가 & 빈칸 없으면 패배
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
    ; 인접한 값이 같거나, 빈칸이 있으면 이동 가능
    ; 여기서는 빈칸 체크를 호출 전 했으므로, 오직 인접 같은 값이 있는지만 확인
    for r in range(1, boardSize) {
        for c in range(1, boardSize) {
            val := board[r][c]
            if (r < boardSize && board[r+1][c] = val)
                return true
            if (c < boardSize && board[r][c+1] = val)
                return true
        }
    }
    return false
}

; -- 5) 보드 그리기 ---------------------------------------------------------
DrawBoard() {
    global board, boardSize, tileSize, spaceSize

    boardPixelSize := tileSize*boardSize + spaceSize*(boardSize+1)

    ; 1) 메모리 DC 준비
    hdc := DllCall("CreateCompatibleDC", "Ptr", 0)
    hbm := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", boardPixelSize, "Int", boardPixelSize)
    obm := DllCall("SelectObject", "Ptr", hdc, "Ptr", hbm)

    ; 배경(회색)
    backgroundColor := 0xCCC0B4  ; 2048게임 전통 UI 색
    FillRect(hdc, 0, 0, boardPixelSize, boardPixelSize, backgroundColor)

    ; 타일 그리기
    for r in range(1, boardSize) {
        for c in range(1, boardSize) {
            val := board[r][c]
            x := spaceSize + (c-1)*(tileSize + spaceSize)
            y := spaceSize + (r-1)*(tileSize + spaceSize)

            if (val = 0) {
                ; 빈칸은 연한 그레이
                tileColor := 0xCDC1B4
            } else {
                tileColor := GetTileColor(val)
            }
            FillRect(hdc, x, y, tileSize, tileSize, tileColor)

            if (val != 0) {
                ; 텍스트(타일 숫자) 그리기
                DrawTextCenter(hdc, x, y, tileSize, tileSize, val)
            }
        }
    }

    ; 2) GUI 컨트롤에 복사
    GuiControlGet, bHwnd, 2048Game:Hwnd, BoardCanvas
    hdc_dest := DllCall("GetDC", "Ptr", bHwnd)
    DllCall("BitBlt", "Ptr", hdc_dest, "Int", 0, "Int", 0, "Int", boardPixelSize, "Int", boardPixelSize
                               , "Ptr", hdc, "Int", 0, "Int", 0, "UInt", 0xCC0020)
    DllCall("ReleaseDC", "Ptr", bHwnd, "Ptr", hdc_dest)

    ; 3) 정리
    DllCall("SelectObject", "Ptr", hdc, "Ptr", obm)
    DllCall("DeleteObject", "Ptr", hbm)
    DllCall("DeleteDC", "Ptr", hdc)
}

; 사각형 채우기
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

; 타일별 색상 반환(단순 예시)
GetTileColor(val) {
    ; 16진수 BGR 순서
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

; 텍스트 가운데 그리기
DrawTextCenter(hdc, x, y, w, h, textValue) {
    fontColor := 0x000000
    ; 폰트색 지정
    DllCall("SetTextColor", "Ptr", hdc, "Int", fontColor)
    DllCall("SetBkMode", "Ptr", hdc, "Int", 1)  ; 투명 모드
    ; 폰트 생성
    hFont := DllCall("CreateFont", "Int", 24, "Int", 0, "Int", 0, "Int", 0, "Uint", 400
                                  , "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0
                                  , "Uint", 0, "Uint", 0, "Str", "Arial", "Ptr")
    oldFont := DllCall("SelectObject", "Ptr", hdc, "Ptr", hFont)

    ; 실제 DrawText
    VarSetCapacity(rc, 16, 0)
    NumPut(x, rc, 0, "Int")
    NumPut(y, rc, 4, "Int")
    NumPut(x+w, rc, 8, "Int")
    NumPut(y+h, rc, 12, "Int")
    DllCall("DrawText", "Ptr", hdc, "Str", textValue, "Int", -1, "Ptr", &rc, "Int", 0x00000001|0x00000004) ; DT_CENTER|DT_VCENTER

    ; 정리
    DllCall("SelectObject", "Ptr", hdc, "Ptr", oldFont)
    DllCall("DeleteObject", "Ptr", hFont)
}

; -- 6) 보조 함수들 ---------------------------------------------------------
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

; -- 7) 게임 종료 및 점수 저장 -------------------------------------------------
GameOver() {
    global score

    ; 게임 오버 메시지 및 닉네임 입력 GUI
    Gui, ScoreInput:New, +AlwaysOnTop
    Gui, ScoreInput:Add, Text, x10 y10 w250, 게임 종료! 점수: %score%
    Gui, ScoreInput:Add, Text, x10 y+30 w250, 닉네임을 입력하세요:
    Gui, ScoreInput:Add, Edit, x10 y+60 w200 vPlayerName
    Gui, ScoreInput:Add, Button, x10 y+100 w80 gConfirmScore, 확인
    Gui, ScoreInput:Add, Button, x+10 w80 gCancelScore, 취소
    Gui, ScoreInput:Show
}

ConfirmScore() {
    global score, logFilePath, PlayerName
    global board, gameOver

    Gui, ScoreInput:Submit, NoHide
    if (PlayerName = "") {
        MsgBox, 48, 경고, 닉네임을 입력하세요!
        return
    }

    ; 날짜/시간 형식
    FormatTime, currentDateTime,, yyyy-MM-dd_HH:mm
    ; 로그 파일에 저장: [저장된 날짜] [닉네임] [점수]
    logEntry := currentDateTime . " " . PlayerName . " " . score
    FileAppend, %logEntry%`n, %logFilePath%

    MsgBox, 64, 등록, 점수가 등록되었습니다!
    Gui, ScoreInput:Destroy
    
    ; 게임을 재시작하거나, 그냥 GUI를 남겨둘 수도 있음
    ; 여기서는 간단히 재시작 처리
    RestartGame()
}

CancelScore() {
    Gui, ScoreInput:Destroy
    ; 여기서는 단순 재시작
    RestartGame()
}

; -- 8) 재시작, 닫기, 점수확인 --------------------------------------------------
RestartGame:
RestartGame() {
    global gameStarted, score, gameOver
    global board
    SetHotkeysOff()
    Gui, 2048Game:Destroy
    Gui, ScoreInput:Destroy
    Gui, ScoreDisplay:Destroy
    InitGame()  ; 다시 초기화
    return
}

CloseGame:
CloseGame() {
    ExitApp
}

ShowScore:
    if !FileExist(logFilePath) {
        MsgBox, 16, 오류, 아직 점수 기록이 없습니다!
        return
    }
    FileRead, logData, %logFilePath%
    if (ErrorLevel) {
        MsgBox, 16, 오류, 점수 파일을 열 수 없습니다!
        return
    }

    ; logData 예시: "2025-01-04_10:23 NickA 200`n2025-01-05_09:11 NickB 150`n..."
    scoreArray := []
    Loop, Parse, logData, `n, `r
    {
        line := Trim(A_LoopField)
        if (line = "")
            continue

        ; line 을 세 부분으로 분리: [날짜시간] [닉네임] [점수]
        ; 공백 기준으로 3개 토큰만 있다고 가정
        tokens := StrSplit(line, " ")
        if (tokens.Length() < 3)
            continue
        ; 날짜 = tokens[1], 닉네임 = tokens[2], 점수 = tokens[3]
        dt := tokens[1]
        nick := tokens[2]
        sc := tokens[3]
        ; 점수가 숫자일 경우만 파싱
        scNum := sc+0
        scoreArray.Push({nick: nick, score: scNum})
    }

    ; 점수 높은 순 정렬
    scoreArray := SortScores(scoreArray)

    ; 상위 10개만
    topScores := ""
    Loop, 10
    {
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

; 내림차순 정렬
SortScores(arr) {
    ; 단순 버블정렬 예시
    loop, % arr.Length()-1 {
        i := A_Index
        loop, % arr.Length()-i {
            j := A_Index
            if (arr[j].score < arr[j+1].score) {
                temp := arr[j]
                arr[j] := arr[j+1]
                arr[j+1] := temp
            }
        }
    }
    return arr
}

; -- GUI 닫힐 때 스크립트 전체 종료 ---------------------------------------------
2048GameGuiClose:
    ExitApp
return
