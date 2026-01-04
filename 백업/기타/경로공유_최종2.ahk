; ============================================================================
; 성능 및 메모리 최적화 설정
; ============================================================================
ListLines, Off
#KeyHistory, 0
#Warn
#SingleInstance Force

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; ============================================================================
; 전역 변수 선언
; ============================================================================
global savedFilePath        ; 복수 파일 전체 경로(줄바꿈으로 구분)
global savedFileName        ; 첫 번째 파일명만
global savedFileDir         ; 선택 파일들의 공통 경로
global attachFile := false  ; 파일 첨부 여부(체크박스)
global filePathCount        ; 선택된 파일(경로) 개수
global fileNameCount        ; 선택된 파일(이름) 개수

; 채널 GUI에서 입력받을 전역 변수 (에피소드 제목/공유 내용)
global gEpisodeTitle := ""
global gShareContent := ""
; 어떤 채널이 클릭되었는지 임시로 저장할 변수
global gChannelName := ""

; 전통적인 AHK pseudo-array:
;   filePathList1, filePathList2, ...
;   fileNameList1, fileNameList2, ...

; ============================================================================
; Alt+F12 핫키
; ============================================================================
!F12::
{
    ; 1) 한글 입력 모드일 경우 영어로 전환
    SetEnglishInputMode()

    ; 2) 현재 선택된 파일(단/복수)에 대해, F2 → Ctrl+A → Ctrl+C → Esc 로 "첫 번째 파일 이름" 얻기
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

    ; 3) 선택된 파일들의 전체 경로를 Ctrl+C 로 복사 (여러 파일이면 줄바꿈으로 구분)
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

    ; 4) pseudo-array 초기화
    filePathCount := 0
    fileNameCount := 0

    ; 5) savedFilePath를 줄바꿈(`r`n) 기준으로 파싱 → filePathList1, filePathList2... 에 저장
    Loop, Parse, savedFilePath, `r`n
    {
        if (A_LoopField = "")
            continue  ; 빈 줄은 무시

        filePathCount++
        filePathList%filePathCount% := A_LoopField
    }

    ; 첫 번째 파일 경로 기준으로 공통 디렉터리 추출
    if (filePathCount >= 1)
    {
        SplitPath, filePathList1, outName, outDir
        savedFileDir := outDir
    }

    ; 6) 각 파일의 이름만 추출 → fileNameList1, fileNameList2...
    Loop, %filePathCount%
    {
        SplitPath, filePathList%A_Index%, onlyName, onlyDir
        fileNameCount++
        fileNameList%fileNameCount% := onlyName
    }

    ; 7) 사용자 선택 GUI (사람/채널) 표시
    Gui, +AlwaysOnTop
    Gui, Add, Text, x10 y10 w200 h20, 전송할 대상을 선택하세요:

    ; 사람에게 공유
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
    Gui, Add, Button, x130 y230 w110 h30 gJoYeorae,     조여래
    Gui, Add, Button, x10  y270 w110 h30 gBaeHansol,    배한솔
    Gui, Add, Button, x130 y270 w110 h30 gLeeDaeun,     이다은
    Gui, Add, Button, x10  y310 w110 h30 gKimSooyeon,   김수연
    Gui, Add, Button, x130 y310 w110 h30 gJeonHyerim,   전혜림
    Gui, Add, Button, x10  y350 w110 h30 gJangJaeyoung, 장재영
    Gui, Add, Button, x130 y350 w110 h30 gKangJiyung,   강지융

    ; 채널에 전송
    Gui, Add, Text, x10 y390 w200 h20, 채널에 전송:
    Gui, Add, Button, x10  y420 w230 h30 gSakopakOriginal,   사코팍-오리지널
    Gui, Add, Button, x10  y460 w230 h30 gSakopakMembership, 사코팍-일반-멤버십
    Gui, Add, Button, x10  y500 w230 h30 gSakopakBackground, 사코팍-background
    Gui, Add, Button, x10  y540 w230 h30 gSakopakCharacter,  사코팍-character
    Gui, Add, Button, x10  y580 w230 h30 gSakopakIpInsta,    사코팍-ip-insta

    ; 파일 첨부 체크박스
    Gui, Add, Checkbox, x10 y620 vattachFile Checked, 파일 같이 첨부하기
    Gui, Show, w250 h660, 대상 선택

    return
}

; ============================================================================
; 한글 입력 모드일 경우 영어로 전환하는 함수
; ============================================================================
SetEnglishInputMode() {
    InputLocale := DllCall("GetKeyboardLayout", "UInt"
                  , DllCall("GetWindowThreadProcessId", "UInt", WinActive("A"), "UInt", 0))
    if (InputLocale == 0x4120412)  ; 한글(0x0412)
    {
        Send, {VK15}  ; 한/영 키
        Sleep, 100
    }
}

; ============================================================================
; -- (1) 채널 GUI 표시 함수 --
;     "에피소드 제목 / 공유 내용" 입력과,
;     "팀원 이름" 체크박스(복수 선택) GUI가 함께 뜸.
; ============================================================================
ShowChannelGui(channelName)
{
    global gChannelName
    global gEpisodeTitle
    global gShareContent
    global gMentionList  ; 최종 @멘션 목록을 담을 전역변수

    ; 어떤 채널인지 기억
    gChannelName := channelName

    ; 미리 전역변수 비우기
    gEpisodeTitle := ""
    gShareContent := ""
    gMentionList := ""

    ; GUI 2번 사용 예시
    Gui, 2:Destroy
    Gui, 2:+AlwaysOnTop
    Gui, 2:Default
    ; ┌────────────────────────────────────────────────────────────────────────────┐
    ; │ [Font 설정]                                                                │
    ; │   - Gui, Font, [옵션], [폰트이름]                                           │
    ; │   - 주요 옵션 예시:                                                         │
    ; │       S10    : 글씨 크기를 10pt 로 설정                                     │
    ; │       cRed   : 글씨 색상을 빨간색 (Hex 색상도 가능)                          │
    ; │       Italic : 글씨 이탤릭체 적용                                           │
    ; │       Bold   : 글씨를 굵게                                                  │
    ; │     예)  Gui, Font, S10 cBlue Italic, Verdana                              │
    ; │          -> 글씨 크기 10pt, 파란색, 이탤릭체, 폰트는 Verdana                  │
    ; │                                                                            │
    ; │ 참고로, “Gui, Font” 명령어는 이후에 추가되는 GUI 컨트롤(텍스트, 버튼 등)에     │
    ; │ 해당 폰트 스타일을 적용합니다.                                               │
    ; └────────────────────────────────────────────────────────────────────────────┘
    ; ----------------------------
    ; (A) 에피소드 제목 / 공유 내용
    ; ----------------------------
    Gui, Font, S13 Bold, Verdana
    Gui, 2:Add, Text, x90  y9  w140 h20 +Center, 공유 항목을 입력해주세요.
    Gui, Font, S10 CDefault norm, Verdana
    Gui, 2:Add, Text, x12  y29 w160 h20 , 에피소드 제목
    Gui, 2:Add, Edit, x12  y49 w160 h30 vepisodeTitle
    Gui, 2:Add, Text, x192 y29 w160 h20 , 공유 내용
    Gui, 2:Add, Edit, x192 y49 w160 h30 vshareContent

    Gui, 2:Add, Edit, x12  y89 w160 h30 ReadOnly, 예시) 지웅이게임(오리지널)
    Gui, 2:Add, Edit, x192 y89 w160 h30 ReadOnly, 예시) 배경 컨셉아트 공유

    ; ----------------------------
    ; (B) 팀원 이름 체크박스 (복수 선택)
    ; - 예시로 몇 명만 추가
    ; - 필요한 만큼 계속 추가해도 됨
    ; ----------------------------
    Gui, 2:Add, Text, x12  y149 w340 h20 , 함께 멘션할 팀원 선택:
    Gui, 2:Add, Checkbox, x20  y179 vcbAnRyoocheon,  안류천
    Gui, 2:Add, Checkbox, x20  y209 vcbYoonSeongwon, 윤성원
    Gui, 2:Add, Checkbox, x20  y239 vcbHeoHyewon,    허혜원
    Gui, 2:Add, Checkbox, x20  y269 vcbJiJeongmin,   지정민
    Gui, 2:Add, Checkbox, x20 y299 vcbWonDongwoo,   원동우
    Gui, 2:Add, Checkbox, x100 y179 vcbKangSunyoung, 강선영
    Gui, 2:Add, Checkbox, x100 y209 vcbParkJeongin,  박정인
    Gui, 2:Add, Checkbox, x100 y239 vcbLeeMyeonghoon,이명훈
    Gui, 2:Add, Checkbox, x100 y269 vcbLeeHyemin, 이혜민
    Gui, 2:Add, Checkbox, x100 y299 vcbJoYeorae, 조여래
    Gui, 2:Add, Checkbox, x180 y179 vcbBaeHansol, 배한솔
    Gui, 2:Add, Checkbox, x180 y209 vcbLeeDaeun, 이다은
    Gui, 2:Add, Checkbox, x180 y239 vcbKimSooyeon, 김수연
    Gui, 2:Add, Checkbox, x180 y269 vcbJeonHyerim, 전혜림
    Gui, 2:Add, Checkbox, x260 y209 vcbJangJaeyoung, 장재영
    Gui, 2:Add, Checkbox, x260 y239 vcbKangJiyung, 강지융
    
    Gui, Font, S13 Cred Bold, Verdana
    Gui, 2:Add, Checkbox, x260 y179 vcbJBJ, 장삐쭈
    ; ... 필요한 만큼 계속 ...

    ; ----------------------------
    ; (C) 확인 버튼
    ; ----------------------------
    Gui, 2:Add, Button, x280 y310 w80 h30 gChannelOk, 확인

    ; GUI 표시
    Gui, 2:Show, x818 y623 w380 h355, 채널 공유 GUI

    return
}

; GUI 닫기 처리(2번 GUI)
2GuiClose:
GuiEscape2:
    ; 2번 GUI만 닫음
    Gui, 2:Destroy
return

; ============================================================================
; (2) 채널 GUI에서 '확인' 버튼 눌렀을 때
;     => 에피소드 제목/공유 내용 전역 변수에 저장
;     => 채널로 메시지 전송 함수 호출
; ============================================================================
ChannelOk:
Gui, 2:Submit, NoHide
{
    global gEpisodeTitle, gShareContent
    global gChannelName
    global gMentionList

    ; (A) Edit 컨트롤로부터 입력받은 값 보관
    gEpisodeTitle := episodeTitle
    gShareContent := shareContent

    ; (B) 체크박스로부터 선택된 사람들 추려내기
    ;     체크된 항목에 대해서만 "@이름" 식으로 덧붙임
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
    if (cbJoYeorae = "1")
        gMentionList .= " @조여래"
    if (cbBaeHansol = "1")
        gMentionList .= " @배한솔"
    if (cbLeeDaeun = "1")
        gMentionList .= " @이다은"
    if (cbKimSooyeon = "1")
        gMentionList .= " @김수연"
    if (cbJangJaeyoung = "1")
        gMentionList .= " @장재영"
    if (cbKangJiyung = "1")
        gMentionList .= " @강지융"
    if (cbJeonHyerim = "1")
        gMentionList .= " @전혜림"

    ; ... 필요한 만큼 계속 ...

    ; GUI 닫기
    Gui, 2:Destroy

    ; 실제 전송
    SendMessageToUser(gChannelName)
}
return


; ============================================================================
; 메세지를 사용자(또는 채널)에 전송하는 함수
; ============================================================================
SendMessageToUser(userName) {
    global attachFile
    global savedFileDir
    global filePathCount
    global fileNameCount

    ; 채널용 추가 전역변수
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

    ; 한글 입력 모드일 경우 영어로 전환
    SetEnglishInputMode()
    Sleep, 100

    ; (1) 새 DM(또는 채널) 시작 (Ctrl+Shift+K)
    SendInput, ^+k
    Sleep, 500

    ; --- 새로운 코드 시작 ---
    ; 강제로 영어 입력 모드로 전환
    SetEnglishInputMode()
    Sleep, 100

    ; 클립보드 백업
    prevClip := ClipboardAll

    ; 채널(또는 사용자) 이름을 클립보드에 담음
    Clipboard := userName
    Sleep, 100
    ClipWait, 1

    ; 붙여넣기
    SendInput, ^v
    Sleep, 300

    ; Slack에서 채널/사용자 선택
    SendInput, {Enter}
    Sleep, 500
    SendInput, {Tab}
    Sleep, 200

    ; 클립보드 복원
    Clipboard := prevClip
    prevClip := ""
    ; --- 새로운 코드 종료 ---

; -------------------------------------------------
; (1-A) 채널일 때만 + 입력값이 있을 때만
;       [ 에피소드 / 공유내용 ] 형식으로 추가
; -------------------------------------------------
; -------------------------------------------------
; (1-A) 채널일 때만 + 입력값이 있을 때만
;       [ 에피소드 / 공유내용 ] 형식으로 추가
; -------------------------------------------------
if (InStr(userName, "사코팍-"))  ; "사코팍-"이 들어있으면 '채널'로 간주
{
    if (gEpisodeTitle != "" or gShareContent != "")
    {
        ; -- 클립보드 백업 --
        previousClip := ClipboardAll
        
        ; -- [ 에피소드제목 / 공유내용 ] 형식으로 한 덩어리 만들기 --
        fullText := "*[ " . gEpisodeTitle . " / " . gShareContent . " ]*"
        
        ; -- 클립보드에 넣고 붙여넣기 --
        Clipboard := fullText
        Sleep, 100
        ClipWait, 1
        SendInput, ^v
        Sleep, 200
    
        ; -- 줄바꿈 2번 --
        SendInput, +{Enter}
        Sleep, 200
        SendInput, +{Enter}
        Sleep, 200

        ; -- 클립보드 복원 --
        Clipboard := previousClip
        previousClip := ""
        Sleep, 200

        ; 채널에서 한 번 사용 후, 다음 전송에는 초기화
        gEpisodeTitle := ""
        gShareContent := ""
    }
}

    ; (2) 메시지 작성
    ; userName에 "사코팍-" 이 들어있으면 => 채널로 간주
    ; 아니면 => 개인 DM(사람)
    if (InStr(userName, "사코팍-"))
    {
        ; 채널인 경우
        SendRaw, :열린_파일_폴더:
    }
    else
    {
        ; 사람에게 전송하는 경우
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

    ; 2-1) 공통 경로 출력
    Clipboard := savedFileDir
    Sleep, 100
    ClipWait, 1
    SendInput, ^v
    Sleep, 200

    ; 줄바꿈
    SendInput, +{Enter}
    Sleep, 200

    ; 2-2) 파일 이름들 출력
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
    ; ===============================

    ; (3) 파일 첨부 체크박스가 선택된 경우 → 복수 파일 첨부
    if (attachFile)
    {
        MsgBox, 4,, 파일도 함께 첨부하시겠습니까?
        IfMsgBox, No
            return

        IfMsgBox, Yes
        {
            ; 여러 파일 첨부
            Loop, %filePathCount%
            {
                previousClipboard2 := ClipboardAll
                Clipboard := filePathList%A_Index%
                Sleep, 100
                ClipWait, 1

                ; 파일 첨부 버튼 (Ctrl+U)
                SendInput, ^u
                Sleep, 500

                ; 파일 첨부 대화상자 대기
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
                Sleep, 1000  ; 업로드 대기

                ; 클립보드 복원
                Clipboard := previousClipboard2
            }
        }
    }
}

; ============================================================================
; Slack 주 창(ahk_id가 가장 작은) 찾는 함수
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
; - 사람에게 전송 버튼 클릭 시: 기존 방식 그대로 SendMessageToUser()
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

JoYeorae:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("조여래")
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

KimSooyeon:
Gui, Submit, NoHide
Gui, Destroy
SendMessageToUser("김수연")
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

; ============================================================================
; 각 대상별 처리 함수(채널)
; - 채널에 전송 버튼 클릭 시: 우선 Channel GUI를 띄움
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
; (기존) GUI 닫기 처리 (메인 GUI)
; ============================================================================
GuiClose:
GuiEscape:
    Gui, Destroy
return
