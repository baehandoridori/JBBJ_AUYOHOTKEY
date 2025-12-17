; ============================================================================
; 성능 및 메모리 최적화 설정
; ============================================================================
ListLines 0           ; 스크립트 실행 시, 상세한 실행 로그(ListLines)를 끔
;KeyHistory 0         ; 키보드 히스토리를 보이지 않도록 설정
#Warn                 ; 경고를 표시(변수 충돌 등) - 디버깅용
#SingleInstance Force ; 이미 스크립트가 실행 중이면, 새로 실행 시 이전 스크립트를 종료
; #NoEnv 지시문은 v2에서 제거됨 (오류의 원인이었음)
SendMode "Input"      ; Send 입력 모드를 Input으로 설정
SetWorkingDir A_ScriptDir  ; 스크립트가 있는 폴더를 작업 디렉토리로 설정
; UIA 라이브러리 포함 (상대 경로 사용)
#include "..\라이브러리\UIA\Lib\UIA.ahk"
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


; 프로그레스 바 관련 전역 변수
global progressGui := ""            ; 프로그레스 바 GUI 객체
global progressBar := ""            ; 프로그레스 바 컨트롤
global progressText := ""           ; 프로그레스 텍스트 컨트롤
global progressStatus := ""         ; 프로그레스 상태 텍스트
global isUploading := false         ; 업로드 진행 중 여부
global shouldCancelUpload := false  ; 업로드 취소 플래그
global totalSteps := 5              ; 전체 진행 단계 수 (채널/사용자 선택, 메시지 작성, 파일 첨부 등)
global currentStep := 0             ; 현재 진행 중인 단계

; ESC 키 처리 핸들러 추가 (전역 핫키로 등록)
Hotkey "~Escape", CancelUpload, "On"

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
    mainGui.Add("Button", "x130 y230 w110 h30", "배한솔").OnEvent("Click", PersonClicked.Bind("배한솔"))
    mainGui.Add("Button", "x10  y270 w110 h30", "이다은").OnEvent("Click", PersonClicked.Bind("이다은"))
    mainGui.Add("Button", "x130 y270 w110 h30", "전혜림").OnEvent("Click", PersonClicked.Bind("전혜림"))
    mainGui.Add("Button", "x10  y310 w110 h30", "장재영").OnEvent("Click", PersonClicked.Bind("장재영"))
    mainGui.Add("Button", "x130 y310 w110 h30", "강지융").OnEvent("Click", PersonClicked.Bind("강지융"))
    mainGui.Add("Button", "x10  y350 w110 h30", "김어진").OnEvent("Click", PersonClicked.Bind("김어진"))
    mainGui.Add("Button", "x130 y350 w110 h30", "류이레").OnEvent("Click", PersonClicked.Bind("류이레"))

    ; (채널에 전송) 부분
    mainGui.Add("Text", "x10 y430 w200 h20", "채널에 전송:")
    mainGui.Add("Button", "x10  y460 w230 h30", "사코팍-오리지널").OnEvent("Click", ChannelClicked.Bind("사코팍-오리지널"))
    mainGui.Add("Button", "x10  y490 w230 h30", "사코팍-일반-멤버십").OnEvent("Click", ChannelClicked.Bind("사코팍-일반-멤버십"))
    mainGui.Add("Button", "x10  y530 w230 h30", "사코팍-background").OnEvent("Click", ChannelClicked.Bind("사코팍-background"))
    mainGui.Add("Button", "x10  y560 w230 h30", "사코팍-character").OnEvent("Click", ChannelClicked.Bind("사코팍-character"))
    mainGui.Add("Button", "x10  y590 w230 h30", "사코팍-ip-insta").OnEvent("Click", ChannelClicked.Bind("사코팍-ip-insta"))

    ; "파일 같이 첨부하기" 체크박스 (기본 체크 상태)
    attachFileCheckbox := mainGui.Add("Checkbox", "x10 y630 vattachFile Checked", "파일 같이 첨부하기")
    
    ; GUI 이벤트 핸들러 설정
    mainGui.OnEvent("Close", GuiCloseHandler)
    mainGui.OnEvent("Escape", GuiEscapeHandler)
    
    ; GUI 표시
    mainGui.Show("w250 h660")
}

; ============================================================================
; 오류 메시지를 항상 최상위에 표시하고, 현재 작업만 중단하는 함수
; ============================================================================
ShowErrorAndStop(message, title := "오류") {
    global progressGui, isUploading, shouldCancelUpload, currentStep
    
    ; 현재 진행 중인 업로드/프로세스 중단 플래그 설정
    shouldCancelUpload := true
    isUploading := false
    
    ; 모든 타이머 즉시 중지
    SetTimer CloseProgressBar, 0
    SetTimer CheckEscapeKey, 0
    
    ; 키보드 입력 대기열 비우기
    BlockInput "On"
    Sleep 100
    Send ""
    Sleep 100
    BlockInput "Off"
    
    ; 중요: 프로그레스 바를 즉시 제거 - 꼭 필요!
    if (progressGui != "") {
        try {
            progressGui.Destroy()  ; 프로그레스 바 즉시 제거
            progressGui := ""
        } catch as e {
            ; 무시
        }
    }
    
    ; 파일 대화상자 닫기 시도
    try {
        WinClose "ahk_class #32770"
        Sleep 50
        Send "{Escape}"
        Sleep 50
    } catch as e {
        ; 무시
    }
    
    ; 잠시 대기 (UI 갱신 위해)
    Sleep 200
    
    ; 최상위 레벨 오류 메시지 표시 (여러 플래그 조합)
    try {
        ; 별도의 GUI로 구현하여 확실히 최상위에 표시
        errorGui := Gui("+AlwaysOnTop +OwnDialogs +ToolWindow", title)
        errorGui.SetFont("s10 bold", "Segoe UI")
        errorGui.Add("Text", "x20 y20 w400", message)
        errorGui.Add("Button", "x170 y70 w100 h30 Default", "확인").OnEvent("Click", (*) => errorGui.Destroy())
        errorGui.OnEvent("Close", (*) => errorGui.Destroy())
        
        ; 현재 화면 중앙에 표시
        MonitorGet(MonitorGetPrimary(), &Left, &Top, &Right, &Bottom)
        centerX := (Right - Left - 440) / 2
        centerY := (Bottom - Top - 120) / 2
        
        errorGui.Show(Format("w440 h120 x{1} y{2}", centerX, centerY))
        
        ; 다른 창 위에 강제로 표시
        WinSetAlwaysOnTop 1, "ahk_id " . errorGui.Hwnd
        
        ; 모달 대화상자처럼 작동하도록 대기
        WinWaitClose "ahk_id " . errorGui.Hwnd
    } catch as e {
        ; 만약 GUI 방식이 실패하면 내장 MsgBox 사용 (백업 방법)
        MsgBox message, title, 4096  ; 시스템 모달
    }
    
    ; 작업 변수 초기화 (다음 핫키 사용을 위해)
    currentStep := 0
    shouldCancelUpload := false
    isUploading := false
    
    ; 프로세스는 중단되었지만 스크립트는 계속 실행됨
    return
}

; ============================================================================
; 입력 대기열 비우기 함수 (후속 자동 입력 방지)
; ============================================================================
EmptyKeyQueue() {
    ; 키보드 입력 일시 차단
    BlockInput "On"
    
    ; 입력 대기열 비우기 위한 시간 간격
    Sleep 100
    
    ; 남아있는 Send 명령 비우기 위해 빈 Send
    Send ""
    
    ; 잠시 대기
    Sleep 100
    
    ; 키보드 입력 차단 해제
    BlockInput "Off"
}

; ============================================================================
; 슬랙 메인 창을 찾고 활성화하는 함수 (개선된 버전)
; ============================================================================
FindAndActivateSlackMainWindow() {
    global progressStatus, currentStep, totalSteps
    
    try {
        ; 프로그레스 바 업데이트
        UpdateProgressBar((currentStep + 0.2) * 100 / totalSteps, "Slack 창 찾는 중 (방법 1: 프로세스 확인)...")
        
        ; Slack 프로세스가 실행 중인지 확인
        if !WinExist("ahk_exe slack.exe") {
            ShowErrorAndStop("Slack이 실행 중이지 않습니다. Slack을 먼저 실행해 주세요.")
            return false
        }
        
        ; 방법 1: 정확히 "- Studio JBBJ - Slack [기본]" 이름의 창을 찾기 시도
        UpdateProgressBar((currentStep + 0.4) * 100 / totalSteps, "Slack 창 찾는 중 (방법 2: 정확한 창 제목)...")
        exactWindowTitle := "- Studio JBBJ - Slack [기본]"
        if WinExist(exactWindowTitle) {
            WinActivate exactWindowTitle
            if WinWaitActive(exactWindowTitle,, 2) {
                return UIA.ElementFromHandle(exactWindowTitle)
            }
        }
        
        ; 방법 2: [기본] 태그가 포함된 Studio JBBJ 창을 찾아봄
        UpdateProgressBar((currentStep + 0.5) * 100 / totalSteps, "Slack 창 찾는 중 (방법 3: 부분 제목 매칭)...")
        slackWindows := WinGetList("ahk_exe slack.exe")
        
        for hwnd in slackWindows {
            winTitle := WinGetTitle("ahk_id " hwnd)
            if InStr(winTitle, "Studio JBBJ") && InStr(winTitle, "[기본]") {
                WinActivate "ahk_id " hwnd
                if WinWaitActive("ahk_id " hwnd,, 2) {
                    return UIA.ElementFromHandle("ahk_id " hwnd)
                }
            }
        }
        
        ; 방법 3: Studio JBBJ가 포함된 창이라도 찾아봄 (기본 태그 없이)
        UpdateProgressBar((currentStep + 0.6) * 100 / totalSteps, "Slack 창 찾는 중 (방법 4: 워크스페이스 기준)...")
        for hwnd in slackWindows {
            winTitle := WinGetTitle("ahk_id " hwnd)
            if InStr(winTitle, "Studio JBBJ") {
                WinActivate "ahk_id " hwnd
                if WinWaitActive("ahk_id " hwnd,, 2) {
                    return UIA.ElementFromHandle("ahk_id " hwnd)
                }
            }
        }
        
        ; 방법 4: 대체 방법 - UIA를 사용하여 워크스페이스 아이콘으로 찾기
        UpdateProgressBar((currentStep + 0.7) * 100 / totalSteps, "Slack 창 찾는 중 (대체 방법: 워크스페이스 아이콘)...")
        return FindSlackByWorkspaceIcon()
        
    } catch as e {
        ShowErrorAndStop("Slack 창을 찾는 중 오류가 발생했습니다: " . e.Message)
        return false
    }
}

; ============================================================================
; 워크스페이스 아이콘으로 슬랙 메인 창을 찾는 대체 방법
; ============================================================================
FindSlackByWorkspaceIcon() {
    try {
        ; 모든 슬랙 창 목록 가져오기
        slackWindows := WinGetList("ahk_exe slack.exe")
        
        ; 창이 없으면 실패
        if (slackWindows.Length < 1) {
            return false
        }
        
        ; 각 슬랙 창에 대해 시도
        for hwnd in slackWindows {
            ; 창 활성화
            WinActivate "ahk_id " hwnd
            if !WinWaitActive("ahk_id " hwnd,, 1) {
                continue
            }
            
            ; UIA 요소 생성 시도
            try {
                slackEl := UIA.ElementFromHandle("ahk_id " hwnd)
                
                ; 워크스페이스 아이콘 찾기 시도
                workspaceIcon := slackEl.ElementFromPath("RQB6")
                
                ; 아이콘을 찾았으면 포커스 설정 후 성공으로 간주
                if (workspaceIcon) {
                    workspaceIcon.SetFocus()
                    Sleep 500
                    
                    ; 로그에 대체 방법 성공 기록
                    OutputDebug "대체 방법으로 슬랙 메인 창 찾기 성공 (워크스페이스 아이콘 사용)"
                    
                    ; 메인 창 UIA 요소 반환
                    return slackEl
                }
            } catch as e {
                ; 이 창에서는 실패했지만, 다음 창에서 계속 시도
                continue
            }
        }
        
        ; 모든 시도 실패, 마지막 대체 방법: 첫 번째 슬랙 창 시도
        ShowErrorAndStop("Slack 메인 창을 찾을 수 없습니다. 슬랙의 기본 창이 열려 있는지 확인하세요.")
        return false
        
    } catch as e {
        ShowErrorAndStop("워크스페이스 아이콘으로 Slack 창을 찾는 중 오류가 발생했습니다: " . e.Message)
        return false
    }
}

; ============================================================================
; 추가: 슬랙 창이 올바르게 활성화되었는지 검증하는 함수
; ============================================================================
VerifySlackWindowActivated(slackEl) {
    try {
        ; 윈도우 제목 확인
        winTitle := WinGetTitle("A")  ; 현재 활성화된 창의 제목
        
        ; 슬랙 관련 키워드 검색
        if (!InStr(winTitle, "Slack") && !InStr(winTitle, "Studio JBBJ")) {
            return false
        }
        
        ; UIA로 확인 - 워크스페이스 아이콘 또는 다른 슬랙 특유의 요소 존재 여부
        try {
            ; 워크스페이스 아이콘 확인 시도
            workspaceIcon := slackEl.ElementFromPath("RQB6")
            if (workspaceIcon) {
                return true
            }
            
            ; 대체 확인: 메시지 입력 영역 존재 여부
            msgInputArea := slackEl.FindFirst("ByName=메시지 작성")
            if (msgInputArea) {
                return true
            }
        } catch {
            ; UIA 확인 실패
            return false
        }
        
        ; 여기까지 왔다면 확인 불가
        return false
        
    } catch as e {
        OutputDebug "슬랙 창 검증 중 오류: " . e.Message
        return false
    }
}



; ============================================================================
; UIA를 사용하여 검색창에 채널 또는 사용자 이름 입력하는 함수
; ============================================================================
SearchForChannelOrUser(name) {
    global progressStatus
    
    try {
        UpdateProgressBar(40, "검색창에 이름 입력 중...")
        
        ; 검색창이 활성화될 때까지 대기
        Sleep 500
        
        ; 검색 입력란에 텍스트 입력
        Send name
        Sleep 300
        
        ; 엔터 키 눌러 검색 결과 선택
        Send "{Enter}"
        Sleep 500
        
        UpdateProgressBar(50, "대화창 열기 완료...")
        return true
    } catch as e {
        MsgBox "채널/사용자 검색 중 오류가 발생했습니다: " . e.Message
        return false
    }
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
    static cbParkJeongin, cbLeeMyeonghoon, cbLeeHyemin, cbBaeHansol, cbLeeDaeun
    static cbJeonHyerim, cbJangJaeyoung, cbKangJiyung, cbJBJ, cbKimEojin

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
    cbBaeHansol := channelGui.Add("Checkbox", "x100 y299", "배한솔")
    cbLeeDaeun := channelGui.Add("Checkbox", "x180 y179", "이다은")
    cbJeonHyerim := channelGui.Add("Checkbox", "x180 y209", "전혜림")
    cbJangJaeyoung := channelGui.Add("Checkbox", "x180 y239", "장재영")
    cbKangJiyung := channelGui.Add("Checkbox", "x180 y269", "강지융")
    cbKimEojin := channelGui.Add("Checkbox", "x260 y209", "김어진")
    cbRyu := channelGui.Add("Checkbox", "x260 y239", "류이레")
    
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
        if (cbBaeHansol.Value)
            gMentionList .= " @배한솔"
        if (cbLeeDaeun.Value)
            gMentionList .= " @이다은"
        if (cbJeonHyerim.Value)
            gMentionList .= " @전혜림"
        if (cbJangJaeyoung.Value)
            gMentionList .= " @장재영"
        if (cbKangJiyung.Value)
            gMentionList .= " @강지융"
        if (cbKimEojin.Value)
            gMentionList .= " @김어진"
        if (cbRyu.Value)
            gMentionList .= " @류이레"


        ; GUI 닫고, 실제 전송 함수 호출
        channelGui.Destroy()
        SendMessageToUserUIA(gChannelName)
    }

    ChannelGuiCloseHandler(*) {
        channelGui.Destroy()
    }
}

; ============================================================================
; 안정적인 텍스트 입력 함수 (클립보드 활용)
; ============================================================================
SafeSendText(text) {
    prevClip := ClipboardAll()  ; 현재 클립보드 내용 백업
    A_Clipboard := text         ; 입력할 텍스트를 클립보드에 복사
    Sleep 100
    ClipWait(2, 0)              ; 클립보드에 텍스트가 복사될 때까지 대기
    Send "^v"                   ; 붙여넣기
    Sleep 100
    A_Clipboard := prevClip     ; 원래 클립보드 내용 복원
    prevClip := ""              ; 메모리 해제
}

; ============================================================================
; 경로 하이퍼링크 삽입 함수 (jbbj:// 프로토콜)
; Slack의 하이퍼링크 기능을 사용하여 클릭 가능한 경로 링크 생성
; ============================================================================
InsertPathHyperlink(filePath) {
    ; jbbj:// 링크 생성
    urlPath := StrReplace(filePath, "\", "/")
    jbbjLink := "jbbj://open/" . urlPath

    ; 클립보드 백업
    prevClip := ClipboardAll()

    ; 1. Slack 하이퍼링크 다이얼로그 열기 (Ctrl+Shift+U)
    Send "^+u"
    Sleep 300

    ; 2. 텍스트 필드에 경로만 붙여넣기 (G:\... 형식)
    A_Clipboard := filePath
    Sleep 100
    ClipWait(2, 0)
    Send "^v"
    Sleep 100

    ; 3. Tab으로 링크 필드로 이동
    Send "{Tab}"
    Sleep 100

    ; 4. 링크 필드에 jbbj:// 링크 붙여넣기
    A_Clipboard := jbbjLink
    Sleep 100
    ClipWait(2, 0)
    Send "^v"
    Sleep 100

    ; 5. Enter로 확인
    Send "{Enter}"
    Sleep 100

    ; 클립보드 복원
    A_Clipboard := prevClip
    prevClip := ""
}

; ============================================================================
; UIA를 활용한 Slack 메시지 전송 함수
; ============================================================================
; ============================================================================
; UIA를 활용한 Slack 메시지 전송 함수 (사용자/채널 구분)
; ============================================================================
SendMessageToUserUIA(userName) {
    global attachFile, savedFileDir, filePathCount, fileNameCount
    global filePathList, fileNameList
    global gEpisodeTitle, gShareContent, gMentionList
    global currentStep, totalSteps, shouldCancelUpload
    
    try {
        ; 프로그레스 바 업데이트
        currentStep++
        UpdateProgressBar(currentStep * 100 / totalSteps, "Slack 창을 찾는 중...")
        if (shouldCancelUpload) {
            CloseProgressBar()
            return
        }
        
        ; Slack 메인 창 찾기
        slackEl := FindAndActivateSlackMainWindow()
        if (!slackEl) {
            return  ; 오류 처리는 FindAndActivateSlackMainWindow 내부에서 완료
        }
        
       ; 사용자(DM)와 채널 구분하여 처리
       if (InStr(userName, "사코팍-")) {
        ; 채널인 경우 - 기존 핫키 방식 사용
if (!OpenChannelChat(userName)) {
    ShowErrorAndStop("채널 '" . userName . "' 열기에 실패했습니다.")
    return  ; 중요: 여기서 반환하면 이후 코드가 실행되지 않음
}
    } else {
        ; 사용자(DM)인 경우 - UIA 활용
if (!OpenUserDM(userName, slackEl)) {
    ShowErrorAndStop("사용자 '" . userName . "' DM 열기에 실패했습니다.")
    return  ; 중요: 여기서 반환하면 이후 코드가 실행되지 않음
}
    }
        
    if (shouldCancelUpload) {
        CloseProgressBar()
        return
    }
        
        ; 메시지 작성 단계
        currentStep++
        UpdateProgressBar(currentStep * 100 / totalSteps, "메시지 작성 중...")
        if (shouldCancelUpload) {
            CloseProgressBar()
            return
        }
        
        ; 채널일 때만 + 입력값이 있을 때만 [ 에피소드 / 공유내용 ] 형식으로 추가
        if (InStr(userName, "사코팍-") && (gEpisodeTitle != "" || gShareContent != "")) {
            Send "*[ " . gEpisodeTitle . " / " . gShareContent . " ]*"
            Sleep 200
            Send "+{Enter}+{Enter}"  ; 줄바꿈 2번
            Sleep 200
            
            ; 채널에서 한 번 사용 후, 다음 전송에는 초기화
            gEpisodeTitle := ""
            gShareContent := ""
        }
        
        ; 메시지 템플릿 입력 (이모지 + 텍스트)
if (InStr(userName, "사코팍-")) {
    ; 채널이면 이모지만
    SafeSendText(":열린_파일_폴더:")
} else {
    ; 사람이면 이모지 + 텍스트 (느낌표 추가)
    SafeSendText(":열린_파일_폴더: 파일 공유드립니다! :열린_파일_폴더:")
}
Sleep 200
Send "+{Enter}"  ; 줄바꿈
Sleep 200

        ; ★ 경로 하이퍼링크 추가 (jbbj:// 프로토콜)
        InsertPathHyperlink(savedFileDir)
        Sleep 200
        Send "+{Enter}"  ; 줄바꿈
        Sleep 200

        ; 코드 블록 시작 (Ctrl+Shift+9)
        Send "^+9"
        Sleep 100

        ; 공통 경로 출력
        SafeSendText(savedFileDir)
        Sleep 200
        Send "+{Enter}"
        Sleep 200
        
        ; 파일 이름들 출력
        Loop fileNameCount {
            if (shouldCancelUpload) {
                break
            }
            
            Send "파일 이름 :"
            Sleep 100
        
            Send "^b"  ; 볼드체 적용
            Sleep 100
            
            ; 파일 이름 출력에 클립보드 방식 사용
            SafeSendText("*" . fileNameList[A_Index] . "*")
            Sleep 200
            Send "+{Enter}"
            Sleep 200
            
            ; 진행률 업데이트
            UpdateProgressBar(currentStep * 100 / totalSteps + (A_Index / fileNameCount) * (100 / totalSteps), 
                "파일 정보 작성 중 (" . A_Index . "/" . fileNameCount . ")")
        }
        
        ; 코드 블록 종료 및 마크다운 적용
        Send "^+9"
        Sleep 100
        Send "^+{F}^+{F}"  ; 마크다운 적용
        Sleep 200
        
        ; 멘션 목록 출력
        if (gMentionList != "") {
            Send "+{Enter}"
            Sleep 200
            Send gMentionList
            Sleep 200
            Send "+{Enter}"
            Sleep 200
            
            ; 멘션 리스트 초기화
            gMentionList := ""
        }
        
        ; 파일 첨부 단계
        currentStep++
        UpdateProgressBar(currentStep * 100 / totalSteps, "파일 첨부 시작...")
        if (shouldCancelUpload) {
            CloseProgressBar()
            return
        }
        
        ; 파일 첨부가 선택된 경우에만 진행
if (attachFile) {
    UpdateProgressBar((currentStep + 0.3) * 100 / totalSteps, "파일 첨부 준비 중...")
    
    ; 개선된 파일 첨부 함수 호출
    AttachFilesImproved()
} else {
    UpdateProgressBar(100, "작업이 완료되었습니다.")
    SetTimer CloseProgressBar, -1500
}
    } catch as e {
        MsgBox "메시지 전송 중 오류가 발생했습니다: " . e.Message
        CloseProgressBar()
    }
}

; ============================================================================
; 채널 대화창 열기 함수 (핫키 방식)
; ============================================================================
OpenChannelChat(channelName) {
    global currentStep, totalSteps, shouldCancelUpload
    
    UpdateProgressBar((currentStep + 0.5) * 100 / totalSteps, "채널 검색 중...")
    
    ; 핫키로 검색창 열기
    Send "^+k"
    Sleep 500
    
    ; 혹시 한글 입력이면 영어로 전환
    SetEnglishInputMode()
    Sleep 100
    
    ; 채널 이름 입력
    Send channelName
    Sleep 300
    Send "{Enter}"
    Sleep 800  ; 채팅창이 열릴 때까지 대기
    
    return true
}

; ============================================================================
; 사용자 DM 열기 함수 (UIA 시도 후 실패 시 핫키 방식으로 전환)
; ============================================================================
OpenUserDM(userName, slackEl) {
    global currentStep, totalSteps, shouldCancelUpload
    
    ; 1단계: UIA 방식 시도
    try {
        ; DM 사이드바 클릭
        UpdateProgressBar((currentStep + 0.3) * 100 / totalSteps, "DM 사이드바 클릭 중...")
        dmSidebarBtn := slackEl.ElementFromPath("VRQIJq")
        if (!dmSidebarBtn) {
            ; UIA 요소를 찾지 못함 - 핫키 방식으로 전환
            return FallbackToHotkeyDM(userName)
        }
        
        ; 사이드바 버튼 클릭
        dmSidebarBtn.Click("left")
        Sleep 500
        
        ; 창 제목 확인 - "새 메시지" 확인
        winTitle := WinGetTitle("ahk_exe slack.exe")
        if (!InStr(winTitle, "새 메시지") || !InStr(winTitle, "[기본]")) {
            ; 올바른 창으로 전환되지 않음 - 핫키 방식으로 전환
            return FallbackToHotkeyDM(userName)
        }
        
        ; DM 검색 콤보박스 클릭
        UpdateProgressBar((currentStep + 0.6) * 100 / totalSteps, "DM 검색 중...")
        dmSearchBox := slackEl.ElementFromPath("VRQQ3")
        if (!dmSearchBox) {
            ; 콤보박스를 찾지 못함 - 핫키 방식으로 전환
            return FallbackToHotkeyDM(userName)
        }
        
        ; 콤보박스 클릭
        dmSearchBox.Click("left")
        Sleep 300
        
        ; 사용자 이름 입력
        Send userName
        Sleep 500
        Send "{Enter}"
        Sleep 800  ; 채팅창이 열릴 때까지 대기
        
        ; 최종 창 제목 확인 (사용자 이름이 포함되어 있는지)
        winTitle := WinGetTitle("ahk_exe slack.exe")
        if (!InStr(winTitle, userName) || !InStr(winTitle, "DM") || !InStr(winTitle, "[기본]")) {
            ; 올바른 DM 창으로 전환되지 않음 - 핫키 방식으로 전환
            return FallbackToHotkeyDM(userName)
        }
        
        ; 모든 단계 성공
        return true
    } catch as e {
        ; UIA 오류 발생 - 핫키 방식으로 전환
        OutputDebug "UIA 오류: " . e.Message . " - 핫키 방식으로 전환합니다."
        return FallbackToHotkeyDM(userName)
    }
}

; ============================================================================
; 핫키 방식으로 DM 창 열기 (UIA 실패 시 대체 방법)
; ============================================================================
FallbackToHotkeyDM(userName) {
    global currentStep, totalSteps, shouldCancelUpload
    
    try {
        UpdateProgressBar((currentStep + 0.5) * 100 / totalSteps, "대체 방식으로 DM 열기 중...")
        
        ; 혹시 열려있는 대화상자 닫기
        Send "{Escape}"
        Sleep 200
        
        ; Ctrl+Shift+K로 빠른 전환 대화상자 열기
        Send "^+k"
        Sleep 500
        
        ; 한글 입력 모드면 영어로 전환
        SetEnglishInputMode()
        Sleep 100
        
        ; 사용자 이름 입력
        Send userName
        Sleep 500
        
        ; Enter로 선택
        Send "{Enter}"
        Sleep 800  ; 대화창이 열릴 때까지 대기
        
        ; 창 제목 확인 (가능한 경우)
        winTitle := WinGetTitle("ahk_exe slack.exe")
        if (InStr(winTitle, userName) && InStr(winTitle, "DM") && InStr(winTitle, "[기본]")) {
            ; 성공적으로 전환됨
            return true
        }
        
        ; 제목으로 확인할 수 없는 경우 (제목이 변경되지 않았더라도)
        ; 추가적인 Tab 키를 눌러 텍스트 입력 영역으로 포커스 이동
        Send "{Tab}"
        Sleep 300
        
        ; 성공으로 간주
        return true
    } catch as e {
        ; 핫키 방식도 실패한 경우
        ShowErrorAndStop("사용자 '" . userName . "' DM 창을 열지 못했습니다: " . e.Message)
        return false
    }
}


; ============================================================================
; 프로그레스 바 생성 함수 - ESC 키 처리 강화
; ============================================================================
CreateProgressBar() {
    global progressGui, progressBar, progressText, progressStatus
    
    ; 이미 생성되어 있다면 닫고 다시 생성
    if (progressGui != "") {
        progressGui.Destroy()
    }
    
    ; 프로그레스 바 GUI 생성
    progressGui := Gui("+AlwaysOnTop -SysMenu +ToolWindow", "Slack 파일 공유 진행 중...")
    progressGui.SetFont("s10", "Segoe UI")
    progressGui.Add("Text", "x10 y10 w380 h20", "Slack에 파일을 공유하는 중입니다. 진행 상황:")
    progressBar := progressGui.Add("Progress", "x10 y40 w380 h30 vProgressBar Range0-100", 0)
    progressText := progressGui.Add("Text", "x10 y80 w380 h20 +Center", "0%")
    progressStatus := progressGui.Add("Text", "x10 y110 w380 h20", "채널/사용자 선택 중...")
    
    ; ESC 키 안내 텍스트 강조
    progressGui.SetFont("s10 Bold cRed", "Segoe UI")
    progressGui.Add("Text", "x10 y140 w380 h20 +Center", "취소하려면 ESC 키를 누르세요.")
    progressGui.SetFont("s10 norm", "Segoe UI")
    
    ; 화면 중앙에 표시
    progressGui.Show("w400 h170 Center NoActivate")
    
    ; ESC 키 감지를 위한 타이머 설정 (더 자주 체크)
    SetTimer CheckEscapeKey, 50  ; 50ms마다 체크 (더 빠른 반응)
}


; ============================================================================
; ESC 키 감지 함수 - 강화 버전
; ============================================================================
CheckEscapeKey() {
    global shouldCancelUpload, isUploading
    
    ; 업로드 중이 아니면 타이머 중지
    if (!isUploading) {
        SetTimer CheckEscapeKey, 0  ; 타이머 중지
        return
    }
    
    ; ESC 키 감지 (글로벌 상태)
    if (GetKeyState("Escape", "P")) {
        ; ESC 키가 눌린 경우 즉시 모든 작업 중단
        SetTimer CheckEscapeKey, 0  ; 이 타이머 중지
        CancelUpload()  ; 취소 함수 호출
    }
}

;=======================================================================
; 프로그레스 바 업데이트 함수
; ============================================================================
UpdateProgressBar(percentage, status := "") {
    global progressBar, progressText, progressStatus
    
    if (progressBar != "") {
        ; 프로그레스 바 값 설정
        progressBar.Value := percentage
        
        ; 텍스트 업데이트
        progressText.Value := percentage . "%"
        
        ; 상태 메시지 업데이트 (제공된 경우)
        if (status != "") {
            progressStatus.Value := status
        }
        
        ; GUI를 새로고침하지만 활성화하지는 않음
        progressGui.Show("NoActivate")
    }
}

; ============================================================================
; 프로그레스 바 닫기 함수
; ============================================================================
CloseProgressBar() {
    global progressGui, isUploading, currentStep
    
    ; ESC 핫키 제거
    try {
        Hotkey "Escape", "Off"
    }
    
    if (progressGui != "") {
        progressGui.Destroy()
        progressGui := ""
    }
    
    isUploading := false
    currentStep := 0
}

; ============================================================================
; 업로드 취소 처리 함수 - 개선된 버전
; ============================================================================
CancelUpload(*) {
    global shouldCancelUpload, progressStatus, isUploading
    
    ; 취소 플래그 설정 및 업로드 상태 변경
    shouldCancelUpload := true
    isUploading := false
    
    ; 프로그레스 바 메시지 업데이트
    UpdateProgressBar(100, "작업이 사용자에 의해 취소되었습니다.")
    if (progressStatus != "") {
        progressStatus.Value := "ESC 키로 중지됨"
    }
    
    ; 슬랙 창에서 실행 중인 작업 강제 중단
    try {
        ; 먼저 모든 열린 대화상자 닫기
        WinClose "ahk_class #32770"  ; 파일 대화상자 닫기
        Send "{Escape}"  ; 혹시 열려있는 다른 대화상자 닫기
        Sleep 200
        
        ; 슬랙 창 포커스 해제
        WinActivate "ahk_class Shell_TrayWnd"
        Sleep 100
        
        ; 모든 AutoHotkey 타이머 중단
        SetTimer CloseProgressBar, 0
        SetTimer CheckEscapeKey, 0
        
        ; 중요 작업 섹션 시작 - 인터럽트 방지
        Critical "On"
    }
    catch as e {
        ; 오류 무시
    }
    
    ; 잠시 후 프로그레스 바 닫기
    SetTimer CloseProgressBar, -1500
    
    ; 강제로 모든 진행 중인 작업 중단을 위한 추가 방법
    Sleep 500
    Critical "Off"  ; 중요 작업 섹션 종료
}

; ============================================================================
; 개선된 파일 첨부 함수 - 불필요한 Alt+Shift+F 로직 제거
; ============================================================================
AttachFilesImproved() {
    global filePathCount, filePathList, attachFile
    global isUploading, shouldCancelUpload, currentStep, totalSteps
    
    ; 파일 첨부 체크박스가 선택되지 않았으면 리턴
    if (!attachFile) {
        UpdateProgressBar(100, "작업이 완료되었습니다.")
        SetTimer CloseProgressBar, -1500
        return
    }
    
    ; 첨부할 파일의 총 개수
    totalFiles := filePathCount
    
    ; 각 파일마다 첨부 진행
    for index, filePath in filePathList {
        ; 취소 플래그 확인 - 더 빈번히 검사
        if (shouldCancelUpload) {
            break
        }
        
        ; 현재 파일 기준 진행률 계산
        baseProgress := currentStep * 100 / totalSteps
        fileProgress := (index - 1) * (100 / totalSteps) / totalFiles
        totalProgress := baseProgress + fileProgress
        
        ; 파일 첨부 시작 메시지
        UpdateProgressBar(Round(totalProgress), 
            "파일 " . index . "/" . totalFiles . " 첨부 중...")
        
        try {
            ; 핫키 방식으로 파일 첨부
            Send "^o"  ; Ctrl+U 키를 통한 파일 첨부
            Sleep 800  ; 파일 첨부 대화상자가 뜨기를 충분히 기다림
            
            ; 취소 플래그 다시 확인
            if (shouldCancelUpload) {
                break
            }
            
            ; 파일 첨부 대화상자 "열기"가 뜰 때까지 대기
            if !WinWaitActive("열기",, 5) {
                ; 대화상자가 나타나지 않으면 오류 처리 및 중단
                ShowErrorAndStop("파일 첨부 대화상자를 찾을 수 없습니다.")
                return
            }
            
            ; 취소 플래그 다시 확인
            if (shouldCancelUpload) {
                Send "{Escape}"  ; 열기 대화상자 닫기
                break
            }
            
            ; 파일 경로 입력 - 클립보드 방식 사용
            prevClip := ClipboardAll()
            A_Clipboard := filePath
            Sleep 100
            ClipWait(2, 0)
            Send "^v"
            Sleep 500  ; 경로 붙여넣기 후 충분히 대기
            
            ; 취소 플래그 다시 확인
            if (shouldCancelUpload) {
                Send "{Escape}"  ; 열기 대화상자 닫기
                break
            }
            
            Send "{Enter}"
            Sleep 1000  ; 파일 업로드 시작을 위한 충분한 대기 시간
            
            ; 클립보드 복원
            A_Clipboard := prevClip
            prevClip := ""
            
            ; 취소 플래그 다시 확인
            if (shouldCancelUpload) {
                break
            }
            
            ; 업로드 대기 시뮬레이션
            SimulateFileUploadProgress(baseProgress, fileProgress, index, totalFiles)
            
            ; 파일 간 추가 대기 시간
            Sleep 1000
            
        } catch as e {
            ShowErrorAndStop("파일 첨부 중 오류가 발생했습니다: " . e.Message)
            return
        }
    }
    
    ; 모든 파일 첨부 완료 또는 취소됨
    if (shouldCancelUpload) {
        UpdateProgressBar(100, "작업이 취소되었습니다.")
    } else {
        UpdateProgressBar(100, "모든 작업이 완료되었습니다!")
    }
    
    ; 잠시 후 프로그레스 바 닫기
    SetTimer CloseProgressBar, -1500
}



; ============================================================================
; 파일 업로드 진행 시뮬레이션 함수
; ============================================================================
SimulateFileUploadProgress(baseProgress, fileProgress, currentFileIndex, totalFiles) {
    global shouldCancelUpload, totalSteps
    
    ; 시뮬레이션할 단계 수
    steps := 10
    
    ; 각 단계별 대기 시간 (ms)
    waitTime := 200
    
    ; 각 단계별 진행
    for step in Range(1, steps) {
        ; 취소 플래그 확인
        if (shouldCancelUpload) {
            return
        }
        
        ; 현재 진행률 계산 (약간의 랜덤성 추가)
        randomFactor := Random(-2, 2)
        stepProgress := (step / steps) * (100 / totalSteps) / totalFiles
        
        ; 전체 진행률에 반영
        totalProgress := Round(baseProgress + fileProgress + stepProgress + randomFactor)
        
        ; 진행률 범위 확인 (100%를 넘지 않도록)
        if (totalProgress > 100)
            totalProgress := 100
        
        ; 프로그레스 바 업데이트
        UpdateProgressBar(totalProgress, 
            "파일 " . currentFileIndex . "/" . totalFiles . " 첨부 중... (" . Round(step * 100 / steps) . "%)")
        
        ; 대기
        Sleep waitTime
    }
}

; ============================================================================
; Range 함수 구현 (유틸리티 함수) - 범위 내 숫자 배열 생성
; ============================================================================
Range(start, end) {
    result := []
    Loop (end - start + 1) {
        result.Push(start + A_Index - 1)
    }
    return result
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
; ============================================================================
; 함수 공통화 - 사람 버튼과 채널 버튼 클릭 처리
; ============================================================================
PersonClicked(personName, ctrl, *) {
    global attachFile, isUploading, shouldCancelUpload, currentStep, totalSteps
    
    ; 현재 GUI 객체 가져오기
    currentGui := ctrl.Gui
    
    ; 체크박스 값 가져오기
    attachFile := currentGui["attachFile"].Value
    
    ; GUI 닫기
    currentGui.Destroy()
    
    ; 프로그레스 바 시작
    isUploading := true
    shouldCancelUpload := false
    currentStep := 0
    CreateProgressBar()
    UpdateProgressBar(5, "사용자 " . personName . "에게 파일 공유 준비 중...")
    
    ; UIA를 사용하여 메시지 전송
    SendMessageToUserUIA(personName)
}

ChannelClicked(channelName, ctrl, *) {
    global attachFile, isUploading, shouldCancelUpload, currentStep, totalSteps
    
    ; 현재 GUI 객체 가져오기
    currentGui := ctrl.Gui
    
    ; 체크박스 값 가져오기
    attachFile := currentGui["attachFile"].Value
    
    ; GUI 닫기
    currentGui.Destroy()
    
    ; 프로그레스 바 시작
    isUploading := true
    shouldCancelUpload := false
    currentStep := 0
    CreateProgressBar()
    UpdateProgressBar(5, "채널 공유 정보 입력 중...")
    
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