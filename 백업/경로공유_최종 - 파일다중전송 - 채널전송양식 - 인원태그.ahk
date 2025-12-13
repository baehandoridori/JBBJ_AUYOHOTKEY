; 성능 및 메모리 최적화 설정
ListLines, Off
#KeyHistory, 0
#Warn
#SingleInstance Force

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
    Send, ^A
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
    Gui, Add, Text, x10 y10 w200 h20, 전송할 대상을 선택하세요:

    ; 사람에게 공유 그룹
    Gui, Add, Text, x10 y40 w200 h20, 사람에게 공유:
    Gui, Add, Button, x10 y70 w110 h30 gAnRyoocheon, 안류천
    Gui, Add, Button, x130 y70 w110 h30 gYoonSeongwon, 윤성원
    Gui, Add, Button, x10 y110 w110 h30 gHeoHyewon, 허혜원
    Gui, Add, Button, x130 y110 w110 h30 gJiJeongmin, 지정민
    Gui, Add, Button, x10 y150 w110 h30 gWonDongwoo, 원동우
    Gui, Add, Button, x130 y150 w110 h30 gKangSunyoung, 강선영
    Gui, Add, Button, x10 y190 w110 h30 gParkJeongin, 박정인
    Gui, Add, Button, x130 y190 w110 h30 gLeeMyeonghoon, 이명훈
    Gui, Add, Button, x10 y230 w110 h30 gLeeHyemin, 이혜민
    Gui, Add, Button, x130 y230 w110 h30 gJoYeorae, 조여래
    Gui, Add, Button, x10 y270 w110 h30 gBaeHansol, 배한솔
    Gui, Add, Button, x130 y270 w110 h30 gLeeDaeun, 이다은
    Gui, Add, Button, x10 y310 w110 h30 gKimSooyeon, 김수연
    Gui, Add, Button, x130 y310 w110 h30 gJeonHyerim, 전혜림
    Gui, Add, Button, x10 y350 w110 h30 gJangJaeyoung, 장재영
    Gui, Add, Button, x130 y350 w110 h30 gKangJiyung, 강지융

    ; 채널에 전송 그룹
    Gui, Add, Text, x10 y390 w200 h20, 채널에 전송:
    Gui, Add, Button, x10 y420 w230 h30 gSakopakOriginal, 사코팍-오리지널
    Gui, Add, Button, x10 y460 w230 h30 gSakopakMembership, 사코팍-일반-멤버십
    Gui, Add, Button, x10 y500 w230 h30 gSakopakBackground, 사코팍-background
    Gui, Add, Button, x10 y540 w230 h30 gSakopakCharacter, 사코팍-character
    Gui, Add, Button, x10 y580 w230 h30 gSakopakIpInsta, 사코팍-ip-insta

    ; 파일 첨부 체크박스
    Gui, Add, Checkbox, x10 y620 vattachFile, 파일 같이 첨부하기
    Gui, Show, w250 h660, 대상 선택


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



; **********************디버깅용 함수*************************
;SendMessageToUser(userName) {
;    global attachFile, savedFileDir, savedFileName, savedFilePath

    ; 체크박스 상태 가져오기
;    Gui, Submit, NoHide

    ; attachFile 변수 값 확인 (디버깅용)
;    MsgBox, attachFile의 값은 %attachFile%입니다.

    ; 나머지 코드...
;}
; **********************디버깅용 함수***************************



; 메세지를 사용자에게 전송하는 함수
SendMessageToUser(userName) {

        ; 필요한 전역 변수 선언
    global attachFile, savedFileDir, savedFileName, savedFilePath


    ; 체크박스 상태 가져오기
    ;Gui, Submit, NoHide
    ; attachFile 변수는 이미 설정되었으므로 추가 할당 불필요
        ; attachFile 변수 값 확인 (디버깅용)
    ;MsgBox, attachFile의 값은 %attachFile%입니다.


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




    ; 클립보드 내용 복원
    Clipboard := previousClipboard


    ; 파일 첨부 체크박스가 선택된 경우에만 메시지 박스 표시
    if (attachFile)
    {
        ; 파일 첨부 여부를 묻는 알림 메시지 표시
        MsgBox, 4,, 파일도 함께 첨부하시겠습니까?
        IfMsgBox, No
            return

        IfMsgBox, Yes
        {
            ; 파일 첨부 시작

            ; 파일 첨부 버튼 클릭 (Ctrl+U)
            SendInput, ^u
            Sleep, 500

            ; 파일 첨부 대화상자가 나타날 때까지 대기
            WinWaitActive, 열기, , 5  ; '열기'는 파일 탐색기 창의 제목입니다.
            if ErrorLevel
            {
                MsgBox, 파일 첨부 대화상자를 찾을 수 없습니다.
                return
            }

            ; 전체 파일 경로 생성
            fullFilePath := savedFileDir . "\" . savedFileName

            ; 파일 경로를 클립보드에 저장하고 붙여넣기
            previousClipboard2 := ClipboardAll  ; 클립보드 백업
            Clipboard := fullFilePath
            Sleep, 100
            ClipWait, 1
            SendInput, ^v
            Sleep, 500

            ; Enter 키로 파일 선택 완료
            SendInput, {Enter}
            Sleep, 1000  ; 파일 업로드 대기

            ; 클립보드 내용 복원
            Clipboard := previousClipboard2
        }
    }
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

; 각 대상별 처리 함수
AnRyoocheon:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("안류천")
return

YoonSeongwon:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("윤성원")
return

HeoHyewon:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("허혜원")
return

JiJeongmin:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("지정민")
return

WonDongwoo:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("원동우")
return

KangSunyoung:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("강선영")
return

ParkJeongin:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("박정인")
return

LeeMyeonghoon:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("이명훈")
return

LeeHyemin:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("이혜민")
return

JoYeorae:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("조여래")
return

BaeHansol:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("배한솔")
return

LeeDaeun:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("이다은")
return

KimSooyeon:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("김수연")
return

JeonHyerim:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("전혜림")
return

JangJaeyoung:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("장재영")
return

KangJiyung:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("강지융")
return

; 채널에 전송하는 함수들
SakopakOriginal:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("사코팍-오리지널")
return

SakopakMembership:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("사코팍-일반-멤버십")
return

SakopakBackground:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("사코팍-background")
return

SakopakCharacter:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("사코팍-character")
return

SakopakIpInsta:
    Gui, Submit, NoHide  ; 체크박스 상태를 먼저 가져옵니다
    Gui, Destroy
    SendMessageToUser("사코팍-ip-insta")
return

; GUI 닫기 처리
GuiClose:
GuiEscape:
    Gui, Destroy
return
