#NoEnv  ; 권장
SendMode Input  ; 권장
SetWorkingDir %A_ScriptDir%  ; 기본 작업 디렉토리 설정

; === 초기 설정 ===
masterFolder := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\테스트용 마스터폴더"
testPathFolder := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\테스트용 경로폴더"
defaultPath := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\테스트용 기본설정경로"
backupDir := "C:\ScriptsAndShortCut_Backup"

; 백업 폴더가 존재하지 않으면 생성
if not FileExist(backupDir)
{
    FileCreateDir, %backupDir%
    if ErrorLevel
    {
        MsgBox, 16, 오류, 백업 폴더를 생성할 수 없습니다.`n경로: %backupDir%
        ExitApp
    }
}

; === GUI 구성 ===
; 업데이트 파일 선택 블록
Gui, Add, Text, x192 y89 w190 h20 Center, 업데이트 할 항목 선택
Gui, Add, DropDownList, x192 y109 w190 h20 vSelectedFile gFileSelectionChanged, 파일 목록을 불러오는 중...

; 업데이트 경로 선택 블록
Gui, Add, Text, x192 y139 w200 h30 Center, 업데이트 경로 선택
Gui, Add, Edit, x192 y169 w180 h20 vUpdatePath, 
Gui, Add, Button, x372 y169 w20 h20 gBrowsePath, ...

; 파일 버전 확인 버튼 블록
Gui, Add, Button, x192 y199 w200 h40 gCheckVersion, 파일 버전 확인

; 로그 창. 읽기전용으로 표기
Gui, Add, Edit, x402 y69 w190 h240 ReadOnly vLogEdit, 로그 창(읽기전용)

; 예시 경로 표시 그룹박스 (읽기전용)
Gui, Add, GroupBox, x2 y59 w170 h240, 예시 경로
Gui, Add, Text, x12 y89 w160 h20, 모호14 성원단축키 스크립트
Gui, Add, Edit, x12 y109 w160 h50 ReadOnly, %defaultPath%
Gui, Add, Text, x12 y159 w160 h20, 애니메이트 단축키
Gui, Add, Edit, x12 y179 w160 h50 ReadOnly, %defaultPath%
Gui, Add, Text, x12 y229 w160 h20, 모호 단축키
Gui, Add, Edit, x12 y249 w160 h50 ReadOnly, %defaultPath%

; 업데이트 버튼
Gui, Add, Button, x192 y249 w200 h60 gUpdateFile, 업데이트

; 피드백 보내기 버튼
Gui, Add, Button, x22 y329 w100 h30 gSendFeedback, 피드백 보내기

; 종료 버튼
Gui, Add, Button, x482 y329 w100 h30 gExitScript, 종료

; 제목 및 폰트 설정
Gui, Font, S14 CDefault Bold, Verdana
Gui, Add, Text, x172 y9 w290 h40, JBBJ 단축키/ 스크립트 업데이트

; GUI 표시
Gui, Show, x898 y544 h379 w608, New GUI Window
Return

; === 함수 정의 ===

; 마스터 폴더의 파일 목록을 드롭다운 리스트에 추가하는 함수
PopulateDropDownList()
{
    global masterFolder
    fileList := ""
    Loop, Files, % masterFolder "\*.*"
    {
        if (A_LoopFileName ~= "_v\d+\.\d+") ; 버전 패턴을 가진 파일만 추가
        {
            fileList .= A_LoopFileName "|"
        }
    }
    StringTrimRight, fileList, fileList, 1 ; 마지막 | 제거
    GuiControl,, SelectedFile, %fileList%
}

; 파일 선택 시 기본 경로 설정
FileSelectionChanged:
    Gui, Submit, NoHide
    ; 기본 경로 설정 (여기서는 모든 파일의 기본 경로가 동일하다고 가정)
    GuiControl,, UpdatePath, %defaultPath%
    LogMessage("파일 선택됨: " SelectedFile)
Return

; 경로 탐색기 열기
BrowsePath:
    FileSelectFolder, selectedFolder, , 3, 업데이트 경로를 선택하세요:
    if selectedFolder
    {
        GuiControl,, UpdatePath, %selectedFolder%
        LogMessage("경로 변경됨: " selectedFolder)
    }
Return

; 로그 메시지를 로그 창에 추가하는 함수
LogMessage(msg)
{
    GuiControlGet, currentLog, , LogEdit
    newLog := currentLog . msg . "`n"
    GuiControl,, LogEdit, %newLog%
}

; 버전 비교 함수
GetFileVersion(filePath)
{
    ; 파일 이름에서 버전 추출 (_v1.0 등)
    SplitPath, filePath, OutName, OutDir, OutExtension, OutNameNoExt, OutDrive
    if RegExMatch(OutNameNoExt, "_v(\d+)\.(\d+)", versionMatch)
    {
        major := versionMatch1
        minor := versionMatch2
        return major * 1000 + minor ; 버전을 숫자로 변환하여 비교 용이하게 함
    }
    return 0
}

; 파일 버전 확인 핸들러
CheckVersion:
    Gui, Submit, NoHide
    masterFilePath := masterFolder "\" SelectedFile
    targetFilePath := UpdatePath "\" SelectedFile

    ; 마스터 파일 존재 확인
    if not FileExist(masterFilePath)
    {
        LogMessage("마스터 파일이 존재하지 않습니다: " masterFilePath)
        MsgBox, 16, 오류, 마스터 파일이 존재하지 않습니다.`n경로: %masterFilePath%
        Return
    }

    ; 대상 파일 존재 확인
    if not FileExist(targetFilePath)
    {
        LogMessage("대상 파일이 존재하지 않습니다: " targetFilePath)
        MsgBox, 48, 정보, 대상 파일이 존재하지 않습니다. 업데이트가 필요합니다.
        Return
    }

    ; 버전 추출
    masterVersion := GetFileVersion(masterFilePath)
    targetVersion := GetFileVersion(targetFilePath)

    ; 버전 비교
    if (masterVersion > targetVersion)
    {
        LogMessage("마스터 파일 버전: " masterVersion " > 대상 파일 버전: " targetVersion " → 업데이트 필요")
        MsgBox, 64, 정보, 업데이트가 필요합니다. (마스터 버전: %masterVersion% > 대상 버전: %targetVersion%)
    }
    else if (masterVersion = targetVersion)
    {
        LogMessage("마스터 파일 버전: " masterVersion " = 대상 파일 버전: " targetVersion " → 최신 버전입니다.")
        MsgBox, 64, 정보, 파일이 최신 버전입니다.
    }
    else
    {
        LogMessage("마스터 파일 버전: " masterVersion " < 대상 파일 버전: " targetVersion " → 대상 파일이 더 최신입니다.")
        MsgBox, 48, 정보, 대상 파일이 마스터 파일보다 최신입니다.
    }
Return

; 파일 업데이트 핸들러
UpdateFile:
    Gui, Submit, NoHide
    masterFilePath := masterFolder "\" SelectedFile
    targetFilePath := UpdatePath "\" SelectedFile

    ; 마스터 파일 존재 확인
    if not FileExist(masterFilePath)
    {
        LogMessage("마스터 파일이 존재하지 않습니다: " masterFilePath)
        MsgBox, 16, 오류, 마스터 파일이 존재하지 않습니다.`n경로: %masterFilePath%
        Return
    }

    ; 대상 파일 존재 여부 확인
    if FileExist(targetFilePath)
    {
        ; 백업 경로 설정
        backupFilePath := backupDir "\" SelectedFile
        ; 기존 파일 백업
        FileCopy, %targetFilePath%, %backupFilePath%, 1
        if ErrorLevel
        {
            LogMessage("백업 실패: " targetFilePath " → " backupFilePath)
            MsgBox, 16, 오류, 파일을 백업하는 데 실패했습니다.
            Return
        }
        LogMessage("백업 완료: " targetFilePath " → " backupFilePath)
    }
    else
    {
        LogMessage("대상 파일이 존재하지 않아 백업을 생략합니다.")
    }

    ; 파일 업데이트 (마스터 파일을 대상 경로로 복사)
    FileCopy, %masterFilePath%, %targetFilePath%, 1
    if ErrorLevel
    {
        LogMessage("업데이트 실패: " masterFilePath " → " targetFilePath)
        MsgBox, 16, 오류, 파일을 업데이트하는 데 실패했습니다.
        Return
    }
    LogMessage("업데이트 완료: " masterFilePath " → " targetFilePath)
    MsgBox, 64, 성공, 업데이트가 성공적으로 완료되었습니다.
Return

; 피드백 보내기 핸들러
SendFeedback:
    feedbackScript := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\피드백.ahk"
    if FileExist(feedbackScript)
    {
        Run, %feedbackScript%
        LogMessage("피드백 스크립트 실행됨: " feedbackScript)
    }
    else
    {
        LogMessage("피드백 스크립트가 존재하지 않습니다: " feedbackScript)
        MsgBox, 16, 오류, 피드백 스크립트가 존재하지 않습니다.`n경로: %feedbackScript%
    }
Return

; 종료 핸들러
ExitScript:
    ExitApp
Return

; GUI 종료 시 스크립트 종료
GuiClose:
    ExitApp
Return

; === 스크립트 시작 시 DropDownList 채우기 ===
OnExit, ExitScript
PopulateDropDownList()
Return
