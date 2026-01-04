#NoEnv  ; 환경 변수 사용을 권장하지 않음
#SingleInstance, Force  ; 스크립트 실행 시 이전 인스턴스를 자동으로 대체
SetWorkingDir, %A_ScriptDir%  ; 스크립트의 작업 디렉토리를 스크립트 파일의 디렉토리로 설정

; 글로벌 변수 정의
global FeedbackText  ; 피드백 텍스트를 저장할 변수
global PlaceholderText := "예시 ) 어도비 파이어플라이도 지원 프로그램에 추가해주세요!"  ; 플레이스홀더 텍스트
global IsPlaceholder := true  ; 현재 플레이스홀더가 표시되고 있는지 여부를 추적
global WebhookUrl := "https://hooks.slack.com/triggers/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"

; Webhook 전송을 위한 함수
SendToWebhook(feedbackText, timestamp) {
    static WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    payload := "{""feedback_key"":""" . feedbackText . """, ""feedback_time"":""" . timestamp . """}"
    
    try {
        WinHttpReq.Open("POST", WebhookUrl, true)
        WinHttpReq.SetRequestHeader("Content-Type", "application/json")
        WinHttpReq.Send(payload)
        return true
    } catch e {
        MsgBox, 262160, 전송 오류, Webhook 전송 중 오류가 발생했습니다: %e%
        return false
    }
}

; 피드백 GUI 생성
Gui, Feedback:New, +AlwaysOnTop  ; 항상 최상위에 표시되는 새 GUI 생성
Gui, Feedback:Add, Text,, 피드백을 입력해주세요:  ; 안내 텍스트 추가
Gui, Feedback:Add, Edit, r5 w300 vFeedbackText gUpdatePlaceholder  ; 멀티라인 편집 컨트롤 추가, UpdatePlaceholder 함수와 연결
Gui, Feedback:Add, Button, x10 y+10 w145 gSendFeedback, 전송  ; '전송' 버튼 추가, SendFeedback 함수와 연결
Gui, Feedback:Add, Button, x+10 w145 gCloseFeedback, 닫기  ; '닫기' 버튼 추가, CloseFeedback 함수와 연결
Gui, Feedback:Show,, 피드백 전송  ; GUI 표시

; 초기 플레이스홀더 텍스트 설정
GuiControl,, FeedbackText, %PlaceholderText%  ; Edit 컨트롤에 플레이스홀더 텍스트 설정
GuiControl, +cGray, FeedbackText  ; 플레이스홀더 텍스트 색상을 회색으로 설정

return  ; 자동 실행 섹션 종료

; 플레이스홀더 업데이트 함수
; 이 함수는 Edit 컨트롤의 내용이 변경될 때마다 호출됨
UpdatePlaceholder:
    if (A_GuiEvent == "Normal") {  ; 사용자가 Edit 컨트롤을 클릭했을 때
        ControlGetFocus, FocusedControl, A
        if (FocusedControl == "Edit1" && IsPlaceholder) {  ; Edit 컨트롤에 포커스가 있고 현재 플레이스홀더가 표시 중이라면
            GuiControl,, FeedbackText  ; 플레이스홀더 텍스트 제거
            GuiControl, +cBlack, FeedbackText  ; 텍스트 색상을 검은색으로 변경
            IsPlaceholder := false  ; 플레이스홀더 상태 업데이트
        }
    } else {  ; 텍스트가 변경되었을 때
        Gui, Submit, NoHide  ; GUI 컨트롤의 내용을 변수에 저장 (화면 갱신 없이)
        if (FeedbackText == "") {  ; 텍스트가 비어있다면
            GuiControl,, FeedbackText, %PlaceholderText%  ; 플레이스홀더 텍스트 다시 표시
            GuiControl, +cGray, FeedbackText  ; 텍스트 색상을 회색으로 변경
            IsPlaceholder := true  ; 플레이스홀더 상태 업데이트
        } else if (FeedbackText != PlaceholderText) {  ; 텍스트가 있고 플레이스홀더가 아니라면
            GuiControl, +cBlack, FeedbackText  ; 텍스트 색상을 검은색으로 유지
            IsPlaceholder := false  ; 플레이스홀더 상태 업데이트
        }
    }
return

; 피드백 전송 함수
; '전송' 버튼 클릭 시 호출됨
SendFeedback:
Gui, Feedback:Submit, NoHide
if (FeedbackText != "" && FeedbackText != PlaceholderText) {
    timestamp := A_Now
    feedbackPath := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\feedback"
    
    ; 파일에 저장
    FileAppend, %timestamp%: %FeedbackText%`n, %feedbackPath%\feedback_log.txt
    
    ; Webhook 전송
    if (SendToWebhook(FeedbackText, timestamp)) {
        Gui, Feedback:Destroy
        MsgBox, 262208, 피드백 전송 완료, 피드백이 전송되었습니다. 감사합니다!
        ExitApp
    }
} else {
    MsgBox, 262160, 입력 오류, 피드백 내용을 입력해주세요.
}
return


; GUI 닫기 함수들
; '닫기' 버튼 클릭, GUI 닫기 버튼 클릭, 또는 ESC 키 입력 시 호출됨
CloseFeedback:
FeedbackGuiClose:
FeedbackGuiEscape:
    ExitApp  ; 스크립트 종료

; 키 입력 캡처
; 피드백 창이 활성화되어 있을 때만 동작
#If WinActive("피드백 전송")
~*::  ; 모든 키 입력을 캡처
    if (IsPlaceholder) {  ; 현재 플레이스홀더가 표시 중이라면
        GuiControl,, FeedbackText  ; 플레이스홀더 텍스트 제거
        GuiControl, +cBlack, FeedbackText  ; 텍스트 색상을 검은색으로 변경
        IsPlaceholder := false  ; 플레이스홀더 상태 업데이트
    }
return
#If  ; 조건부 핫키 종료