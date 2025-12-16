#Persistent
#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1

global grid := [], score := 0, gameStarted := false, startTime := 0
global logFilePath := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\2040스코어\score_log.txt"
global GameWindow2048, ScoreText, TimeText, GameStateText    ; 여기에 컨트롤 변수들 추가

Init2048()
return

Init2048() {
   global grid, GameWindow2048
   
   Gui, Game2048:New, +Resize
   GameWindow2048 := WinExist()
   
   Gui, Game2048:Add, Text, x10 y10 w200 vScoreText, 점수: 0
   Gui, Game2048:Add, Text, x10 y+5 w200 vTimeText, 시간: 00:00
   Gui, Game2048:Add, Text, x10 y+5 w200 vGameStateText, 방향키를 눌러 게임을 시작하세요
   Gui, Game2048:Add, Button, x10 y+5 w100 gRestartGame, 재시작
   Gui, Game2048:Add, Button, x+10 w100 gShowScores, 점수 확인
   Gui, Game2048:Add, Button, x+10 w100 gCloseGame, 닫기

   CreateGrid()
   AddNewTile()
   AddNewTile()
   DrawGame()

   EnableGameControls()
   SetTimer, UpdateTimer, 1000
   Gui, Game2048:Show,, 2048 게임
}

CreateGrid() {
   global grid
   grid := []
   Loop, 4 {
       row := []
       Loop, 4
           row.Push(0)
       grid.Push(row)
   }
}

EnableGameControls() {
    Hotkey, IfWinActive, ahk_class AutoHotkeyGUI  ; 변경
    Hotkey, Up, MoveUp, On
    Hotkey, Down, MoveDown, On
    Hotkey, Left, MoveLeft, On
    Hotkey, Right, MoveRight, On
    Hotkey, IfWinActive
}

MoveUp:
MoveDown:
MoveLeft:
MoveRight:
   if (!gameStarted) {
       gameStarted := true
       startTime := A_TickCount
   }
   Move(A_ThisLabel)
return

Move(direction) {
   global grid, score
   moved := false
   
   if (direction = "MoveLeft")
       moved := MoveGridLeft()
   else if (direction = "MoveRight")
       moved := MoveGridRight()
   else if (direction = "MoveUp")
       moved := MoveGridUp()
   else if (direction = "MoveDown")
       moved := MoveGridDown()
       
   if (moved) {
       AddNewTile()
       DrawGame()
       UpdateScore()
       CheckGameOver()
   }
}

MoveGridLeft() {
   moved := false
   Loop, 4 {
       row := A_Index
       Loop, 3 {
           col := A_Index + 1
           if (grid[row][col] != 0) {
               pos := col
               while (pos > 1 && (grid[row][pos-1] = 0 || grid[row][pos-1] = grid[row][pos])) {
                   if (grid[row][pos-1] = 0) {
                       grid[row][pos-1] := grid[row][pos]
                       grid[row][pos] := 0
                       moved := true
                   } else if (grid[row][pos-1] = grid[row][pos]) {
                       grid[row][pos-1] *= 2
                       score += grid[row][pos-1]
                       grid[row][pos] := 0
                       moved := true
                       break
                   }
                   pos--
               }
           }
       }
   }
   return moved
}

MoveGridRight() {
   moved := false
   Loop, 4 {
       row := A_Index
       Loop, 3 {
           col := 4 - A_Index
           if (grid[row][col] != 0) {
               pos := col
               while (pos < 4 && (grid[row][pos+1] = 0 || grid[row][pos+1] = grid[row][pos])) {
                   if (grid[row][pos+1] = 0) {
                       grid[row][pos+1] := grid[row][pos]
                       grid[row][pos] := 0
                       moved := true
                   } else if (grid[row][pos+1] = grid[row][pos]) {
                       grid[row][pos+1] *= 2
                       score += grid[row][pos+1]
                       grid[row][pos] := 0
                       moved := true
                       break
                   }
                   pos++
               }
           }
       }
   }
   return moved
}

MoveGridUp() {
   moved := false
   Loop, 4 {
       col := A_Index
       Loop, 3 {
           row := A_Index + 1
           if (grid[row][col] != 0) {
               pos := row
               while (pos > 1 && (grid[pos-1][col] = 0 || grid[pos-1][col] = grid[pos][col])) {
                   if (grid[pos-1][col] = 0) {
                       grid[pos-1][col] := grid[pos][col]
                       grid[pos][col] := 0
                       moved := true
                   } else if (grid[pos-1][col] = grid[pos][col]) {
                       grid[pos-1][col] *= 2
                       score += grid[pos-1][col]
                       grid[pos][col] := 0
                       moved := true
                       break
                   }
                   pos--
               }
           }
       }
   }
   return moved
}

MoveGridDown() {
   moved := false
   Loop, 4 {
       col := A_Index
       Loop, 3 {
           row := 4 - A_Index
           if (grid[row][col] != 0) {
               pos := row
               while (pos < 4 && (grid[pos+1][col] = 0 || grid[pos+1][col] = grid[pos][col])) {
                   if (grid[pos+1][col] = 0) {
                       grid[pos+1][col] := grid[pos][col]
                       grid[pos][col] := 0
                       moved := true
                   } else if (grid[pos+1][col] = grid[pos][col]) {
                       grid[pos+1][col] *= 2
                       score += grid[pos+1][col]
                       grid[pos][col] := 0
                       moved := true
                       break
                   }
                   pos++
               }
           }
       }
   }
   return moved
}

AddNewTile() {
   empty := []
   Loop, 4 {
       row := A_Index
       Loop, 4 {
           col := A_Index
           if (grid[row][col] = 0)
               empty.Push({row: row, col: col})
       }
   }
   
   if (empty.Length() > 0) {
       Random, index, 1, % empty.Length()
       Random, value, 1, 10
       grid[empty[index].row][empty[index].col] := (value = 1) ? 4 : 2
   }
}

DrawGame() {
   static colors := {0: "FFFFFF", 2: "EEE4DA", 4: "EDE0C8", 8: "F2B179"
       , 16: "F59563", 32: "F67C5F", 64: "F65E3B", 128: "EDCF72"
       , 256: "EDCC61", 512: "EDC850", 1024: "EDC53F", 2048: "EDC22E"}
   
   Gui, Game2048:Font, s20 bold
   Loop, 4 {
       row := A_Index
       Loop, 4 {
           col := A_Index
           value := grid[row][col]
           color := colors[value]
           x := (col-1)*80 + 10
           y := (row-1)*80 + 150
           
           Gui, Game2048:Add, Text, x%x% y%y% w80 h80 Center BackgroundTrans
               , % (value = 0) ? "" : value
       }
   }
}

UpdateScore() {
   GuiControl, Game2048:, ScoreText, 점수: %score%
}

UpdateTimer:
   if (gameStarted) {
       elapsed := (A_TickCount - startTime) // 1000
       minutes := elapsed // 60
       seconds := Mod(elapsed, 60)
       GuiControl, Game2048:, TimeText, % "시간: " . Format("{:02}:{:02}", minutes, seconds)
   }
return

CheckGameOver() {
   hasEmpty := false
   canMove := false
   
   Loop, 4 {
       row := A_Index
       Loop, 4 {
           col := A_Index
           if (grid[row][col] = 0)
               hasEmpty := true
           if (grid[row][col] = 2048) {
               GameWon()
               return
           }
           if (col < 4 && grid[row][col] = grid[row][col+1])
               canMove := true
           if (row < 4 && grid[row][col] = grid[row+1][col])
               canMove := true
       }
   }
   
   if (!hasEmpty && !canMove)
       GameOver()
}

GameWon() {
   global score
   SetTimer, UpdateTimer, Off
   elapsedTime := (A_TickCount - startTime) // 1000
   
   Gui, WinInput:New, +AlwaysOnTop
   Gui, WinInput:Add, Text,, 축하합니다! 2048을 완성했습니다!`n점수: %score%`n시간: %elapsedTime%초
   Gui, WinInput:Add, Text,, 닉네임을 입력하세요:
   Gui, WinInput:Add, Edit, vPlayerName w200
   Gui, WinInput:Add, Button, gSaveScore w100, 저장
   Gui, WinInput:Show
}

GameOver() {
   global score
   SetTimer, UpdateTimer, Off
   elapsedTime := (A_TickCount - startTime) // 1000
   
   Gui, GameOver:New, +AlwaysOnTop
   Gui, GameOver:Add, Text,, 게임 오버!`n점수: %score%`n시간: %elapsedTime%초
   Gui, GameOver:Add, Text,, 닉네임을 입력하세요:
   Gui, GameOver:Add, Edit, vPlayerName w200
   Gui, GameOver:Add, Button, gSaveScore w100, 저장
   Gui, GameOver:Show
}

SaveScore:
    Gui, Submit
    if (PlayerName = "") {
        MsgBox, 48,, 닉네임을 입력하세요!
        return
    }
    
    FormatTime, currentTime,, yyyyMMdd_HHmmss
    FileAppend, %currentTime% %PlayerName% %score%`n, %logFilePath%
    
    Gui, Destroy
    Gosub, RestartGame
return

ShowScores:
   FileRead, scores, %logFilePath%
   scoreArray := []
   
   Loop, Parse, scores, `n
   {
       if (A_LoopField = "")
           continue
       fields := StrSplit(A_LoopField, A_Space)
       scoreArray.Push({name: fields[2], score: fields[3]})
   }
   
   for i, score in scoreArray {
       for j, nextScore in scoreArray {
           if (score.score < nextScore.score) {
               temp := scoreArray[i]
               scoreArray[i] := scoreArray[j]
               scoreArray[j] := temp
           }
       }
   }
   
   displayText := ""
   Loop, % Min(10, scoreArray.Length())
       displayText .= A_Index . ". " . scoreArray[A_Index].name . ": " . scoreArray[A_Index].score . "`n"
   
   Gui, Scores:New, +AlwaysOnTop
   Gui, Scores:Add, Edit, r10 w300 ReadOnly, %displayText%
   Gui, Scores:Show
return

RestartGame:
   Gui, Game2048:Destroy
   Init2048()
return

CloseGame:
Game2048GuiClose:
Game2048GuiEscape:
   ExitApp
return