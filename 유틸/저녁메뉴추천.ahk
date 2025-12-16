#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1

; 메뉴 목록 추천받아야 함
menus := ["카츠와", "시장냉면", "돈수백", "밥순이네", "은행골", "비스트로큐슈", "미분당", "피자스쿨", "니쥬버거", "무라", "모미모미", "림가기", "샤브로21", "왕소야(짱개)", "흥부네부대찌개", "부탄츄", "틈새라면", "샐러디(배달)", "오복순대국", "가이오순대국","닭한마리", "스아게", "율촌", "서브웨이", "롯데리아(배달)", "맥도날드(배달)", "버거킹(배달)", "페리카나(배달)", "멕시칸(배달)", "굶어", "파스타고", "행복갈비탕", "오향족발", "김치찜", "니뽕내뽕" ]

; 워크플로 웹후크 URL 이거 전역변수 아니고 로컬로만
webhookURL := "https://hooks.slack.com/triggers/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"

; 전역 변수
global SelectedMenu := ""
global timerInterval := 50
global totalDuration := 2500  ; 전체 슬롯머신 진행 시간 (밀리초)
global startTime, elapsedTime

; GUI 생성
Gui, +AlwaysOnTop
Gui, Font, S12, 맑은 고딕
Gui, Add, Text, x10 y10 w280 h30 Center vDisplayText, 저녁 메뉴 추천
Gui, Add, Button, x30 y50 w80 h30 gStartSlotMachine, 저메추
Gui, Add, Button, x120 y50 w80 h30 gStartSlotMachine vRePickBtn Disabled, 다시 뽑기
Gui, Add, Button, x210 y50 w80 h30 gSendRecommendation vRecommendBtn Hidden, 추천하기
Gui, Add, Progress, x10 y90 w280 h20 vProgressBar Range0-100
Gui, Show, w300 h130, 저녁 메뉴 추천기
return

; 슬롯머신 시작
StartSlotMachine:
    GuiControl,, DisplayText, 선택 중...
    GuiControl, Disable, RePickBtn
    GuiControl, Hide, RecommendBtn
    GuiControl,, ProgressBar, 0
    ProgressValue := 0
    timerInterval := 50  ; 초기 타이머 간격
    SetTimer, UpdateMenu, %timerInterval%
    startTime := A_TickCount
return

; 메뉴 업데이트
UpdateMenu:
    elapsedTime := A_TickCount - startTime

    ; 프로그레스 바 업데이트
    ProgressValue := (elapsedTime / totalDuration) * 100
    if (ProgressValue > 100)
        ProgressValue := 100
    GuiControl,, ProgressBar, %ProgressValue%

    ; 슬롯머신 종료 조건
    if (elapsedTime >= totalDuration)
    {
        SetTimer, UpdateMenu, Off
        ; 랜덤으로 메뉴 선택
        Random, SelectedIndex, 1, % menus.Length()
        SelectedMenu := menus[SelectedIndex]
        GuiControl,, DisplayText, 오늘의 저녁은 "%SelectedMenu%" 어떠신가요?

        ; 다시 뽑기 버튼 활성화
        GuiControl, Enable, RePickBtn

        ; 추천하기 버튼 표시
        GuiControl, Show, RecommendBtn
        return
    }

    ; 메뉴 목록에서 랜덤으로 하나 표시
    Random, Index, 1, % menus.Length()
    CurrentMenu := menus[Index]
    GuiControl,, DisplayText, %CurrentMenu%

    ; 타이머 간격 조절 (점진적으로 느려짐)
    newInterval := timerInterval * 1.02  ; 타이머 간격을 5%씩 증가
    if (newInterval > 200)  ; 최대 간격 제한
        newInterval := 200
    timerInterval := newInterval
    SetTimer, UpdateMenu, Off
    SetTimer, UpdateMenu, % Round(timerInterval)
return

; 추천하기 버튼 클릭 시 웹후크로 메뉴 전송
SendRecommendation:
    if (SelectedMenu != "")
    {
        ; Slack 웹후크로 메뉴 전송
        SendWebhook("오늘의 저녁은 '" . SelectedMenu . "' 어떠신가요?")
        MsgBox, 정보, 전송 완료, 추천한 메뉴를 Slack에 전송하였습니다.
    }
    else
    {
        MsgBox, 경고, 메뉴 선택 필요, 먼저 메뉴를 선택해 주세요.
    }
return

; 웹후크로 메뉴 전송
SendWebhook(menuItem)
{
    global webhookURL
    jsonData := "{" . Chr(34) . "menu_item" . Chr(34) . ":" . Chr(34) . menuItem . Chr(34) . "}"

    ; WinHttpRequest 객체 생성
    req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    req.Open("POST", webhookURL, false)
    req.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
    req.Send(jsonData)

    ; 응답 확인 (필요 시)
    status := req.Status
    responseText := req.ResponseText
    if (status != 200) {
        MsgBox, 웹후크 전송 실패: %status%`n%responseText%
    }
}

GuiClose:
ExitApp
