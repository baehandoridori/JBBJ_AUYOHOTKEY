; 성능 및 메모리 최적화 설정
ListLines, Off
#KeyHistory, 0
#Warn

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; 전역 변수 선언
global savedFilePath
global savedFileName
global savedFileDir
global attachFile := false  ; 파일 첨부 여부를 저장할 변수

; Alt+F12를 핫키로 설정
!F12::
    ; 한글 입력 모드일 경우 영어로 전환
    SetEnglishInputMode()

    ; 현재 선택된 파일의 전체 경로를 가져옵니다
    Send, {F2}
    Sleep, 100
    Send, ^c
    Sleep, 100
    Send, {Esc}
    ClipWait, 2
    if ErrorLevel
    {
        MsgBox, 파일 이름을 가져오지 못했습니다.
        return
    }
    savedFileName := Clipboard
    Clipboard := ""

    ; 전체 경로 복사
    Send, ^c
    Sleep, 100
    ClipWait, 2
    if ErrorLevel
    {
        MsgBox, 파일 경로를 가져오지 못했습니다.
        return
    }
    savedFilePath := Clipboard
    Clipboard := ""

    ; 파일 경로에서 디렉터리 경로를 추출합니다
    SplitPath, savedFilePath, , savedFileDir

    ; 사용자 선택 GUI 생성
    Gui, +AlwaysOnTop
    Gui, Add, Text, x10 y10 w200 h20, 전송할 사용자를 선택하세요:
    Gui, Add, Button, x10 y40 w100 h30 gYoonSeongwon, 윤성원
    Gui, Add, Button, x120 y40 w100 h30 gHeoHyewon, 허혜원
    Gui, Add, Button, x10 y80 w100 h30 gBaeHansol, 배한솔
    Gui, Add, Button, x120 y80 w100 h30 gKangSunyoung, 강선영
    Gui, Add, Checkbox, x10 y120 vAttachFile, 파일 같이 첨부하기
    Gui, Show, w240 h160, 사용자 선택

return

; 한글 입력 모드일 경우 영어로 전환하는 함수
SetEnglishInputMode() {
    InputLocale := DllCall("GetKeyboardLayout", "UInt", DllCall("GetWindowThreadProcessId", "UInt", WinActive("A"), "UInt", 0))
    if (InputLocale == 0x4120412)
    {
        Send, {VK15}
        Sleep, 100
    }
}

; 메세지를 사용자에게 전송하는 함수
SendMessageToUser(userName) {
    ; 체크박스 상태 가져오기
    Gui, Submit, NoHide
    attachFile := AttachFile  ; 체크박스 상태 저장

    ; Slack 창 찾기 (ahk_id가 가장 작은 창)
    slackHwnd := GetMainSlackWindow()
    if (!slackHwnd)
    {
        MsgBox, Slack 주 창을 찾을 수 없습니다.
        return
    }

    ; Slack 창 활성화
    WinActivate, ahk_id %slackHwnd%
    WinWaitActive, ahk_id %slackHwnd%, , 5
    if ErrorLevel
    {
        MsgBox, Slack 창을 활성화할 수 없습니다.
        return
    }
    Sleep, 500

    ; 한글 입력 모드일 경우 영어로 전환
    SetEnglishInputMode()
    Sleep, 100

    ; 새 DM 시작 (Ctrl+Shift+K)
    SendInput, ^+k
    Sleep, 500

    ; 사용자 이름 입력
    SendRaw, %userName%
    Sleep, 500
    SendInput, {Enter}
    Sleep, 500

    ; 사용자 이름 입력 후 Tab 키 입력
    SendInput, {Tab}
    Sleep, 200



    ; 메시지 작성
    ; 파일 이모지와 안내 문구 입력
    SendRaw, :열린_파일_폴더: 파일 공유드립니다! :열린_파일_폴더:
    Sleep, 100

    ; 줄바꿈 (Shift+Enter)
    SendInput, +{Enter}
    Sleep, 200

    ; 클립보드 내용 백업
    previousClipboard := ClipboardAll
    Clipboard := ""

    ; 코드 블록 시작 (Ctrl+Shift+9)
    SendInput, ^+9
    Sleep, 100

    ; 디렉터리 경로를 클립보드에 저장하고 붙여넣기
    Clipboard := savedFileDir
    Sleep, 100
    ClipWait, 1
    SendInput, ^v
    Sleep, 200

    ; 줄바꿈 (Shift+Enter)
    SendInput, +{Enter}
    Sleep, 200

    ; "파일 이름 : " 입력
    SendRaw, 파일 이름 : 
    Sleep, 100

    ; 볼드 서식 시작 (Ctrl+B)
    SendInput, ^b
    Sleep, 100

    ; 파일 이름에 볼드 서식을 적용하여 클립보드에 저장
    Clipboard := "*" . savedFileName . "*"
    Sleep, 100
    ClipWait, 1
    SendInput, ^v
    Sleep, 200

    ; 줄바꿈
    SendInput, +{Enter}
    Sleep, 200

    ; 코드 블록 종료 (Ctrl+Shift+9)
    SendInput, ^+9
    Sleep, 100

    ; 마크다운 적용 (Ctrl+Shift+F 두 번)
    SendInput, ^+{F}
    Sleep, 100
    SendInput, ^+{F}

    ; 파일 첨부 기능
    if (attachFile)
    {
        ; 파일 첨부 버튼 클릭 (Ctrl++U)
        SendInput, ^u
        Sleep, 500

        ; 파일 경로 입력
        Clipboard := savedFilePath
        Sleep, 100
        ClipWait, 1
        SendInput, ^v
        Sleep, 500

        ; Enter 키로 파일 선택 완료
        SendInput, {Enter}
        Sleep, 500  ; 파일 업로드 대기

    }




    ; 클립보드 내용 복원
    Clipboard := previousClipboard
}

; Slack 주 창을 찾는 함수 (ahk_id가 가장 작은 창 선택)
GetMainSlackWindow() {
    WinGet, idList, List, ahk_exe slack.exe
    if (idList > 0)
    {
        minHwnd := idList1
        minId := minHwnd + 0  ; 문자열을 숫자로 변환
        Loop, %idList%
        {
            hwnd := idList%A_Index%
            hwndId := hwnd + 0
            if (hwndId < minId)
            {
                minId := hwndId
                minHwnd := hwnd
            }
        }
        return minHwnd
    }
    else
    {
        return ""
    }
}

; 각 사용자별 처리 함수
YoonSeongwon:
    Gui, Destroy
    SendMessageToUser("윤성원")
return

HeoHyewon:
    Gui, Destroy
    SendMessageToUser("허혜원")
return

BaeHansol:
    Gui, Destroy
    SendMessageToUser("배한솔")
return

KangSunyoung:
    Gui, Destroy
    SendMessageToUser("강선영")
return

; GUI 닫기 처리
GuiClose:
GuiEscape:
    Gui, Destroy
return
