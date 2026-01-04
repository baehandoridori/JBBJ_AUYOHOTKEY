#SingleInstance, Force

; ─────────────────────────────────────────────────────────────────────────
; [1] 확인할 프로그램 개수(ProgCount)
;     - 이 코드에서 총 4개 프로그램을 관리하고 있음
;     - 새 프로그램을 추가하려면 이 값을 5, 6... 으로 늘립니다.
; ─────────────────────────────────────────────────────────────────────────
ProgCount := 4

; ─────────────────────────────────────────────────────────────────────────
; [2] 프로그램 정보 설정
;     - ProgramN_Name, ProgramN_InstallPath, ProgramN_SetupPath 세 변수를
;       각 프로그램에 할당. (N = 1~ProgCount)
;
; [★새 프로그램을 추가★] 하는 방법:
;  1) ProgCount 값을 늘린다(예: 5).
;  2) Program5_Name, Program5_InstallPath, Program5_SetupPath 변수를 추가.
;     예) 
;        Program5_Name := "새로 추가할 프로그램"
;        Program5_InstallPath := "C:\Program Files\MyApp"
;        Program5_SetupPath   := "G:\공유 드라이브\...\MyAppSetup.exe"
;  3) RefreshCheck 라벨에서 
;     if (A_Index = 5) { ...특수 로직... }
;     식으로 버전 체크나 설치 여부 확인 로직 작성.
;  4) 설치 버튼(InstallProgram)에서도 
;     if (A_Index = 5) { ... } 
;     식으로 “설치 진행” 로직 추가.
;  5) 끝!
; 
; 아래에는 이미 4개(디스코드, 프로그램1, 블렌더, SW_모호)가 등록된 상태.

; (1) 디스코드
Program1_Name := "디스코드"
Program1_InstallPath := "C:\Users\" . A_UserName . "\AppData\Local\Discord"
Program1_SetupPath   := "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\DiscordSetup.exe"

; (2) 프로그램1
Program2_Name := "프로그램1"
Program2_InstallPath := "C:\Program Files\Program1"
Program2_SetupPath   := "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\Program1Setup.exe"

; (3) 블렌더 (폴더 이름으로 버전 체크)
;     - "C:\Program Files\Blender Foundation\Blender 4.3" 같은 폴더가 있으면 설치됨
;     - 자료실 MSI: "blender-4.2.3-windows-x64.msi" 등
Program3_Name := "블렌더"
Program3_InstallPath := "C:\Program Files\Blender Foundation"
Program3_SetupPath   := "G:\공유 드라이브\JBBJ 자료실\애니메이션 관련 자료들\blender-4.2.3-windows-x64.msi"

; (4) SW_모호 단축키 변경 (버전 체크)
;     - 시작프로그램 폴더에 "SW_모호 단축키 변경ver*.ahk" 형태로 존재하면 설치됨
Program4_Name := "SW_모호 단축키 변경"
Program4_InstallPath := A_StartMenu "\Programs\Startup"
Program4_SetupPath   := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\테스트_마스터폴더"


; ─────────────────────────────────────────────────────────────────────────
; [3] 메인 GUI 생성
;     - 각 프로그램마다 [설치됨/미설치 텍스트] + [설치 진행] 버튼을 배치
; ─────────────────────────────────────────────────────────────────────────
Gui, Destroy
Gui, +AlwaysOnTop +Resize
Gui, Font, s10

; 상단에 안내용 텍스트
Gui, Add, Text, x10 y10 w300 h20 cBlue, ★ 설치 여부 확인 도구 ★
curY := 40

; ProgramN 별로 Text, Button 컨트롤을 자동 생성
Loop, %ProgCount%
{
    installedVar    := "installedVar" A_Index    ; 예: installedVar1, ...
    notInstalledVar := "notInstalledVar" A_Index
    buttonVar       := "buttonVar" A_Index

    varName := "Program" A_Index "_Name"
    thisProgramName := %varName%

    ; 초록색 텍스트 (기본 Hidden)
    Gui, Font, s10 cGreen
    Gui, Add, Text, x20 y%curY% w450 h20 v%installedVar% Hidden, % "[" . thisProgramName . "] - 설치되어 있습니다."

    ; 빨간색 텍스트 (기본 Hidden)
    Gui, Font, s10 cRed
    Gui, Add, Text, x20 y%curY% w450 h20 v%notInstalledVar% Hidden, % "[" . thisProgramName . "] - 설치되어 있지 않습니다."

    ; 검정 폰트 복귀
    Gui, Font, s10 cBlack
    ; “설치 진행” 버튼 (기본 Hidden)
    Gui, Add, Button, x+10 w70 v%buttonVar% gInstallProgram Hidden, 설치 진행

    curY += 30
}

; “새로고침” 버튼
Gui, Add, Button, x20 y+10 gRefreshCheck, 새로고침

; 처음 실행 시 1회 RefreshCheck
GoSub, RefreshCheck

Gui, Show, w600 h%curY%, 설치 상태 확인
Return


; ─────────────────────────────────────────────────────────────────────────
; [4] RefreshCheck (리프레시)
;     - A_Index에 따라 각 프로그램 설치 여부를 확인
;       1,2 => 폴더 존재
;       3 => 블렌더 (폴더명)
;       4 => SW_모호 (파일명)
; ─────────────────────────────────────────────────────────────────────────
RefreshCheck:
{
    Loop, %ProgCount%
    {
        var := "Program" A_Index "_Name"
        programName := %var%
        var := "Program" A_Index "_InstallPath"
        installPath := %var%
        var := "Program" A_Index "_SetupPath"
        setupPath := %var%

        installedVar    := "installedVar" A_Index
        notInstalledVar := "notInstalledVar" A_Index
        buttonVar       := "buttonVar" A_Index

        if (A_Index = 4)
        {
            ; SW_모호 - ver*.ahk 체크
            GoSub, CheckSWMoho
        }
        else if (A_Index = 3)
        {
            ; 블렌더 - 폴더명으로 버전 체크
            GoSub, CheckBlenderByFolder
        }
        else
        {
            ; 디스코드(1), 프로그램1(2) - 폴더만 존재해도 설치
            pathAttr := FileExist(installPath)
            if (pathAttr != "" && InStr(pathAttr, "D"))
            {
                ; 설치됨
                GuiControl,, %installedVar%, % "[" . programName . "] - 설치되어 있습니다."
                GuiControl, Show, %installedVar%
                GuiControl, Hide, %notInstalledVar%
                GuiControl, Hide, %buttonVar%
            }
            else
            {
                ; 미설치
                GuiControl,, %notInstalledVar%, % "[" . programName . "] - 설치되어 있지 않습니다."
                GuiControl, Show, %notInstalledVar%
                GuiControl, Show, %buttonVar%
                GuiControl, Hide, %installedVar%
            }
        }
    }
}
return

; ─────────────────────────────────────────────────────────────────────────
; [보조 라벨] CheckSWMoho
;     - SW_모호 단축키: “SW_모호 단축키 변경ver*.ahk” 파일명에서 버전 추출
; ─────────────────────────────────────────────────────────────────────────
CheckSWMoho:
{
    programName := Program4_Name
    installPath := Program4_InstallPath
    setupPath   := Program4_SetupPath

    installedVar    := "installedVar4"
    notInstalledVar := "notInstalledVar4"
    buttonVar       := "buttonVar4"

    startFile := ""
    startVer  := "0.0"
    patternStart := installPath . "\SW_모호 단축키 변경ver*.ahk"

    ; 설치 폴더에 어떤 버전이 깔려 있는지
    Loop, Files, %patternStart%
    {
        RegExMatch(A_LoopFileName, "ver([\d_]+)\.ahk", m)
        if (m1 != "")
        {
            tmpVerStr := RegExReplace(m1, "_", ".") 
            if (CompareVersion(tmpVerStr, startVer) = 1)
            {
                startVer := tmpVerStr
                startFile := A_LoopFileFullPath
            }
        }
    }

    ; 소스(자료실) 폴더에도 어떤 버전이 있는지
    sourceFile := ""
    sourceVer  := "0.0"
    patternSource := setupPath . "\SW_모호 단축키 변경ver*.ahk"
    Loop, Files, %patternSource%
    {
        RegExMatch(A_LoopFileName, "ver([\d_]+)\.ahk", m)
        if (m1 != "")
        {
            tmpVerStr := RegExReplace(m1, "_", ".")
            if (CompareVersion(tmpVerStr, sourceVer) = 1)
            {
                sourceVer := tmpVerStr
                sourceFile := A_LoopFileFullPath
            }
        }
    }

    if (startFile = "")
    {
        ; 아예 설치되지 않음
        GuiControl,, %notInstalledVar%, % "[" . programName . "] - (파일 없음) 설치되어 있지 않습니다."
        GuiControl, Show, %notInstalledVar%
        GuiControl, Show, %buttonVar%
        GuiControl, Hide, %installedVar%
    }
    else
    {
        ; 버전 비교
        if (CompareVersion(sourceVer, startVer) = 1)
        {
            ; 자료실에 더 높은 버전이 있음
            GuiControl,, %notInstalledVar%, % "[" . programName . "] - (구버전:" . startVer . ") 더 높은 버전:" . sourceVer . " 존재"
            GuiControl, Show, %notInstalledVar%
            GuiControl, Show, %buttonVar%
            GuiControl, Hide, %installedVar%
        }
        else
        {
            ; 설치 버전이 같거나 더 높음
            GuiControl,, %installedVar%, % "[" . programName . "] - 설치됨 (현재:" . startVer . ")"
            GuiControl, Show, %installedVar%
            GuiControl, Hide, %notInstalledVar%
            GuiControl, Hide, %buttonVar%
        }
    }
}
return

; ─────────────────────────────────────────────────────────────────────────
; [보조 라벨] CheckBlenderByFolder
;     - 블렌더를 폴더명("Blender 4.3" 등)으로 버전 판별
; ─────────────────────────────────────────────────────────────────────────
CheckBlenderByFolder:
{
    programName := Program3_Name
    installPath := Program3_InstallPath
    setupPath   := Program3_SetupPath

    installedVar    := "installedVar3"
    notInstalledVar := "notInstalledVar3"
    buttonVar       := "buttonVar3"

    ; 1) 설치 폴더 내 "Blender ..." 폴더 중 가장 높은 버전을 찾음
    foundFolderVer := "0.0"

    ; 한 단계 폴더만 찾는다 (D 옵션). 
    ; 예: "Blender 4.3", "Blender 4.2.1" 등 
    Loop, Files, %installPath%\Blender*, D
    {
        ; 폴더명 예: "Blender 4.3", "Blender 4.2.1"
        if RegExMatch(A_LoopFileName, "Blender\s+([\d\.]+)", m)
        {
            ; m1 = "4.3" or "4.2.1" 등
            ver2 := ExtractMajorMinor(m1)  ; => "4.3" or "4.2"
            if (CompareVersion(ver2, foundFolderVer) = 1)
            {
                foundFolderVer := ver2
            }
        }
    }

    if (foundFolderVer = "0.0")
    {
        ; 폴더가 전혀 없음 => 미설치
        GuiControl,, %notInstalledVar%, % "[" . programName . "] - 설치되지 않았습니다."
        GuiControl, Show, %notInstalledVar%
        GuiControl, Show, %buttonVar%
        GuiControl, Hide, %installedVar%
        return
    }

    ; 2) 자료실 .msi 중 가장 높은 버전 찾기(두 번째 자리만)
    foundMsi := ""
    foundMsiVer := "0.0"

    if (FileExist(setupPath) && !(FileExist(setupPath) = "D"))
    {
        ; 사용자가 SetupPath를 파일로 직접 지정했을 경우
        foundMsi := setupPath
        if RegExMatch(setupPath, "blender-([\d\.]+)-windows", mm)
        {
            tmpVer := ExtractMajorMinor(mm1)
            foundMsiVer := tmpVer
        }
    }
    else
    {
        ; 폴더에 "blender-*.msi"가 여러 개 있을 수도 있으므로
        patternMsi := setupPath . "\blender-*.msi"
        Loop, Files, %patternMsi%
        {
            if RegExMatch(A_LoopFileName, "blender-([\d\.]+)-windows", mm)
            {
                tmpVer := ExtractMajorMinor(mm1)
                if (CompareVersion(tmpVer, foundMsiVer) = 1)
                {
                    foundMsiVer := tmpVer
                    foundMsi := A_LoopFileFullPath
                }
            }
        }
    }

    if (foundMsi = "")
    {
        ; 자료실에 MSI 자체가 없으면 => 설치 버전만 표시
        GuiControl,, %installedVar%, % "[" . programName . "] - 설치됨 (현재:" . foundFolderVer . ")"
        GuiControl, Show, %installedVar%
        GuiControl, Hide, %notInstalledVar%
        GuiControl, Hide, %buttonVar%
    }
    else
    {
        ; 자료실 버전 vs 설치 버전 비교
        if (CompareVersion(foundMsiVer, foundFolderVer) = 1)
        {
            ; MSI 버전이 더 높음
            GuiControl,, %notInstalledVar%, % "[" . programName . "] - 구버전:" . foundFolderVer . " / 새버전:" . foundMsiVer
            GuiControl, Show, %notInstalledVar%
            GuiControl, Show, %buttonVar%
            GuiControl, Hide, %installedVar%
        }
        else
        {
            ; 설치 버전이 같거나 더 높음
            GuiControl,, %installedVar%, % "[" . programName . "] - 설치됨 (현재:" . foundFolderVer . ")"
            GuiControl, Show, %installedVar%
            GuiControl, Hide, %notInstalledVar%
            GuiControl, Hide, %buttonVar%
        }
    }
}
return

; ─────────────────────────────────────────────────────────────────────────
; [5] "설치 진행" 버튼 누르면 실행
;     - SW_모호(4): 파일 복사
;     - 블렌더(3): MSI 실행
;     - 디스코드(1)/프로그램1(2): 그냥 Run
; ─────────────────────────────────────────────────────────────────────────
InstallProgram:
{
    clickedBtn := A_GuiControl
    Loop, %ProgCount%
    {
        buttonVar := "buttonVar" A_Index
        if (clickedBtn = buttonVar)
        {
            if (A_Index = 4)
            {
                ; SW_모호 복사/업데이트 로직
                ; ...
                GoSub, RefreshCheck
            }
            else if (A_Index = 3)
            {
                ; 블렌더 설치 파일(MSI) 실행
                ; (기존 로직 그대로)
                foundMsi := ""
                foundMsiVer := "0.0"
                installPath := Program3_InstallPath
                setupPath   := Program3_SetupPath

                if (FileExist(setupPath) && !(FileExist(setupPath) = "D"))
                {
                    foundMsi := setupPath
                    if RegExMatch(setupPath, "blender-([\d\.]+)-windows", m)
                    {
                        foundMsiVer := ExtractMajorMinor(m1)
                    }
                }
                else
                {
                    patternMsi := setupPath . "\blender-*.msi"
                    Loop, Files, %patternMsi%
                    {
                        if RegExMatch(A_LoopFileName, "blender-([\d\.]+)-windows", mm)
                        {
                            tmpVer := ExtractMajorMinor(mm1)
                            if (CompareVersion(tmpVer, foundMsiVer) = 1)
                            {
                                foundMsiVer := tmpVer
                                foundMsi := A_LoopFileFullPath
                            }
                        }
                    }
                }

                if (foundMsi = "")
                {
                    MsgBox, 48, 오류, 블렌더 설치 파일(MSI)을 찾지 못했습니다.
                    return
                }
                RunWait, %foundMsi%
                ; 설치 끝나면 재확인
                GoSub, RefreshCheck
            }
            else if (A_Index = 1 or A_Index = 2)
            {
                ; 디스코드 / 프로그램1
                programSetup := "Program" A_Index "_SetupPath"
                setupPath := %programSetup%
                Run, %setupPath%
                ; 만약 설치 끝나면 자동 리프레시 하고 싶다면:
                ; RunWait, %setupPath%
                ; GoSub, RefreshCheck
            }
            break
        }
    }
}
return

GuiClose:
ExitApp


; ─────────────────────────────────────────────────────────────────────────
; [보조 함수] CompareVersion(A, B)
;   - "4.2", "4.3.1" 같은 문자열을 '.'으로 나눈 뒤, 앞에서부터 숫자 비교
;   - A > B => 1, A = B => 0, A < B => -1
; ─────────────────────────────────────────────────────────────────────────
CompareVersion(a, b)
{
    arrA := StrSplit(a, ".")
    arrB := StrSplit(b, ".")
    maxLen := (arrA.MaxIndex() > arrB.MaxIndex()) ? arrA.MaxIndex() : arrB.MaxIndex()

    Loop, %maxLen%
    {
        ai := (arrA[A_Index]="") ? 0 : arrA[A_Index]+0
        bi := (arrB[A_Index]="") ? 0 : arrB[A_Index]+0

        if (ai < bi)
            return -1
        else if (ai > bi)
            return 1
    }
    return 0
}

; ─────────────────────────────────────────────────────────────────────────
; [보조 함수] ExtractMajorMinor(fullVerStr)
;   - ex) "4.2.3" -> "4.2"
;   - ex) "4.3"   -> "4.3"
;   - ex) "4.10.1"-> "4.10"
;   => 두 번째 자리까지만 반환
; ─────────────────────────────────────────────────────────────────────────
ExtractMajorMinor(fullVerStr)
{
    arr := StrSplit(fullVerStr, ".")
    major := arr[1]+0
    minor := (arr.Count()>=2) ? arr[2]+0 : 0
    return major "." minor
}
