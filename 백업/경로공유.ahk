; 성능 및 메모리 최적화 설정
ListLines, Off  ; 스크립트의 메모리 사용을 줄이기 위해 실행된 코드 라인을 저장하지 않음
#KeyHistory, 0  ; 키 히스토리 비활성화로 메모리 사용 최적화
#Warn  ; 일반적인 코딩 오류 감지를 위한 경고 활성화

; 기본 AutoHotkey 설정
#NoEnv  ; 환경 변수를 사용하지 않도록 설정하여 성능 향상
SendMode Input  ; SendInput 모드로 설정하여 빠르고 신뢰성 있는 키 입력 지원
SetWorkingDir %A_ScriptDir%  ; 스크립트의 작업 디렉터리를 스크립트가 위치한 곳으로 설정

; 전역 변수 선언
global savedFilePath    ; 선택한 파일의 전체 경로를 저장할 변수
global savedFileName    ; 선택한 파일의 이름을 저장할 변수
global savedFileDir     ; 선택한 파일이 위치한 디렉터리 경로를 저장할 변수

; Alt+F12를 핫키로 설정
!F12::
    ; 한글 입력 모드일 경우 영어로 전환
    SetEnglishInputMode()

    ; 현재 선택된 파일의 전체 경로를 가져옵니다
    Send, {F2}  ; 파일 이름 편집 모드로 진입
    Sleep, 100
    Send, ^c  ; 파일 이름 복사
    Sleep, 100
    Send, {Esc}  ; 편집 모드 종료
    ClipWait, 2  ; 클립보드에 내용이 복사될 때까지 대기
    if ErrorLevel
    {
        MsgBox, 파일 이름을 가져오지 못했습니다.
        return
    }
    savedFileName := Clipboard  ; 파일 이름 저장
    Clipboard := ""  ; 클립보드 초기화

    ; 전체 경로 복사
    Send, ^c  ; 전체 경로 복사
    Sleep, 100
    ClipWait, 2
    if ErrorLevel
    {
        MsgBox, 파일 경로를 가져오지 못했습니다.
        return
    }
    savedFilePath := Clipboard  ; 파일 경로 저장
    Clipboard := ""  ; 클립보드 초기화

    ; 파일 경로에서 디렉터리 경로를 추출합니다
    SplitPath, savedFilePath, , savedFileDir  ; savedFileDir에 디렉터리 경로 저장

    ; 사용자 선택 GUI 생성
    Gui, +AlwaysOnTop  ; GUI를 항상 위에 표시
    Gui, Add, Button, x10 y10 w100 h30 gYoonSeongwon, 윤성원
    Gui, Add, Button, x10 y50 w100 h30 gHeoHyewon, 허혜원
    Gui, Add, Button, x10 y90 w100 h30 gBaeHansol, 배한솔
    Gui, Add, Button, x10 y130 w100 h30 gKangSunyoung, 강선영
    Gui, Show, w120 h170, 사용자 선택  ; GUI 표시

return

; 한글 입력 모드일 경우 영어로 전환하는 함수
SetEnglishInputMode() {
    ; 현재 활성 창의 입력 로케일을 확인하여 영어로 전환
    InputLocale := DllCall("GetKeyboardLayout", "UInt", DllCall("GetWindowThreadProcessId", "UInt", WinActive("A"), "UInt", 0))
    if (InputLocale == 0x4120412) ; 한국어 입력 상태
    {
        Send, {VK15}  ; 한/영 키를 눌러 영어로 전환
        Sleep, 100
    }
}

; 메세지를 사용자에게 전송하는 함수
SendMessageToUser(userName) {
    ; Slack 창 활성화
    WinActivate, ahk_exe slack.exe
    WinWaitActive, ahk_exe slack.exe, , 5
    if ErrorLevel
    {
        MsgBox, Slack 창을 찾을 수 없습니다.
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

    ; 입력 모드를 영어로 전환 (다시 한번 확인)
    SetEnglishInputMode()
    Sleep, 100

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
    ClipWait, 1  ; 클립보드에 내용이 설정될 때까지 대기
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
    ClipWait, 1  ; 클립보드에 내용이 설정될 때까지 대기
    SendInput, ^v
    Sleep, 200

    ; 줄바꿈
    SendInput, +{Enter}
    Sleep, 200

    ; 코드 블록 종료 (Ctrl+Shift+9)
    SendInput, ^+9
    Sleep, 100

    ;마크다운 적용
    SendInput, ^+{F}
    Sleep, 100
    SendInput, ^+{F}

    ; 클립보드 내용 복원
    Clipboard := previousClipboard
}


; 각 사용자별 처리 함수
YoonSeongwon:
    Gui, Destroy  ; GUI 닫기
    SendMessageToUser("윤성원")  ; "윤성원"에게 메세지 전송
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
