#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

; -----------------------------
; 1) 전역 변수/설정
; -----------------------------
global SlackWebhookURL := "https://hooks.slack.com/triggers/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"

; 플레이스홀더 관련
global PlaceholderText := "예시 ) 오늘 가습기 물을 채워줬어요! 습기넘치는 모습 칭찬합니다!"
global IsPlaceholder := true

; 사람 이름 <-> Slack ID 매핑
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
SlackIDs["김어진"] := "U090WLY7XLH"
SlackIDs["류이레"] := "U0978NUD5L7"

;todo: 인원 중 퇴사자 있을 시 위 오브젝트, 아래 콤보박스에서 제거. 현재 퇴사자 : 조여래, 김수연
slackIDs.Remove("조여래")
slackIDs.Remove("김수연")

; todo: 추가 인원은 위에 slackIDs 오브젝트에 넣기

; todo: 추가 인원은 아래 콤보박스 목록에도 넣기

; 콤보박스 목록
peopleList := "안류천|윤성원|허혜원|원동우|지정민|박정인|강선영|이명훈|이혜민|배한솔|이다은|장재영|강지융|전혜림|김어진|류이레"

; -----------------------------
; 2) GUI 생성
; -----------------------------
Gui, +

Gui, Add, Text, x20 y15, 칭찬할 사람 선택
Gui, Add, ComboBox, vSelectedName x20 y40 w220 Choose1, %peopleList%

Gui, Add, Text, x20 y80, 칭찬 내용
; Edit 컨트롤 높이를 r4로 수정
Gui, Add, Edit, r4 w300 x20 y100 vPraiseText gUpdatePlaceholder

; 버튼
Gui, Add, Button, x20 y170 w100 h30 gSendPraise, 칭찬하기
Gui, Add, Button, x220 y170 w100 h30 gGuiClose, 칭찬 안하기

Gui, Show, w340 h210, 칭찬봇

; GUI 실행 시점에 플레이스홀더 설정
GuiControl,, PraiseText, %PlaceholderText%
GuiControl, +cGray, PraiseText
IsPlaceholder := true

return  ; -- 스크립트 초기화 끝 --


; ------------------------------------------------
; 3) Edit 컨트롤 내용 변경(타이핑) 감지
; ------------------------------------------------
UpdatePlaceholder:
Gui, Submit, NoHide

if (A_GuiEvent = "Normal") {  ; 키보드 입력이 있을 때
    if (IsPlaceholder) {
        ; 플레이스홀더 텍스트를 완전히 제거
        GuiControl,, PraiseText,
        ; 글자색을 검정으로 변경
        GuiControl, +cBlack, PraiseText
        IsPlaceholder := false
        return
    }
} else if (A_GuiEvent = "Change") {  ; 내용이 변경되었을 때
    if (PraiseText = "") {
        ; 텍스트가 비어있으면 플레이스홀더 복구
        GuiControl,, PraiseText, %PlaceholderText%
        GuiControl, +cGray, PraiseText
        IsPlaceholder := true
    }
}
return

; ------------------------------------------------
; 4) [칭찬하기] 버튼 클릭
; ------------------------------------------------
SendPraise:
    Gui, Submit, NoHide
    ; 플레이스홀더라면 실제 입력이 없다고 판단
    if (PraiseText = "" || PraiseText = PlaceholderText) {
        MsgBox, 48, 입력 오류, 칭찬 내용을 입력해주세요.
        return
    }

    ; 콤보박스에서 선택한 사람
    GuiControlGet, selectedName,, SelectedName
    if (!selectedName) {
        MsgBox, 48, 선택 오류, 칭찬할 사람을 선택해주세요.
        return
    }

    ; Slack ID
    slackID := slackIDs[selectedName]
    if (!slackID) {
        MsgBox, 48, 오류, Slack ID가 존재하지 않습니다: %selectedName%
        return
    }

    ; Webhook 전송용 JSON 바디
    jsonBody := "{""praise_receiver"":""" . slackID . """,""praise_text"":""" . PraiseText . """}"

    ; POST 요청
    httpObj := ComObjCreate("MSXML2.XMLHTTP")
    httpObj.open("POST", SlackWebhookURL, false)
    httpObj.setRequestHeader("Content-Type", "application/json")
    httpObj.send(jsonBody)

    status := httpObj.status
    if (status = 200) {
        MsgBox, 64, 전송 완료, 칭찬이 성공적으로 전송되었습니다!
    } else {
        MsgBox, 48, 오류, 전송 중 오류 발생.`nHTTP 상태 코드: %status%
    }
    ExitApp
return


; ------------------------------------------------
; 5) GUI 닫기
; ------------------------------------------------
GuiClose:
ExitApp
