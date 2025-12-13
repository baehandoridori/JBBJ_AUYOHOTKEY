; ============================================================================
; 성능 및 메모리 최적화 설정
; ============================================================================
ListLines 0           ; 스크립트 실행 시, 상세한 실행 로그(ListLines)를 끔
;KeyHistory 0         ; 키보드 히스토리를 보이지 않도록 설정
#Warn                 ; 경고를 표시(변수 충돌 등) - 디버깅용
#SingleInstance Force ; 이미 스크립트가 실행 중이면, 새로 실행 시 이전 스크립트를 종료
; #NoEnv 지시문은 v2에서 제거됨 (오류의 원인이었음)
SendMode "Input"      ; Send 입력 모드를 "Input"으로 설정
SetWorkingDir A_ScriptDir  ; 스크립트가 있는 폴더를 작업 디렉토리로 설정

; ============================================================================
; 전역 변수 선언
; - 여기 있는 변수들은 스크립트 전체에서 사용 가능한 전역 변수들입니다.
; - 파일 경로/이름, 체크박스 상태, 멘션 목록, 채널 등등
; ============================================================================
global savedFilePath := ""    ; 복수 파일 전체 경로(줄바꿈으로 구분)
global savedFileName := ""    ; 첫 번째 파일명만 (F2로 복사 시 읽힌 것)
global savedFileDir := ""     ; 선택 파일들의 공통 디렉터리 경로
global attachFile := false    ; "파일 같이 첨부하기" 체크박스 상태(true/false)
global filePathCount := 0     ; 선택된 파일(경로)의 개수
global fileNameCount := 0     ; 선택된 파일(이름)의 개수

; 채널 GUI에서 입력받을 전역 변수들 (에피소드 제목, 공유 내용)
global gEpisodeTitle := ""
global gShareContent := ""
; 사용자가 클릭한 채널 이름을 임시 저장
global gChannelName := ""
; @멘션할 팀원들 목록을 저장해둘 전역 변수
global gMentionList := ""

; 전역 파일 저장을 위한 배열
global filePathList := []
global fileNameList := []

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
    Send "{F2}"
    Sleep 100
    Send "^a"
    Sleep 100
    Send "^c"
    Sleep 100
    Send "{Esc}"
    if !ClipWait(2)
    {
        MsgBox "파일 이름을 가져오지 못했습니다."
        return
    }
    global savedFileName
    savedFileName := A_Clipboard  ; global 키워드를 별도 라인으로 분리
    A_Clipboard := ""

    ; 3) 이어서, 전체 파일 경로(여러 개일 수 있음)를 복사.
    ;    여러 파일을 선택하면, 줄바꿈(`r`n)으로 구분되어 복사됩니다.
    Send "^c"
    Sleep 100
    if !ClipWait(2)
    {
        MsgBox "파일 경로를 가져오지 못했습니다."
        return
    }
    global savedFilePath
    savedFilePath := A_Clipboard  ; global 키워드를 별도 라인으로 분리
    A_Clipboard := ""

    ; 4) 배열 초기화 (파일 경로/이름 개수를 0으로 초기화)
    global filePathCount
    filePathCount := 0
    global fileNameCount
    fileNameCount := 0
    global filePathList
    filePathList := []
    global fileNameList
    fileNameList := []

    ; 5) 줄바꿈(`r`n)을 기준으로 파일 경로를 한 줄씩 꺼내서
    ;    filePathList 배열에 저장
    Loop Parse, savedFilePath, "`r`n"
    {
        if (A_LoopField = "")
            continue  ; 공백 줄이면 무시

        global filePathCount
        filePathCount++
        global filePathList
        filePathList.Push(A_LoopField)
    }

    ; 첫 번째 파일 경로로부터, "공통 디렉토리"를 추출
    if (filePathCount >= 1)
    {
        SplitPath filePathList[1], &outName, &outDir
        global savedFileDir
        savedFileDir := outDir
    }

    ; 6) 각 파일 경로에서 파일 이름만 추출해서 fileNameList 배열에 저장
    ;    (예: C:\Work\Doc.txt → Doc.txt)
    Loop filePathCount
    {
        SplitPath filePathList[A_Index], &onlyName
        global fileNameCount
        fileNameCount++
        global fileNameList
        fileNameList.Push(onlyName)
    }

    ; 7) "대상 선택" GUI를 화면에 표시
    mainGui := Gui("+AlwaysOnTop", "대상 선택")
    mainGui.Add("Text", "x10 y10 w200 h20", "전송할 대상을 선택하세요:")

    ; (사람에게 공유) 부분
    mainGui.Add("Text", "x10 y40 w200 h20", "사람에게 공유:")
    mainGui.Add("Button", "x10  y70  w110 h30", "안류천").OnEvent("Click", PersonClicked.Bind("안류천"))
    mainGui.Add("Button", "x130 y70  w110 h30", "윤성원").OnEvent("Click", PersonClicked.Bind("윤성원"))
    mainGui.Add("Button", "x10  y110 w110 h30", "허혜원").OnEvent("Click", PersonClicked.Bind("허혜원"))
    mainGui.Add("Button", "x130 y110 w110 h30", "지정민").OnEvent("Click", PersonClicked.Bind("지정민"))
    mainGui.Add("Button", "x10  y150 w110 h30", "원동우").OnEvent("Click", PersonClicked.Bind("원동우"))
    mainGui.Add("Button", "x130 y150 w110 h30", "강선영").OnEvent("Click", PersonClicked.Bind("강선영"))
    mainGui.Add("Button", "x10  y190 w110 h30", "박정인").OnEvent("Click", PersonClicked.Bind("박정인"))
    mainGui.Add("Button", "x130 y190 w110 h30", "이명훈").OnEvent("Click", PersonClicked.Bind("이명훈"))
    mainGui.Add("Button", "x10  y230 w110 h30", "이혜민").OnEvent("Click", PersonClicked.Bind("이혜민"))
    mainGui.Add("Button", "x130 y230 w110 h30", "조여래").OnEvent("Click", PersonClicked.Bind("조여래"))
    mainGui.Add("Button", "x10  y270 w110 h30", "배한솔").OnEvent("Click", PersonClicked.Bind("배한솔"))
    mainGui.Add("Button", "x130 y270 w110 h30", "이다은").OnEvent("Click", PersonClicked.Bind("이다은"))
    mainGui.Add("Button", "x10  y310 w110 h30", "김수연").OnEvent("Click", PersonClicked.Bind("김수연"))
    mainGui.Add("Button", "x130 y310 w110 h30", "전혜림").OnEvent("Click", PersonClicked.Bind("전혜림"))
    mainGui.Add("Button", "x10  y350 w110 h30", "장재영").OnEvent("Click", PersonClicked.Bind("장재영"))
    mainGui.Add("Button", "x130 y350 w110 h30", "강지융").OnEvent("Click", PersonClicked.Bind("강지융"))

    ; (채널에 전송) 부분
    mainGui.Add("Text", "x10 y390 w200 h20", "채널에 전송:")
    mainGui.Add("Button", "x10  y420 w230 h30", "사코팍-오리지널").OnEvent("Click", ChannelClicked.Bind("사코팍-오리지널"))
    mainGui.Add("Button", "x10  y460 w230 h30", "사코팍-일반-멤버십").OnEvent("Click", ChannelClicked.Bind("사코팍-일반-멤버십"))
    mainGui.Add("Button", "x10  y500 w230 h30", "사코팍-background").OnEvent("Click", ChannelClicked.Bind("사코팍-background"))
    mainGui.Add("Button", "x10  y540 w230 h30", "사코팍-character").OnEvent("Click", ChannelClicked.Bind("사코팍-character"))
    mainGui.Add("Button", "x10  y580 w230 h30", "사코팍-ip-insta").OnEvent("Click", ChannelClicked.Bind("사코팍-ip-insta"))

    ; "파일 같이 첨부하기" 체크박스 (기본 체크 상태)
    attachFileCheckbox := mainGui.Add("Checkbox", "x10 y620 vattachFile Checked", "파일 같이 첨부하기")
    
    ; GUI 이벤트 핸들러 설정
    mainGui.OnEvent("Close", GuiCloseHandler)
    mainGui.OnEvent("Escape", GuiEscapeHandler)
    
    ; GUI 표시
    mainGui.Show("w250 h660")
}

; ============================================================================
; 한글 입력 모드일 경우, 영어로 전환하는 함수
; - 슬랙에서 채널명이나 영문 키워드가 깨지지 않도록 대비
; ============================================================================
SetEnglishInputMode() {
    InputLocale := DllCall("GetKeyboardLayout", "UInt", 
                 DllCall("GetWindowThreadProcessId", "UInt", WinExist("A"), "UInt*", 0))
    if (InputLocale == 0x4120412)  ; 한글(0x0412)이면
    {
        Send "{VK15}"  ; 한/영 키 전환
        Sleep 100
    }
}

; ============================================================================
; -- (1) 채널 GUI 표시 함수 --
;     "에피소드 제목 / 공유 내용"을 입력하고
;     멘션할 팀원들을 체크박스로 선택할 수 있는 GUI를 띄웁니다.
; ============================================================================
ShowChannelGui(channelName) {
    global gChannelName, gEpisodeTitle, gShareContent, gMentionList
    static channelGui, episodeTitleEdit, shareContentEdit, okButton
    static cbAnRyoocheon, cbYoonSeongwon, cbHeoHyewon, cbJiJeongmin, cbWonDongwoo, cbKangSunyoung
    static cbParkJeongin, cbLeeMyeonghoon, cbLeeHyemin, cbJoYeorae, cbBaeHansol, cbLeeDaeun
    static cbKimSooyeon, cbJeonHyerim, cbJangJaeyoung, cbKangJiyung, cbJBJ

    ; 어떤 채널인지 기억
    gChannelName := channelName

    ; 필요한 전역 변수들 초기화
    gEpisodeTitle := ""
    gShareContent := ""
    gMentionList := ""

    ; 채널 전송 GUI 생성
    channelGui := Gui("+AlwaysOnTop", "채널 공유 GUI")

    ; (A) 에피소드 제목 / 공유 내용
    channelGui.SetFont("S13 Bold", "Verdana")
    channelGui.Add("Text", "x90 y9 w140 h20 +Center", "공유 항목을 입력해주세요.")
    channelGui.SetFont("S10 CDefault norm", "Verdana")
    channelGui.Add("Text", "x12 y29 w160 h20", "에피소드 제목")
    episodeTitleEdit := channelGui.Add("Edit", "x12 y49 w160 h30")
    channelGui.Add("Text", "x192 y29 w160 h20", "공유 내용")
    shareContentEdit := channelGui.Add("Edit", "x192 y49 w160 h30")

    ; 읽기전용 Edit (예시로 어떤 값이 들어가는지 안내)
    channelGui.Add("Edit", "x12 y89 w160 h30 ReadOnly", "예시) 지웅이게임(오리지널)")
    channelGui.Add("Edit", "x192 y89 w160 h30 ReadOnly", "예시) 배경 컨셉아트 공유")

    ; (B) 팀원 이름 체크박스 (복수 선택 가능)
    channelGui.Add("Text", "x12 y149 w340 h20", "함께 멘션할 팀원 선택:")
    
    ; 체크박스 추가
    cbAnRyoocheon := channelGui.Add("Checkbox", "x20 y179", "안류천")
    cbYoonSeongwon := channelGui.Add("Checkbox", "x20 y209", "윤성원")
    cbHeoHyewon := channelGui.Add("Checkbox", "x20 y239", "허혜원")
    cbJiJeongmin := channelGui.Add("Checkbox", "x20 y269", "지정민")
    cbWonDongwoo := channelGui.Add("Checkbox", "x20 y299", "원동우")
    cbKangSunyoung := channelGui.Add("Checkbox", "x100 y179", "강선영")
    cbParkJeongin := channelGui.Add("Checkbox", "x100 y209", "박정인")
    cbLeeMyeonghoon := channelGui.Add("Checkbox", "x100 y239", "이명훈")
    cbLeeHyemin := channelGui.Add("Checkbox", "x100 y269", "이혜민")
    cbJoYeorae := channelGui.Add("Checkbox", "x100 y299", "조여래")
    cbBaeHansol := channelGui.Add("Checkbox", "x180 y179", "배한솔")
    cbLeeDaeun := channelGui.Add("Checkbox", "x180 y209", "이다은")
    cbKimSooyeon := channelGui.Add("Checkbox", "x180 y239", "김수연")
    cbJeonHyerim := channelGui.Add("Checkbox", "x180 y269", "전혜림")
    cbJangJaeyoung := channelGui.Add("Checkbox", "x260 y209", "장재영")
    cbKangJiyung := channelGui.Add("Checkbox", "x260 y239", "강지융")
    
    ; 굵은 빨간 텍스트로 강조된 팀원(예시)
    channelGui.SetFont("S13 Cred Bold", "Verdana")
    cbJBJ := channelGui.Add("Checkbox", "x260 y179", "장삐쭈")

    ; (C) 확인 버튼
    okButton := channelGui.Add("Button", "x280 y310 w80 h30", "확인")
    okButton.OnEvent("Click", ChannelOk)

    ; GUI 이벤트 핸들러 설정
    channelGui.OnEvent("Close", ChannelGuiCloseHandler)
    channelGui.OnEvent("Escape", ChannelGuiCloseHandler)

    ; GUI 표시
    channelGui.Show("x818 y623 w380 h355")

    ; 콜백 함수 정의
    ChannelOk(*) {
        ; (A) Edit 컨트롤로부터 입력받은 텍스트 보관
        gEpisodeTitle := episodeTitleEdit.Value
        gShareContent := shareContentEdit.Value

        ; (B) 체크박스로부터 선택된 사람들 추려내기
        ;     체크된 항목(값이 true)에 대해서만 "@이름" 형태로 연결
        gMentionList := ""
        if (cbJBJ.Value)
            gMentionList .= " @장삐쭈"
        if (cbAnRyoocheon.Value)
            gMentionList .= " @안류천"
        if (cbYoonSeongwon.Value)
            gMentionList .= " @윤성원"
        if (cbHeoHyewon.Value)
            gMentionList .= " @허혜원"
        if (cbJiJeongmin.Value)
            gMentionList .= " @지정민"
        if (cbWonDongwoo.Value)
            gMentionList .= " @원동우"
        if (cbKangSunyoung.Value)
            gMentionList .= " @강선영"
        if (cbParkJeongin.Value)
            gMentionList .= " @박정인"
        if (cbLeeMyeonghoon.Value)
            gMentionList .= " @이명훈"
        if (cbLeeHyemin.Value)
            gMentionList .= " @이혜민"
        if (cbJoYeorae.Value)
            gMentionList .= " @조여래"
        if (cbBaeHansol.Value)
            gMentionList .= " @배한솔"
        if (cbLeeDaeun.Value)
            gMentionList .= " @이다은"
        if (cbKimSooyeon.Value)
            gMentionList .= " @김수연"
        if (cbJangJaeyoung.Value)
            gMentionList .= " @장재영"
        if (cbKangJiyung.Value)
            gMentionList .= " @강지융"
        if (cbJeonHyerim.Value)
            gMentionList .= " @전혜림"

        ; GUI 닫고, 실제 전송 함수 호출
        channelGui.Destroy()
        SendMessageToUser(gChannelName)
    }

    ChannelGuiCloseHandler(*) {
        channelGui.Destroy()
    }
}

; ============================================================================
; 메세지를 사용자(또는 채널)에 전송하는 함수
; - 최종적으로 Slack 창을 찾아서 파일 정보 / 채널 정보 / 멘션 / 파일 첨부 등을 합니다.
; ============================================================================
SendMessageToUser(userName) {
    global attachFile, savedFileDir, filePathCount, fileNameCount
    global filePathList, fileNameList
    global gEpisodeTitle, gShareContent, gMentionList

    ; Slack 주 창 찾기
    slackHwnd := GetMainSlackWindow()
    if (!slackHwnd)
    {
        MsgBox "Slack 주 창을 찾을 수 없습니다."
        return
    }

    ; Slack 창 활성화
    WinActivate "ahk_id " slackHwnd
    if !WinWaitActive("ahk_id " slackHwnd,, 5)
    {
        MsgBox "Slack 창을 활성화할 수 없습니다."
        return
    }
    Sleep 500

    ; 혹시 한글 입력이면 영어로 전환
    SetEnglishInputMode()
    Sleep 100

    ; (1) 새 DM(또는 채널) 시작 (Ctrl+Shift+K)
    Send "^+k"
    Sleep 500

    ; --- 영어 입력 모드 강제 전환 및 채널/사용자 이름 붙여넣기 ---
    SetEnglishInputMode()
    Sleep 100

    prevClip := ClipboardAll()
    A_Clipboard := userName
    Sleep 100
    ClipWait 1

    Send "^v"
    Sleep 300
    Send "{Enter}"
    Sleep 500

    A_Clipboard := prevClip
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
            previousClip := ClipboardAll()

            fullText := "*[ " . gEpisodeTitle . " / " . gShareContent . " ]*"
            A_Clipboard := fullText
            Sleep 100
            ClipWait 1
            Send "^v"
            Sleep 200

            ; 줄바꿈 2번
            Send "+{Enter}"
            Sleep 200
            Send "+{Enter}"
            Sleep 200

            A_Clipboard := previousClip
            previousClip := ""
            Sleep 200

            ; 채널에서 한 번 사용 후, 다음 전송에는 초기화
            gEpisodeTitle := ""
            gShareContent := ""
        }
    }

    ; (2) 메시지 작성
    ; 채널이면 :열린_파일_폴더: 만, 사람이면 "파일 공유드립니다!"까지 추가
    if (InStr(userName, "사코팍-"))
    {
        Sleep 300
        SendInput ":열린_파일_폴더:"
    }
    else
    {
        Sleep 300
        SendInput ":열린_파일_폴더: 파일 공유드립니다! :열린_파일_폴더:"
    }
    Sleep 100

    ; 줄바꿈 (Shift+Enter)
    Send "+{Enter}"
    Sleep 200

    ; 클립보드 백업
    previousClipboard := ClipboardAll()
    A_Clipboard := ""

    ; 코드 블록 시작 (Ctrl+Shift+9)
    Send "^+9"
    Sleep 100

    ; 2-1) 공통 경로 출력 (savedFileDir)
    A_Clipboard := savedFileDir
    Sleep 100
    ClipWait 1
    Send "^v"
    Sleep 200

    ; 줄바꿈
    Send "+{Enter}"
    Sleep 200

    ; 2-2) 파일 이름들 출력
    ;      파일이 여러 개면 Loop를 돌면서 한 줄씩 표시
    Loop fileNameCount
    {
        SendInput "파일 이름 :"
        Sleep 100

        Send "^b"
        Sleep 100

        A_Clipboard := "*" . fileNameList[A_Index] . "*"
        Sleep 100
        ClipWait 1
        Send "^v"
        Sleep 200

        Send "+{Enter}"
        Sleep 200
    }

    ; 코드 블록 종료 (Ctrl+Shift+9)
    Send "^+9"
    Sleep 100

    ; 마크다운 적용 (Ctrl+Shift+F 두 번)
    Send "^+{F}"
    Sleep 100
    Send "^+{F}"

    ; 클립보드 복원
    A_Clipboard := previousClipboard

    ; ===============================
    ; (새로 추가) @멘션 목록 출력
    ; ===============================
    if (gMentionList != "")
    {
        ; 줄바꿈 먼저
        Send "+{Enter}"
        Sleep 200
        ; 실제 멘션 목록 출력
        SendInput gMentionList
        Sleep 200
        ; 다시 줄바꿈
        Send "+{Enter}"
        Sleep 200

        ; ★ 멘션 리스트 초기화 ★
        gMentionList := ""
    }

    ; (3) 파일 첨부 체크박스가 선택된 경우 → 복수 파일 첨부
    if (attachFile)
    {
        ; 바로 파일 첨부 로직으로 넘어감
        Loop filePathCount
        {
            previousClipboard2 := ClipboardAll()
            A_Clipboard := filePathList[A_Index]
            Sleep 100
            ClipWait 1

            ; 파일 첨부 버튼 (Ctrl+U)
            Send "^u"
            Sleep 500

            ; 파일 첨부 대화상자 "열기"가 뜰 때까지 대기
            if !WinWaitActive("열기",, 5)
            {
                MsgBox "파일 첨부 대화상자를 찾을 수 없습니다."
                return
            }

            ; 경로 붙여넣기
            Send "^v"
            Sleep 500

            ; Enter 키 (파일 선택)
            Send "{Enter}"
            Sleep 1000  ; 업로드 대기 (파일 용량에 따라 조절 가능)

            ; 클립보드 복원
            A_Clipboard := previousClipboard2
        }
    }
}

; ============================================================================
; Slack 주 창(ahk_id가 가장 작은) 찾는 함수
; - Slack.exe 프로세스로 열린 창이 여러 개 있을 수 있으므로,
;   그중 창 ID가 가장 작은(가장 먼저 연) 창을 반환합니다.
; ============================================================================
GetMainSlackWindow() {
    idList := WinGetList("ahk_exe slack.exe")
    if (idList.Length > 0)
    {
        minHwnd := idList[1]
        minId := minHwnd + 0
        
        for hwnd in idList
        {
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
; GUI 닫기 처리 함수들
; ============================================================================
GuiCloseHandler(thisGui, *) {
    thisGui.Destroy()
}

GuiEscapeHandler(thisGui, *) {
    thisGui.Destroy()
}

ChannelGuiCloseHandler(thisGui, *) {
    thisGui.Destroy()
}

; ============================================================================
; 함수 공통화 - 사람 버튼과 채널 버튼 클릭 처리
; ============================================================================
PersonClicked(personName, ctrl, *) {
    global attachFile
    
    ; 현재 GUI 객체 가져오기
    currentGui := ctrl.Gui
    
    ; 체크박스 값 가져오기
    attachFile := currentGui["attachFile"].Value
    
    ; GUI 닫기
    currentGui.Destroy()
    
    ; 선택한 사람에게 메시지 전송
    SendMessageToUser(personName)
}

ChannelClicked(channelName, ctrl, *) {
    global attachFile
    
    ; 현재 GUI 객체 가져오기
    currentGui := ctrl.Gui
    
    ; 체크박스 값 가져오기
    attachFile := currentGui["attachFile"].Value
    
    ; GUI 닫기
    currentGui.Destroy()
    
    ; 선택한 채널 GUI 표시
    ShowChannelGui(channelName)
}

; ============================================================================
; GUI 닫기 처리 함수들
; ============================================================================
GuiClose(thisGui, *) {
    thisGui.Destroy()
}

GuiEscape(thisGui, *) {
    thisGui.Destroy()
}

ChannelGuiClose(thisGui, *) {
    thisGui.Destroy()
}