; ============================================================================
; 성능 및 메모리 최적화 설정
; ============================================================================
ListLines, Off           ; 스크립트 실행 시, 상세한 실행 로그(ListLines)를 끔
#KeyHistory, 0           ; 키보드 히스토리를 보이지 않도록 설정
#Warn                    ; 경고를 표시(변수 충돌 등) - 디버깅용
#SingleInstance Force    ; 이미 스크립트가 실행 중이면, 새로 실행 시 이전 스크립트를 종료
#NoEnv                   ; 구버전 호환 옵션 - 환경 변수 사용 안 함
SendMode Input           ; Send 입력 모드를 "Input"으로 설정
SetWorkingDir %A_ScriptDir%  ; 스크립트가 있는 폴더를 작업 디렉토리로 설정

; ============================================================================
; 전역 변수 선언
; - 여기 있는 변수들은 스크립트 전체에서 사용 가능한 전역 변수들입니다.
; - 파일 경로/이름, 체크박스 상태, 멘션 목록, 채널 등등
; ============================================================================
global savedFilePath        ; 복수 파일 전체 경로(줄바꿈으로 구분)
global savedFileName        ; 첫 번째 파일명만 (F2로 복사 시 읽힌 것)
global savedFileDir         ; 선택 파일들의 공통 디렉터리 경로
global attachFile := false  ; "파일 같이 첨부하기" 체크박스 상태(true/false)
global filePathCount        ; 선택된 파일(경로)의 개수
global fileNameCount        ; 선택된 파일(이름)의 개수

; 채널 GUI에서 입력받을 전역 변수들 (에피소드 제목, 공유 내용)
global gEpisodeTitle := ""
global gShareContent := ""
; 사용자가 클릭한 채널 이름을 임시 저장
global gChannelName := ""
; @멘션할 팀원들 목록을 저장해둘 전역 변수
global gMentionList := ""

; 전통적인 AHK pseudo-array:
;   filePathList1, filePathList2, ...
;   fileNameList1, fileNameList2, ...
; 이 스크립트에서는 Loop, Parse 를 통해 개별 파일 경로/이름을 각각 저장합니다.

; ============================================================================
; Alt+F12 핫키
; - 파일/폴더를 선택한 뒤 Alt+F12를 누르면, 아래의 과정이 실행됩니다.
; ============================================================================
!F12::
{
    ; 1) 먼저 한글 입력 상태라면 영어로 전환 (Slack에서 채널/명령어 입력 시 깨지는 걸 방지)
    SetEnglishInputMode()

    ; 2) F2 → Ctrl+A → Ctrl+C → Esc 로 첫 번째 파일 이름을 가져옵니다.
    ;    (Windows에서 파일이나 폴더를 하나 이상 선택했을 때 '이름' 항목을 복사하는 동작)
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

    ; 3) 이어서, 전체 파일 경로(여러 개일 수 있음)를 복사.
    ;    여러 파일을 선택하면, 줄바꿈(`r`n)으로 구분되어 복사됩니다.
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

    ; 4) pseudo-array 초기화 (파일 경로/이름 개수를 0으로 초기화)
    filePathCount := 0
    fileNameCount := 0

    ; 5) 줄바꿈(`r`n)을 기준으로 파일 경로를 한 줄씩 꺼내서
    ;    filePathList1, filePathList2 ... 이런 식으로 차곡차곡 저장
    Loop, Parse, savedFilePath, `r`n
    {
        if (A_LoopField = "")
            continue  ; 공백 줄이면 무시

        filePathCount++
        filePathList%filePathCount% := A_LoopField
    }

    ; 첫 번째 파일 경로로부터, "공통 디렉토리"를 추출
    if (filePathCount >= 1)
    {
        SplitPath, filePathList1, outName, outDir
        savedFileDir := outDir
    }

    ; 6) 각 파일 경로에서 파일 이름만 추출해서 fileNameList1,2... 에 저장
    ;    (예: C:\Work\Doc.txt → Doc.txt)
    Loop, %filePathCount%
    {
        SplitPath, filePathList%A_Index%, onlyName, onlyDir
        fileNameCount++
        fileNameList%fileNameCount% := onlyName
    }

    ; 7) "대상 선택" GUI를 화면에 표시
    Gui, +AlwaysOnTop
    Gui, Add, Text, x10 y10 w200 h20, 전송할 대상을 선택하세요:

    ; (사람에게 공유) 부분
    Gui, Add, Text, x10 y40 w200 h20, 사람에게 공유:
    Gui, Add, Button, x10  y70  w110 h30 gAnRyoocheon,  안류천
    Gui, Add, Button, x130 y70  w110 h30 gYoonSeongwon, 윤성원
    Gui, Add, Button, x10  y110 w110 h30 gHeoHyewon,    허혜원
    Gui, Add, Button, x130 y110 w110 h30 gJiJeongmin,   지정민
    Gui, Add, Button, x10  y150 w110 h30 gWonDongwoo,   원동우
    Gui, Add, Button, x130 y150 w110 h30 gKangSunyoung, 강선영
    Gui, Add, Button, x10  y190 w110 h30 gParkJeongin,  박정인
    Gui, Add, Button, x130 y190 w110 h30 gLeeMyeonghoon,이명훈
    Gui, Add, Button, x10  y230 w110 h30 gLeeHyemin,    이혜민
    Gui, Add, Button, x130 y230 w110 h30 gBaeHansol,    배한솔
    Gui, Add, Button, x10  y270 w110 h30 gLeeDaeun,     이다은
    Gui, Add, Button, x130 y270 w110 h30 gJeonHyerim,   전혜림
    Gui, Add, Button, x10  y310 w110 h30 gJangJaeyoung, 장재영
    Gui, Add, Button, x130 y310 w110 h30 gKangJiyung,   강지융
    Gui, Add, Button, x10  y350 w110 h30 gKimEojin,     김어진
    Gui, Add, Button, x130 y350 w110 h30 gRyu,          류이레

    ; (채널에 전송) 부분
    Gui, Add, Text, x10 y390 w200 h20, 채널에 전송:
    Gui, Add, Button, x10  y420 w230 h30 gSakopakOriginal,   사코팍-오리지널
    Gui, Add, Button, x10  y460 w230 h30 gSakopakMembership, 사코팍-일반-멤버십
    Gui, Add, Button, x10  y500 w230 h30 gSakopakBackground, 사코팍-background
    Gui, Add, Button, x10  y540 w230 h30 gSakopakCharacter,  사코팍-character
    Gui, Add, Button, x10  y580 w230 h30 gSakopakIpInsta,    사코팍-ip-insta

    ; "파일 같이 첨부하기" 체크박스 (기본 체크 상태)
    Gui, Add, Checkbox, x10 y620 vattachFile Checked, 파일 같이 첨부하기
    Gui, Show, w250 h660, 대상 선택

    return
}

; ============================================================================
; 한글 입력 모드일 경우, 영어로 전환하는 함수
; - 슬랙에서 채널명이나 영문 키워드가 깨지지 않도록 대비
; ============================================================================
SetEnglishInputMode() {
    InputLocale := DllCall("GetKeyboardLayout", "UInt"
                  , DllCall("GetWindowThreadProcessId", "UInt", WinActive("A"), "UInt", 0))
    if (InputLocale == 0x4120412)  ; 한글(0x0412)이면
    {
        Send, {VK15}  ; 한/영 키 전환
        Sleep, 100
    }
}

; ============================================================================
; -- (1) 채널 GUI 표시 함수 --
;     "에피소드 제목 / 공유 내용"을 입력하고
;     멘션할 팀원들을 체크박스로 선택할 수 있는 GUI를 띄웁니다.
; ============================================================================
ShowChannelGui(channelName)
{
    global gChannelName
    global gEpisodeTitle
    global gShareContent
    global gMentionList  ; 최종 @멘션 목록을 담을 전역변수

    ; 어떤 채널인지 기억
    gChannelName := channelName

    ; 필요한 전역 변수들 초기화
    gEpisodeTitle := ""
    gShareContent := ""
    gMentionList := ""

    ; 2번 GUI(채널 전송 GUI)를 새로 띄우기 전에 Clear
    Gui, 2:Destroy
    Gui, 2:+AlwaysOnTop
    Gui, 2:Default

    ; ┌─────────────────────────────────────────────────────────────────────────┐
    ; │ 이 부분에서 폰트 설정(Gui, Font)을 통해 GUI 글씨 크기나 색상을 바꿀 수 있음.   │
    ; └─────────────────────────────────────────────────────────────────────────┘
    ; (A) 에피소드 제목 / 공유 내용
    Gui, Font, S13 Bold, Verdana
    Gui, 2:Add, Text, x90  y9  w140 h20 +Center, 공유 항목을 입력해주세요.
    Gui, Font, S10 CDefault norm, Verdana
    Gui, 2:Add, Text, x12  y29 w160 h20 , 에피소드 제목
    Gui, 2:Add, Edit, x12  y49 w160 h30 vepisodeTitle
    Gui, 2:Add, Text, x192 y29 w160 h20 , 공유 내용
    Gui, 2:Add, Edit, x192 y49 w160 h30 vshareContent

    ; 읽기전용 Edit (예시로 어떤 값이 들어가는지 안내)
    Gui, 2:Add, Edit, x12  y89 w160 h30 ReadOnly, 예시) 지웅이게임(오리지널)
    Gui, 2:Add, Edit, x192 y89 w160 h30 ReadOnly, 예시) 배경 컨셉아트 공유

    ; (B) 팀원 이름 체크박스 (복수 선택 가능)
    Gui, 2:Add, Text, x12  y149 w340 h20 , 함께 멘션할 팀원 선택:
    ; 예시로 몇 분만 추가했지만, 필요한 만큼 더 추가해도 됩니다.
    ; 추가/삭제 시, 아래와 같이 Copy+Paste로 늘리면 됩니다.
    Gui, 2:Add, Checkbox, x20  y179 vcbAnRyoocheon,  안류천
    Gui, 2:Add, Checkbox, x20  y209 vcbYoonSeongwon, 윤성원
    Gui, 2:Add, Checkbox, x20  y239 vcbHeoHyewon,    허혜원
    Gui, 2:Add, Checkbox, x20  y269 vcbJiJeongmin,   지정민
    Gui, 2:Add, Checkbox, x20  y299 vcbWonDongwoo,   원동우
    Gui, 2:Add, Checkbox, x100 y179 vcbKangSunyoung, 강선영
    Gui, 2:Add, Checkbox, x100 y209 vcbParkJeongin,  박정인
    Gui, 2:Add, Checkbox, x100 y239 vcbLeeMyeonghoon,이명훈
    Gui, 2:Add, Checkbox, x100 y269 vcbLeeHyemin,    이혜민
    Gui, 2:Add, Checkbox, x100 y299 vcbBaeHansol,    배한솔
    Gui, 2:Add, Checkbox, x180 y179 vcbLeeDaeun,     이다은
    Gui, 2:Add, Checkbox, x180 y209 vcbJeonHyerim,   전혜림
    Gui, 2:Add, Checkbox, x180 y239 vcbJangJaeyoung, 장재영
    Gui, 2:Add, Checkbox, x180 y269 vcbKangJiyung,   강지융
    Gui, 2:Add, Checkbox, x260 y209 vcbKimEojin,     김어진
    Gui, 2:add, Checkbox, x260 y239 vcRyu,           류이레  
    
    ; 굵은 빨간 텍스트로 강조된 팀원(예시)
    Gui, Font, S13 Cred Bold, Verdana
    Gui, 2:Add, Checkbox, x260 y179 vcbJBJ, 장삐쭈

    ; (C) 확인 버튼
    Gui, 2:Add, Button, x280 y310 w80 h30 gChannelOk, 확인

    Gui, 2:Show, x818 y623 w380 h355, 채널 공유 GUI

    return
}

; GUI 닫기 처리(2번 GUI)
2GuiClose:
GuiEscape2:
    ; 2번 GUI만 닫습니다.
    Gui, 2:Destroy
return

; ============================================================================
; (2) 채널 GUI에서 '확인' 버튼 눌렀을 때
; - 에피소드 제목/공유 내용, 체크박스로 선택된 팀원들을 전역 변수에 저장
; - 이후, SendMessageToUser() 함수를 호출해서 실제로 Slack으로 전송
; ============================================================================
ChannelOk:
Gui, 2:Submit, NoHide
{
    global gEpisodeTitle, gShareContent
    global gChannelName
    global gMentionList

    ; (A) Edit 컨트롤로부터 입력받은 텍스트 보관
    gEpisodeTitle := episodeTitle
    gShareContent := shareContent

    ; (B) 체크박스로부터 선택된 사람들 추려내기
    ;     체크된 항목(값이 "1")에 대해서만 "@이름" 형태로 연결
    gMentionList := ""
    if (cbJBJ = "1")
        gMentionList .= " @장삐쭈"
    if (cbAnRyoocheon = "1")
        gMentionList .= " @안류천"
    if (cbYoonSeongwon = "1")
        gMentionList .= " @윤성원"
    if (cbHeoHyewon = "1")
        gMentionList .= " @허혜원"
    if (cbJiJeongmin = "1")
        gMentionList .= " @지정민"
    if (cbWonDongwoo = "1")
        gMentionList .= " @원동우"
    if (cbKangSunyoung = "1")
        gMentionList .= " @강선영"
    if (cbParkJeongin = "1")
        gMentionList .= " @박정인"
    if (cbLeeMyeonghoon = "1")
        gMentionList .= " @이명훈"
    if (cbLeeHyemin = "1")
        gMentionList .= " @이혜민"
    if (cbBaeHansol = "1")
        gMentionList .= " @배한솔"
    if (cbLeeDaeun = "1")
        gMentionList .= " @이다은"
    if (cbJeonHyerim = "1")
        gMentionList .= " @전혜림"
    if (cbJangJaeyoung = "1")
        gMentionList .= " @장재영"
    if (cbKangJiyung = "1")
        gMentionList .= " @강지융"
    if (cbKimEojin = "1")
        gMentionList .= " @김어진"
    if (cbRyu = "1")
        gMentionList .= " @류이레"

    ; GUI 닫고, 실제 전송 함수 호출
    Gui, 2:Destroy
    SendMessageToUser(gChannelName)
}
return

; ============================================================================
; 메세지를 사용자(또는 채널)에 전송하는 함수
; - 최종적으로 Slack 창을 찾아서 파일 정보 / 채널 정보 / 멘션 / 파일 첨부 등을 합니다.
; ============================================================================
SendMessageToUser(userName) {
    global attachFile
    global savedFileDir
    global filePathCount
    global fileNameCount

    ; 채널용 추가 전역변수 (에피소드/공유내용)
    global gEpisodeTitle
    global gShareContent

    ; Slack 주 창 찾기
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

    ; 혹시 한글 입력이면 영어로 전환
    SetEnglishInputMode()
    Sleep, 100

    ; (1) 새 DM(또는 채널) 시작 (Ctrl+Shift+K)
    SendInput, ^+k
    Sleep, 500

    ; --- 영어 입력 모드 강제 전환 및 채널/사용자 이름 붙여넣기 ---
    SetEnglishInputMode()
    Sleep, 100

    prevClip := ClipboardAll
    Clipboard := userName
    Sleep, 100
    ClipWait, 1

    SendInput, ^v
    Sleep, 300
    SendInput, {Enter}
    Sleep, 500

    Clipboard := prevClip
    prevClip := ""
    ; --------------------------------------------------------------

; -------------------------------------------------
; (1-A) 채널일 때만 + 입력값이 있을 때만
;       [ 에피소드 / 공유내용 ] 형식으로 추가
; -------------------------------------------------
if (InStr(userName, "사코팍-"))  ; "사코팍-"이 들어있으면 채널로 간주
{
    if (gEpisodeTitle != "" or gShareContent != "")
    {
        previousClip := ClipboardAll

        fullText := "*[ " . gEpisodeTitle . " / " . gShareContent . " ]*"
        Clipboard := fullText
        Sleep, 100
        ClipWait, 1
        SendInput, ^v
        Sleep, 200

        ; 줄바꿈 2번
        SendInput, +{Enter}
        Sleep, 200
        SendInput, +{Enter}
        Sleep, 200

        Clipboard := previousClip
        previousClip := ""
        Sleep, 200

        ; 채널에서 한 번 사용 후, 다음 전송에는 초기화
        gEpisodeTitle := ""
        gShareContent := ""
    }
}

    ; (2) 메시지 작성
    ; 채널이면 :열린_파일_폴더: 만, 사람이면 "파일 공유드립니다!"까지 추가
    if (InStr(userName, "사코팍-"))
    {
        Sleep, 300
        SendRaw, :열린_파일_폴더:
    }
    else
    {
        Sleep, 300
        SendRaw, :열린_파일_폴더: 파일 공유드립니다! :열린_파일_폴더:
    }
    Sleep, 100

    ; 줄바꿈 (Shift+Enter)
    SendInput, +{Enter}
    Sleep, 200

    ; 클립보드 백업
    previousClipboard := ClipboardAll
    Clipboard := ""

    ; 코드 블록 시작 (Ctrl+Shift+9)
    SendInput, ^+9
    Sleep, 100

    ; 2-1) 공통 경로 출력 (savedFileDir)
    Clipboard := savedFileDir
    Sleep, 100
    ClipWait, 1
    SendInput, ^v
    Sleep, 200

    ; 줄바꿈
    SendInput, +{Enter}
    Sleep, 200

    ; 2-2) 파일 이름들 출력
    ;      파일이 여러 개면 Loop를 돌면서 한 줄씩 표시
    Loop, %fileNameCount%
    {
        SendRaw, 파일 이름 :
        Sleep, 100

        SendInput, ^b
        Sleep, 100

        Clipboard := "*" . fileNameList%A_Index% . "*"
        Sleep, 100
        ClipWait, 1
        SendInput, ^v
        Sleep, 200

        SendInput, +{Enter}
        Sleep, 200
    }

    ; 코드 블록 종료 (Ctrl+Shift+9)
    SendInput, ^+9
    Sleep, 100

    ; 마크다운 적용 (Ctrl+Shift+F 두 번)
    SendInput, ^+{F}
    Sleep, 100
    SendInput, ^+{F}

    ; 클립보드 복원
    Clipboard := previousClipboard

    ; ===============================
    ; (새로 추가) @멘션 목록 출력
    ; ===============================
    global gMentionList
    if (gMentionList != "")
    {
        ; 줄바꿈 먼저
        SendInput, +{Enter}
        Sleep, 200
        ; 실제 멘션 목록 출력
        SendRaw, %gMentionList%
        Sleep, 200
        ; 다시 줄바꿈
        SendInput, +{Enter}
        Sleep, 200

        ; ★ 멘션 리스트 초기화 ★
        gMentionList := ""
    }

    ; (3) 파일 첨부 체크박스가 선택된 경우 → 복수 파일 첨부
    if (attachFile)
    {
        ; 바로 파일 첨부 로직으로 넘어감
        Loop, %filePathCount%
        {
            previousClipboard2 := ClipboardAll
            Clipboard := filePathList%A_Index%
            Sleep, 100
            ClipWait, 1

            ; 파일 첨부 버튼 (Ctrl+U)
            SendInput, ^u
            Sleep, 500

            ; 파일 첨부 대화상자 "열기"가 뜰 때까지 대기
            WinWaitActive, 열기, , 5
            if ErrorLevel
            {
                MsgBox, 파일 첨부 대화상자를 찾을 수 없습니다.
                return
            }

            ; 경로 붙여넣기
            SendInput, ^v
            Sleep, 500

            ; Enter 키 (파일 선택)
            SendInput, {Enter}
            Sleep, 1000  ; 업로드 대기 (파일 용량에 따라 조절 가능)

            ; 클립보드 복원
            Clipboard := previousClipboard2
        }
    }
}

; ============================================================================
; Slack 주 창(ahk_id가 가장 작은) 찾는 함수
; - Slack.exe 프로세스로 열린 창이 여러 개 있을 수 있으므로,
;   그중 창 ID가 가장 작은(가장 먼저 연) 창을 반환합니다.
; ============================================================================
GetMainSlackWindow() {
    WinGet, idList, List, ahk_exe slack.exe
    if (idList > 0)
    {
        minHwnd := idList1
        minId := minHwnd + 0
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

; ============================================================================
; 각 대상별 처리 함수(사람)
; - 사람 버튼 클릭 시: GUI 닫고 → SendMessageToUser("이름")
; - '이름' 자리에 다른 팀원을 추가하고 싶으면, 동일한 형식으로
;   MyoungHee:
;   Gui, Submit, NoHide
;   Gui, Destroy
;   SendMessageToUser("명희")
;   return
;   이런 식으로 작성하시면 됩니다.
; ============================================================================
AnRyoocheon:
    Gui, Submit, NoHide
    Gui, Destroy
    SendMessageToUser("안류천")
return

YoonSeongwon:
    Gui, Submit, NoHide
    Gui, Destroy
    SendMessageToUser("윤성원")
return

HeoHyewon:
    Gui, Submit, NoHide
    Gui, Destroy
    SendMessageToUser("허혜원")
return

JiJeongmin:
    Gui, Submit, NoHide
    Gui, Destroy
    SendMessageToUser("지정민")
return

WonDongwoo:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("원동우")
return

KangSunyoung:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("강선영")
return

ParkJeongin:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("박정인")
return

LeeMyeonghoon:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("이명훈")
return

LeeHyemin:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("이혜민")
return

BaeHansol:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("배한솔")
return

LeeDaeun:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("이다은")
return

JeonHyerim:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("전혜림")
return

JangJaeyoung:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("장재영")
return

KangJiyung:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("강지융")
return

KimEojin:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("김어진")
return

Ryu:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("류이레")
return

; ============================================================================
; 각 대상별 처리 함수(채널)
; - 채널에 전송 버튼 클릭 시: GUI 닫고 → ShowChannelGui("사코팍-오리지널") 등
; - 새 채널을 추가하려면, 비슷한 형식의 라벨을 만들고 ShowChannelGui("사코팍-XXXX")를 넣어주면 됩니다.
; ============================================================================
SakopakOriginal:
Gui, Submit, NoHide
Gui, Destroy
ShowChannelGui("사코팍-오리지널")
return

SakopakMembership:
Gui, Submit, NoHide
Gui, Destroy
ShowChannelGui("사코팍-일반-멤버십")
return

SakopakBackground:
Gui, Submit, NoHide
Gui, Destroy
ShowChannelGui("사코팍-background")
return

SakopakCharacter:
Gui, Submit, NoHide
Gui, Destroy
ShowChannelGui("사코팍-character")
return

SakopakIpInsta:
Gui, Submit, NoHide
Gui, Destroy
ShowChannelGui("사코팍-ip-insta")
return

; ============================================================================
; (기존) 메인 GUI 닫기 처리
; - '대상 선택' GUI에서 ESC나 X 버튼을 눌렀을 때
; ============================================================================
GuiClose:
GuiEscape:
    Gui, Destroy
return