#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; ---------------------------------------------
; 전역 변수: 오목판 상태 (2D 배열 대신 {"row,col": 값} 형태)
; ---------------------------------------------
global omokBoard := {}

; ---------------------------------------------
; 스크립트 시작부 (auto-execute 구역)
; ---------------------------------------------
InitBoard()
CreateGUI()
return  ; 이 지점까지가 초기 실행부

; ---------------------------------------------
; 함수: InitBoard
;  - 15x15 보드를 0(빈칸)으로 초기화
; ---------------------------------------------
InitBoard()
{
    global omokBoard
    Loop, 15
    {
        row := A_Index
        Loop, 15
        {
            col := A_Index
            omokBoard[row "," col] := 0
        }
    }
}

; ---------------------------------------------
; 함수: CreateGUI
;  - 15x15 버튼을 생성 (각 버튼이 클릭되면 PlaceStoneFunc() 함수를 호출)
; ---------------------------------------------
CreateGUI()
{
    local boardSize, btnW, btnH, offsetX, offsetY
    boardSize := 15
    btnW := 30
    btnH := 30
    offsetX := 20
    offsetY := 20

    Gui, +Resize +MinimizeBox +MaximizeBox
    Gui, Color, White
    Gui, Font, s10
    Gui, Add, Text, x%offsetX% y5 w400 h20, [오목 1단계] 클릭 시 돌 놓기 (흑돌만)

    ; 15x15 버튼을 동적 생성
    Loop, % boardSize
    {
        row := A_Index
        Loop, % boardSize
        {
            col := A_Index

            btnX := offsetX + (col-1)*btnW
            btnY := offsetY + (row-1)*btnH
            ctrlVar := "Cell_" row "_" col

            ; gPlaceStoneFunc() → "PlaceStoneFunc" 함수를 직접 호출
            Gui, Add, Button, x%btnX% y%btnY% w%btnW% h%btnH% v%ctrlVar% gPlaceStoneFunc(), 
        }
    }

    local guiWidth, guiHeight
    guiWidth := offsetX*2 + (boardSize*btnW) + 20
    guiHeight := offsetY*2 + (boardSize*btnH) + 50
    Gui, Show, w%guiWidth% h%guiHeight%, 오목 테스트 1단계
}

; ---------------------------------------------
; 함수: PlaceStoneFunc
;  - 버튼 클릭 시 자동 호출됨 (v1에서 gFunctionName() 문법)
;  - 오목판 상태를 갱신하고 돌을 표시
; ---------------------------------------------
PlaceStoneFunc()
{
    ; A_GuiControl: 방금 클릭된 GUI 컨트롤(변수명)
    global omokBoard, A_GuiControl

    varName := A_GuiControl  ; 예: "Cell_3_7"

    ; "Cell_3_7"에서 row=3, col=7 식으로 추출
    StringSplit, dummy, varName, _
    row := dummy2
    col := dummy3

    ; 아직 돌이 없는 자리(0)면 흑돌(1) 놓기
    if (omokBoard[row "," col] = 0)
    {
        omokBoard[row "," col] := 1
        GuiControl,, %varName%, ●
    }
    else
    {
        MsgBox, 이미 돌이 놓여있는 위치입니다!
    }
}

; ---------------------------------------------
; GUI 닫기/종료 라벨 (함수 아님)
; ---------------------------------------------
GuiClose:
GuiEscape:
ExitApp
