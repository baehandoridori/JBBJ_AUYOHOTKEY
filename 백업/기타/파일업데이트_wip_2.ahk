#NoEnv
SetWorkingDir %A_ScriptDir%
#SingleInstance, Force
SetBatchLines, -1

; 전역 변수 설정
global masterFolder := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\테스트용 마스터폴더"
global backupFolder := "C:\Backup_scripts"

; GUI 생성 블록 


; 업데이트 파일 선택 블록
; 업데이트 파일 선택 안내문구
Gui, Add, Text, x192 y89 w190 h20 +Center, 업데이트 할 항목 선택
; 업데이트 항목 드롭다운 리스트, 파일마다 설정된 기본 경로값이 있음. 
Gui, Add, DropDownList, x192 y109 w190 R10 vSelectedProgram gUpdatePath, % GetMasterFileList()

; 업데이트 경로 선택 블록
; 업데이트 경로 선택하라는 텍스트
Gui, Add, Text, x192 y139 w200 h30 +Center, 업데이트 경로 선택
; 업데이트 경로 나오는 창임.. 드롭다운 리스트에서 선택하면 드롭다운 리스트의 파일마다 설정된 경로의 기본값으로 나타나게 됨. 경로 다를 시 아래 ... 버튼 클릭해서 수정하는 것
Gui, Add, Edit, x192 y169 w180 h20 vUpdatePath
; 파일 탐색기 열어서 파일 경로 수동설정하는 버튼
Gui, Add, Button, x372 y169 w20 h20 gBrowsePath, ...
; 파일 버전 확인 버튼 블록
; 파일 버전 확인 버튼, 드롭다운리스트에서 선택한 파일의 버전을 확인함. 파일 버전 확인 버튼을 누르면 드롭다운 리스트의 파일마다 설정된 기본경로로 버전확인 시도, 실패하면 수동으로 경로 선택해야 함
Gui, Add, Button, x192 y199 w200 h40 gCheckVersion, 파일 버전 확인

; 로그 창. 읽기전용으로 표기되어야 함.
Gui, Add, Edit, x402 y69 w190 h240 vLogWindow ReadOnly
; 예시 경로 표시 그룹박스, 이건 참고용으로 있는것. 읽기전용으로 나와야 함
; 예시경로 그룹박스
Gui, Add, GroupBox, x2 y59 w170 h240 , 예시 경로
; 모호 스크립트 예시경로
Gui, Add, Text, x12 y89 w160 h20 , 모호14 성원단축키 스크립트
Gui, Add, Edit, x12 y109 w160 h50 ReadOnly, %A_AppData%\Adobe\Animate\2024\Shortcuts
; 애니메이트 단축키 예시경로
Gui, Add, Text, x12 y159 w160 h20 , 애니메이트 단축키
Gui, Add, Edit, x12 y179 w160 h50 ReadOnly, %A_LocalAppData%\Adobe\Animate 2024\ko_KR\Configuration\Commands
; 모호 단축키 예시경로
Gui, Add, Text, x12 y229 w160 h20 , 모호 단축키
Gui, Add, Edit, x12 y249 w160 h50 ReadOnly, [모호 커스텀 폴더 설치 폴더 경로]\Moho Pro\Keyboard Shortcuts
; 업데이트 버튼, 이거 누르면 업데이트 동작 실행함
Gui, Add, Button, x192 y249 w200 h60 gUpdateFiles, 업데이트
; 피드백 보내기 버튼 누르면 G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new 경로의 피드백.ahk 실행 
Gui, Add, Button, x22 y329 w100 h30 gSendFeedback, 피드백 보내기
; 종료버튼 누르면 스크립트 완전 종료
Gui, Add, Button, x482 y329 w100 h30 gGuiClose, 종료
Gui, Font, S14 CDefault Bold, Verdana
Gui, Add, Text, x172 y9 w290 h40 +Center, JBBJ 단축키/ 스크립트 업데이트

Gui, Show, w608 h379, 파일 버전 업데이트

; 초기 버전 확인
CheckInitialVersions()
return

GuiClose:
ExitApp



BrowsePath:
FileSelectFolder, selectedPath, , 3
if (selectedPath != "")
    GuiControl,, UpdatePath, %selectedPath%
return

CheckVersion:
Gui, Submit, NoHide
CheckFileVersion(SelectedProgram, UpdatePath)
return

UpdateFiles:
Gui, Submit, NoHide
PerformUpdate(SelectedProgram, UpdatePath)
return

SendFeedback:
Run, G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\피드백.ahk
return

GetMasterFileList() {
    fileList := ""
    Loop, %masterFolder%\*.*
    {
        fileList .= A_LoopFileName . "|"
    }
    return RTrim(fileList, "|")
}

UpdatePath:
Gui, Submit, NoHide
path := GetDefaultPath(SelectedProgram)
if (path = "") {
    path := masterFolder . "\" . SelectedProgram
}
GuiControl,, UpdatePath, %path%
return



; ===== %A_AppData% : AppDate\Roming 경로 환경변수. %A_LocalAppData% : AppData\Local 경로 환경변수 (Edit창에서 각자 User 이름으로 출력될 것임) =====
GetDefaultPath(filename) {
    switch filename {
        case "애니메이트 키보드 단축키.txt":
            return "%A_AppData%\Adobe\Animate\2024\Shortcuts"
        case "애니메이트 커맨드.txt":
            return "%A_LocalAppData%\Adobe\Animate 2024\ko_KR\Configuration\Commands"
        case "모호 단축키.txt":
            return "[모호 커스텀 폴더 설치 폴더 경로]\Moho Pro\Keyboard Shortcuts"
        case "SW_모호 단축키 변경.txt":
            return "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
        default:
            return ""
    }
}

CheckFileVersion(program, path) {
    masterFile := masterFolder . "\" . program
    existingFile := path . "\" . program
    
    if !FileExist(masterFile) {
        AppendLog("마스터 파일이 존재하지 않습니다: " . masterFile)
        return
    }
    
    if !FileExist(existingFile) {
        AppendLog("기존 파일이 존재하지 않습니다. 업데이트가 필요합니다.")
        return
    }
    
    FileGetSize, masterSize, %masterFile%
    FileGetSize, existingSize, %existingFile%
    
    if (masterSize != existingSize) {
        AppendLog("파일 크기가 다릅니다. 업데이트가 필요합니다.")
    } else {
        AppendLog("파일 버전이 일치합니다.")
    }
}

PerformUpdate(program, path) {
    masterFile := masterFolder . "\" . program
    existingFile := path . "\" . program
    backupFile := backupFolder . "\" . program
    
    if !FileExist(masterFile) {
        AppendLog("마스터 파일이 존재하지 않습니다: " . masterFile)
        return
    }
    
    FileCreateDir, %backupFolder%
    
    if FileExist(existingFile) {
        FileMove, %existingFile%, %backupFile%, 1
        if ErrorLevel {
            AppendLog("기존 파일 백업 실패: " . existingFile)
            return
        }
        AppendLog("기존 파일 백업 완료: " . backupFile)
    }
    
    FileCopy, %masterFile%, %existingFile%, 1
    if ErrorLevel {
        AppendLog("파일 업데이트 실패: " . existingFile)
        return
    }
    
    AppendLog("파일 업데이트 완료: " . existingFile)
    MsgBox, 0, 업데이트 완료, 파일 업데이트가 완료되었습니다.
}

AppendLog(message) {
    GuiControlGet, currentLog,, LogWindow
    newLog := currentLog . "`n" . message
    GuiControl,, LogWindow, %newLog%
}

CheckInitialVersions() {
    programs := ["애니메이트 키보드 단축키", "애니메이트 커맨드", "모호 단축키", "SW_모호 단축키 변경"]
    for _, program in programs {
        path := GetDefaultPath(program)
        masterFile := masterFolder . "\" . program
        existingFile := path . "\" . program
        
        if !FileExist(masterFile) {
            AppendLog(program . ": 마스터 파일 없음")
            continue
        }
        
        if !FileExist(existingFile) {
            AppendLog(program . ": 파일 없음")
            continue
        }
        
        FileGetSize, masterSize, %masterFile%
        FileGetSize, existingSize, %existingFile%
        
        if (masterSize != existingSize) {
            AppendLog(program . ": 업데이트 필요")
        } else {
            AppendLog(program . ": 문제없음")
        }
    }
}