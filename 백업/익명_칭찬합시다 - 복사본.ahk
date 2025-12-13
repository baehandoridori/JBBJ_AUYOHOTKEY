#Persistent
#NoEnv
#SingleInstance, Force

; ==========================================
; AHK v1 스크립트 예시
; ==========================================

; --- 전역 변수 설정 ---
global SlackWebhookURL := "https://hooks.slack.com/triggers/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"

; 사람 이름과 Slack ID를 매핑할 객체(오브젝트)
; AHK v1에서는 표준 객체 구문 사용
slackIDs := Object()
slackIDs["안류천"] := "U03MAQH93BN"
slackIDs["윤성원"] := "U03H7Q88E1M"
slackIDs["허혜원"] := "U03M1Q37LDU"
slackIDs["원동우"] := "U03MM2B1W73"
slackIDs["지정민"] := "U03MAQGMEN8"
slackIDs["박정인"] := "U03M8AWB49Z"
slackIDs["강선영"] := "U03M8AVUC1H"
slackIDs["이명훈"] := "U03PE3K7539"
slackIDs["이혜민"] := "U03PN339U4E"
slackIDs["조여래"] := "U043S1M5N0G"
slackIDs["배한솔"] := "U05DFV9UAN5"
slackIDs["이다은"] := "U068C1BKPRT"
slackIDs["김수연"] := "U06R5Q9Q4JY"
slackIDs["장재영"] := "U0760LKJ5D4"
slackIDs["강지융"] := "U07AKJGE3HV"
slackIDs["전혜림"] := "U07NBHXV2UW"

; 콤보박스에서 보여줄 사람 목록
; "장삐쭈"의 Slack ID가 따로 제공되지 않아, ID가 있는 사람만 리스트에 넣습니다.
peopleList := "안류천|윤성원|허혜원|원동우|지정민|박정인|강선영|이명훈|이혜민|조여래|배한솔|이다은|김수연|장재영|강지융|전혜림"

; 플레이스홀더 텍스트
placeholderText := "오늘 가습기 물을 채워줬어요! 책임감 있는 모습 칭찬합니다!"

; --- GUI 생성 ---
Gui, +AlwaysOnTop
Gui, Add, Text, x20 y15, 칭찬할 사람 선택
Gui, Add, ComboBox, vSelectedName x20 y40 w200 Choose1, %peopleList%

Gui, Add, Text, x20 y80, 칭찬 내용
Gui, Add, Edit, vPraiseText x20 y100 w300 r5 gEditFocus
; 일단 기본값(플레이스홀더)을 넣어 둠
GuiControl,, PraiseText, %placeholderText%

Gui, Add, Button, x20 y230 w100 h30 gSendPraise, 칭찬하기

Gui, Show, w350 h280, 칭찬봇
return

; --- GUI 이벤트 핸들러: 편집창 포커스 처리 ---
EditFocus:
if (A_GuiEvent = "Focus") {
    GuiControlGet, currentText,, PraiseText
    if (currentText = placeholderText) {
        ; 사용자가 처음 포커스 들어올 때 플레이스홀더와 같으면 지움
        GuiControl,, PraiseText, 
    }
} else if (A_GuiEvent = "LoseFocus") {
    GuiControlGet, currentText,, PraiseText
    if (currentText = "") {
        ; 포커스 잃었는데 아무 내용 없으면 다시 플레이스홀더 복귀
        GuiControl,, PraiseText, %placeholderText%
    }
}
return

; --- GUI 이벤트 핸들러: [칭찬하기] 버튼 ---
SendPraise:
    ; 사용자 입력값 가져오기
    GuiControlGet, selectedName,, SelectedName
    GuiControlGet, praiseText,, PraiseText
    
    ; 만약 플레이스홀더 그대로면 실제 입력이 없는 것으로 판단
    if (praiseText = placeholderText) {
        MsgBox, 48, 알림, 칭찬 내용을 입력해주세요.
        return
    }
    
    ; 선택된 이름에 해당하는 Slack ID
    slackID := slackIDs[selectedName]
    if (!slackID) {
        ; 혹시 리스트에는 있지만 slackIDs 객체에 없는 경우
        MsgBox, 48, 오류, Slack ID가 존재하지 않는 사용자입니다.
        return
    }
    
    ; JSON 바디 구성
    ; AHK의 문자열에서 " 인용부호를 쓰려면 `"(백틱 쌍따옴표)로 이스케이프
    jsonBody := "{""praise_receiver"":""" . slackID . """,""praise_text"":""" . praiseText . """}"

    
    ; HTTP POST 요청 (MSXML2.XMLHTTP 사용)
    httpObj := ComObjCreate("MSXML2.XMLHTTP")
    httpObj.open("POST", SlackWebhookURL, false)
    httpObj.setRequestHeader("Content-Type", "application/json")
    httpObj.send(jsonBody)
    
    ; 슬랙 응답 코드 확인
    status := httpObj.status
    if (status = 200) {
        MsgBox, 64, 전송 완료, 칭찬이 성공적으로 전송되었습니다!
    } else {
        MsgBox, 48, 오류, 슬랙 전송 중 오류가 발생했습니다.`nHTTP 상태 코드: %status%
    }
    
    ; 스크립트 종료
    ExitApp
return

; GUI 닫힘(종료) 이벤트
GuiClose:
ExitApp
