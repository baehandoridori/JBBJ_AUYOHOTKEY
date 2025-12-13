#NoEnv
#Warn
#SingleInstance Force

; ------------------------------------------------------
; [1] 전역 변수
; ------------------------------------------------------
global secretNumber := ""
global digitCount   := 3
global startTime    := 0
global tryCount     := 0


; ------------------------------------------------------
; 난이도 선택 GUI (#1)
; ------------------------------------------------------
Gui, +AlwaysOnTop +LabelDiffGui
Gui, Font, s10
Gui, Add, Text, x20 y20 w280 h30, 숫자 야구 난이도를 선택하세요.

; 세 개의 라디오를 각각 vRadio3, vRadio4, vRadio5로 구분
Gui, Add, Radio, vRadio3  Checked x20 y60, 3자리
Gui, Add, Radio, vRadio4           x20 y90, 4자리
Gui, Add, Radio, vRadio5           x20 y120, 5자리
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
; Radio3=1이면 3자리, Radio4=1이면 4자리, 아니면 5
if (Radio3 = 1)
    digitCount := 3
else if (Radio4 = 1)
    digitCount := 4
else
    digitCount := 5

Gui, Destroy   ; 난이도 GUI 닫기

; 정답 숫자 / 시도 횟수 / 시간 초기화
tryCount := 0
secretNumber := GenerateRandomNumber(digitCount)
startTime := A_TickCount

; ------------------------------------------------------
; 메인 게임 GUI (#2)
; ------------------------------------------------------
Gui, 2: +LabelGameGui
Gui, 2: Font, s12

; (A) 숫자 버튼만 Bold 적용
Gui, 2: Font, wBold
Gui, 2: Add, Button, x502 y129 w70 h70 gDigit1, 1
Gui, 2: Add, Button, x582 y129 w70 h70 gDigit2, 2
Gui, 2: Add, Button, x662 y129 w70 h70 gDigit3, 3
Gui, 2: Add, Button, x502 y209 w70 h70 gDigit4, 4
Gui, 2: Add, Button, x582 y209 w70 h70 gDigit5, 5
Gui, 2: Add, Button, x662 y209 w70 h70 gDigit6, 6
Gui, 2: Add, Button, x502 y289 w70 h70 gDigit7, 7
Gui, 2: Add, Button, x582 y289 w70 h70 gDigit8, 8
Gui, 2: Add, Button, x662 y289 w70 h70 gDigit9, 9
Gui, 2: Add, Button, x582 y369 w70 h70 gDigit0, 0
Gui, 2: Add, Button, x662 y369 w70 h70 gCheckGuess, 확인
Gui, 2: Add, Button, x502 y369 w70 h70 gDel, Del
; 폰트 복원
Gui, 2: Font, wNormal

; (B) 입력 Edit
Gui, 2: Add, Edit, x542 y79 w140 h40 vUserInput

; (C) 그룹박스
Gui, 2: Add, GroupBox, x482 y59 w270 h390, 숫자 입력

; (D) 결과창 (흰 글씨, 읽기전용)
Gui, 2: Add, Edit, x52 y59 w370 h590 vResultEdit +ReadOnly cWhite

; (E) 메모용 Edit
Gui, 2: Add, Edit, x482 y469 w270 h180 vMemoEdit

; (F) 힌트 모드
Gui, 2: Add, CheckBox, x652 y29 w100 h30 vHintMode, 힌트 모드

; (G) 룰 설명
Gui, 2: Add, Text, x52 y19 w230 h30,
(
1) 컴퓨터는 중복되지 않는 숫자를 랜덤으로 선택합니다.
2) 플레이어는 해당 숫자를 추측하여 입력합니다.
3) 숫자와 위치가 모두 맞으면 '스트라이크', 숫자만 맞으면 '볼', 틀리면 '아웃'입니다.
4) 입력한 숫자는 중복될 수 없습니다.
)

; (H) 경과 시간
Gui, 2: Add, Text, x332 y29 w160 h20 vTimeText, 경과 시간: 0초

Gui, 2: Show, x849 y458 w771 h675, 숫자 야구 게임

; (D-2) 결과창 배경을 완전 검정으로 강제 (EM_SETBKGNDCOLOR)
GuiControlGet, hEdit, 2: Hwnd, ResultEdit
if (hEdit)
    SendMessage, 0x701, 0, 0x000000,, ahk_id %hEdit%  ; 0x701 = EM_SETBKGNDCOLOR

; 1초마다 경과 시간 갱신
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
if (A_ThisLabel = "Digit0")
    curValue .= "0"
else if (A_ThisLabel = "Digit1")
    curValue .= "1"
else if (A_ThisLabel = "Digit2")
    curValue .= "2"
else if (A_ThisLabel = "Digit3")
    curValue .= "3"
else if (A_ThisLabel = "Digit4")
    curValue .= "4"
else if (A_ThisLabel = "Digit5")
    curValue .= "5"
else if (A_ThisLabel = "Digit6")
    curValue .= "6"
else if (A_ThisLabel = "Digit7")
    curValue .= "7"
else if (A_ThisLabel = "Digit8")
    curValue .= "8"
else if (A_ThisLabel = "Digit9")
    curValue .= "9"

; 자리수 초과 시 TOPMOST 메시지 표시 & 마지막 문자 제거
if (StrLen(curValue) > digitCount)
{
    ; 0x4030 = 0x40000(MB_TOPMOST) + 0x30(MB_ICONWARNING)
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

; 결과창에 추가
GuiControlGet, curResult, 2:, ResultEdit
newLine := "시도 " tryCount ": " userInput " => " strikeCount " S, " ballCount " B, " outCount " O`r`n"
GuiControl, 2:, ResultEdit, % curResult . newLine

; 정답 확인
if (strikeCount = digitCount)
{
    SetTimer, UpdateTime, Off
    totalTime := Floor((A_TickCount - startTime) / 1000)
    MsgBox, 64, 축하합니다!,
    (
        정답: %secretNumber%
        시도 횟수: %tryCount%
        소요 시간(초): %totalTime%
    )
    Gui, 2: Destroy
    ExitApp
}

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
