#Requires AutoHotkey v2.0
#SingleInstance Force

; UIA 라이브러리 경로는 환경에 맞춰 수정하세요.
; 예: #Include %A_ScriptDir%\Lib\UIA.ahk
#include %A_ScriptDir%\Lib\UIA.ahk

; --------------------------------------
; 매크로 동작을 함수로 분리
macro() {
    Run("ms-settings:")
    Sleep(1000)
    
    ; (만약 v2에서 UIA 객체가 필요하다면 미리 new UIA() 식으로 생성)
    ; 예: global UIA := new UIA()

    ; 1) ApplicationFrameHost 찾기 (Windows 설정)
    ; 여기서부터 질문에서 주신 매크로 동작 그대로:

    ApplicationFrameHostEl := UIA.ElementFromHandle("설정 ahk_exe ApplicationFrameHost.exe")
    ApplicationFrameHostEl.ElementFromPath("X/QXYR7w").Click("left")
    Sleep(1000)

    ApplicationFrameHostEl.ElementFromPath("X/QY87q").Click("left")
    Sleep(1000)
    Sleep(1000)
    Sleep(500)

    ApplicationFrameHostEl.ElementFromPath("X/QR/YR87R0").Click("left")
    Sleep(500)
    Send("{Space}")
    Sleep(1000)

    ApplicationFrameHostEl.ElementFromPath("X/QR/YRq87R0").Click("left")
    Sleep(500)
    Send("{Space}")
    Sleep(500)

    ApplicationFrameHostEl.ElementFromPath("X/QR/YRr0").Click("left")
    Sleep(500)
    Send("{Space}")
    Sleep(500)
}

; --------------------------------------
; 0) 스크립트 실행 시, 안내 메시지 먼저 표시
intro := MsgBox(
    "이 스크립트는 자동한영전환을 위한 스크립트이며, 최초 1회만 설정해도 됩니다.`n" 
  . "설정되는 동안에는 마우스/키보드를 움직이지 말고, 완료 메시지 뜰 때까지 기다려 주세요.`n"
  . "만약 중간에 움직이면 오작동 우려가 있습니다.`n`n"
  . "진행하려면 [예], 그만두려면 [아니오]를 선택하세요."
, "안내", "YesNo" )

; intro 결과가 "Yes"이면 “진행시켜”, "No"면 “안할래”
if (intro = "No") {
    ExitApp()
}

; --------------------------------------
; 1) 우선 매크로를 한 번 실행
macro()

; 2) 이후 무한반복으로 사용자에게 묻고 분기
while true {
    ; “IME가 켬으로 표시되나요?”
    result := MsgBox("이전 버전의 Microsoft IME가 '켬'으로 표시되나요?", "질문", "YesNo")
    if (result = "Yes") {
        ; 사용자: 예 (OS에선 “예”표시, 코드에선 "Yes")
        ExitApp()
    } else {
        ; 사용자: 아니오 ("No")
        result2 := MsgBox("매크로 동작을 다시 실행할까요?", "확인", "YesNo")
        if (result2 = "Yes") {
            macro()
        } else {
            ExitApp()
        }
    }
}
