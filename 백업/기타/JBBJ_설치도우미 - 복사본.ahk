#SingleInstance, Force

; ─────────────────────────────────────────────────────────────────────────
; [1] 확인할 프로그램 개수(ProgCount)
;     - 이 코드에서 총 4개 프로그램을 관리하고 있음
;     - 새 프로그램을 추가하려면 이 값을 5, 6... 으로 늘립니다.
; ─────────────────────────────────────────────────────────────────────────
ProgCount := 4

; ─────────────────────────────────────────────────────────────────────────
; [2] 프로그램 정보 설정
; ─────────────────────────────────────────────────────────────────────────
; 여기서 "ProgramN_Name", "ProgramN_InstallPath", "ProgramN_SetupPath"를 정의합니다.
;  - N은 1부터 ProgCount까지의 번호
;  - 예를 들어, Program1_Name / Program1_InstallPath / Program1_SetupPath 처럼 3개의 변수를 하나의 프로그램 몫으로 사용
;
; [★새 프로그램을 추가★] 하는 방법:
;  1) ProgCount 값 증가 (예: 5로 변경)
;  2) Program5_Name, Program5_InstallPath, Program5_SetupPath 변수를 새로 만듦
;      예) Program5_Name := "내가 추가하고 싶은 프로그램명"
;          Program5_InstallPath := "C:\Program Files\새프로그램폴더"  ; 폴더로 존재하면 설치된 것으로 판단
;          Program5_SetupPath   := "G:\공유 드라이브\...\새프로그램설치파일.exe"
;  3) 만약 "버전 체크" 로직이 필요하다면, RefreshCheck 라벨에서
;     if (A_Index = 5) { ...특수 로직... } 식으로 원하는 검사 과정을 작성
;  4) "설치 진행" 버튼을 눌렀을 때 실행될 로직(InstallProgram 라벨)에서
;     if (A_Index = 5) { ... 설치 혹은 복사, 버전 비교, RunWait ... }
;     같은 형태로 로직을 붙이면 됩니다.
;  5) 끝!
; 
; 아래 예시는 이미 1~4번 프로그램이 등록된 모습.

; (1) 디스코드
Program1_Name := "디스코드"
Program1_InstallPath := "C:\Users\" . A_UserName . "\AppData\Local\Discord"
Program1_SetupPath   := "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\DiscordSetup.exe"

; (2) 프로그램1
Program2_Name := "프로그램1"
Program2_InstallPath := "C:\Program Files\Program1"
Program2_SetupPath   := "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\Program1Setup.exe"

; (3) 블렌더 (버전 체크)
;   - 실제 "blender.exe"의 파일 버전을 읽어 업데이트 여부를 판단
;   - SetupPath에 *.msi 파일을 두고, "blender-4.2.3-windows-x64.msi" 같은 규칙으로 버전 추출
Program3_Name := "블렌더"
Program3_InstallPath := "C:\Program Files\Blender Foundation"
Program3_SetupPath   := "G:\공유 드라이브\JBBJ 자료실\애니메이션 관련 자료들\blender-4.2.3-windows-x64.msi"

; (4) SW_모호 단축키 변경 (버전 체크)
;   - 시작프로그램 폴더(A_StartMenu "\Programs\Startup") 안에 "SW_모호 단축키 변경ver*.ahk" 로 존재 여부/버전 확인
Program4_Name := "SW_모호 단축키 변경"
Program4_InstallPath := A_StartMenu "\Programs\Startup"
Program4_SetupPath   := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\테스트_마스터폴더"


; ─────────────────────────────────────────────────────────────────────────
; [3] 메인 GUI 생성
;     - 각 프로그램마다 "설치됨 텍스트(초록)" + "설치 안됨 텍스트(빨간)" + "설치 진행" 버튼을 만든다.
; ─────────────────────────────────────────────────────────────────────────
Gui, Destroy
Gui, +AlwaysOnTop +Resize
Gui, Font, s10

Gui, Add, Text, x10 y10 w300 h20 cBlue, ★ 설치 여부 확인 도구 ★
curY := 40

Loop, %ProgCount%
{
    installedVar    := "installedVar" A_Index
    notInstalledVar := "notInstalledVar" A_Index
    buttonVar       := "buttonVar" A_Index

    varName := "Program" A_Index "_Name"
    thisProgramName := %varName%

    ; 초록색 텍스트 (기본은 Hidden)
    Gui, Font, s10 cGreen
    Gui, Add, Text, x20 y%curY% w450 h20 v%installedVar% Hidden, % "[" . thisProgramName . "] - 설치되어 있습니다."

    ; 빨간색 텍스트 (기본은 Hidden)
    Gui, Font, s10 cRed
    Gui, Add, Text, x20 y%curY% w450 h20 v%notInstalledVar% Hidden, % "[" . thisProgramName . "] - 설치되어 있지 않습니다."

    Gui, Font, s10 cBlack
    Gui, Add, Button, x+10 w70 v%buttonVar% gInstallProgram Hidden, 설치 진행

    curY += 30
}

Gui, Add, Button, x20 y+10 gRefreshCheck, 새로고침

GoSub, RefreshCheck
Gui, Show, w600 h%curY%, 설치 상태 확인
Return


; ─────────────────────────────────────────────────────────────────────────
; [4] RefreshCheck (리프레시)
;     - 디스코드/프로그램1(1,2) => 폴더 존재만 확인
;     - 블렌더(3) => blender.exe 파일 버전 읽기(디렉터리 검색 + DllCall)
;     - SW_모호(4) => AHK 파일명에 적힌 ver 숫자 비교
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
            ; ────────── SW_모호 버전 로직 ──────────
            startFile := ""
            startVer  := "0.0"
            patternStart := installPath . "\SW_모호 단축키 변경ver*.ahk"

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
                GuiControl,, %notInstalledVar%, % "[" . programName . "] - (파일 없음) 설치되어 있지 않습니다."
                GuiControl, Show, %notInstalledVar%
                GuiControl, Show, %buttonVar%
                GuiControl, Hide, %installedVar%
            }
            else
            {
                if (CompareVersion(sourceVer, startVer) = 1)
                {
                    GuiControl,, %notInstalledVar%, % "[" . programName . "] - (구버전:" . startVer . ") 더 높은 버전:" . sourceVer . " 존재"
                    GuiControl, Show, %notInstalledVar%
                    GuiControl, Show, %buttonVar%
                    GuiControl, Hide, %installedVar%
                }
                else
                {
                    GuiControl,, %installedVar%, % "[" . programName . "] - 설치됨 (현재:" . startVer . ")"
                    GuiControl, Show, %installedVar%
                    GuiControl, Hide, %notInstalledVar%
                    GuiControl, Hide, %buttonVar%
                }
            }
        }
        else if (A_Index = 3)
        {
            ; ────────── 블렌더 exe 버전 로직 ──────────
            baseDir := installPath
            foundBlenderExe := ""
            foundBlenderVer := "0.0.0.0"
            searchPath := baseDir . "\*"

            Loop, Files, %searchPath%, D
            {
                if InStr(A_LoopFileName, "Blender")
                {
                    currentExe := A_LoopFileFullPath . "\blender.exe"
                    if FileExist(currentExe)
                    {
                        currentVer := GetExeVersion(currentExe)
                        if (currentVer = "")
                            currentVer := "0.0.0.0"
                        if (CompareVersion(currentVer, foundBlenderVer) = 1)
                        {
                            foundBlenderVer := currentVer
                            foundBlenderExe := currentExe
                        }
                    }
                }
            }

            if (foundBlenderExe = "")
            {
                GuiControl,, %notInstalledVar%, % "[" . programName . "] - 설치되지 않았습니다."
                GuiControl, Show, %notInstalledVar%
                GuiControl, Show, %buttonVar%
                GuiControl, Hide, %installedVar%
            }
            else
            {
                foundMsi := ""
                foundMsiVer := "0.0.0.0"

                if (FileExist(setupPath) and !(FileExist(setupPath) = "D"))
                {
                    foundMsi := setupPath
                    RegExMatch(setupPath, "blender-([\d\.]+)-windows", m)
                    if (m1 != "")
                        foundMsiVer := m1 . ".0"
                }
                else
                {
                    patternMsi := setupPath . "\blender-*.msi"
                    Loop, Files, %patternMsi%
                    {
                        if RegExMatch(A_LoopFileName, "blender-([\d\.]+)-windows", m)
                        {
                            curVer := m1 . ".0"
                            if (CompareVersion(curVer, foundMsiVer) = 1)
                            {
                                foundMsiVer := curVer
                                foundMsi := A_LoopFileFullPath
                            }
                        }
                    }
                }

                if (foundMsi = "")
                {
                    GuiControl,, %installedVar%, % "[" . programName . "] - 설치됨 (현재:" . foundBlenderVer . ")"
                    GuiControl, Show, %installedVar%
                    GuiControl, Hide, %notInstalledVar%
                    GuiControl, Hide, %buttonVar%
                }
                else
                {
                    if (CompareVersion(foundMsiVer, foundBlenderVer) = 1)
                    {
                        GuiControl,, %notInstalledVar%, % "[" . programName . "] - 구버전:" . foundBlenderVer . " / 새버전:" . foundMsiVer
                        GuiControl, Show, %notInstalledVar%
                        GuiControl, Show, %buttonVar%
                        GuiControl, Hide, %installedVar%
                    }
                    else
                    {
                        GuiControl,, %installedVar%, % "[" . programName . "] - 설치됨 (현재:" . foundBlenderVer . ")"
                        GuiControl, Show, %installedVar%
                        GuiControl, Hide, %notInstalledVar%
                        GuiControl, Hide, %buttonVar%
                    }
                }
            }
        }
        else
        {
            ; ────────── 디스코드(1), 프로그램1(2) : 폴더 존재 여부 ──────────
            pathAttr := FileExist(installPath)
            if (pathAttr != "" && InStr(pathAttr, "D"))
            {
                GuiControl,, %installedVar%, % "[" . programName . "] - 설치되어 있습니다."
                GuiControl, Show, %installedVar%
                GuiControl, Hide, %notInstalledVar%
                GuiControl, Hide, %buttonVar%
            }
            else
            {
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
; [보조함수] GetExeVersion(filePath)
;   - DllCall("Version.dll")을 통해, EXE의 파일 버전을 읽어온다 (FileGetVersion() 대체)
;   - 오토핫키 구버전(v1.1.27 이전)에서도 동작
;   - 반환 예시: "4.2.3.0"
; ─────────────────────────────────────────────────────────────────────────
GetExeVersion(filePath)
{
    hModule := DllCall("LoadLibrary", "Str", "Version.dll", "UPtr")
    if !hModule
        return ""
    size := DllCall("Version.dll\GetFileVersionInfoSizeA", "Str", filePath, "UInt", 0, "UInt")
    if !size
        return ""
    VarSetCapacity(buf, size, 0)
    if !DllCall("Version.dll\GetFileVersionInfoA", "Str", filePath, "UInt", 0, "UInt", size, "Ptr", &buf)
        return ""
    pBlock := 0
    verSize := 0
    if !DllCall("Version.dll\VerQueryValueA", "Ptr", &buf, "Str", "\", "PtrP", pBlock, "UIntP", verSize)
        return ""

    major := NumGet(pBlock, 10, "UShort")
    minor := NumGet(pBlock, 8,  "UShort")
    patch := NumGet(pBlock, 14, "UShort")
    build := NumGet(pBlock, 12, "UShort")
    DllCall("FreeLibrary", "UPtr", hModule)

    return major "." minor "." patch "." build
}

; ─────────────────────────────────────────────────────────────────────────
; [테스트용] 실제 설치된 blender.exe 버전을 MsgBox로 보여주는 샘플
;           필요 없으면 주석처리 or 삭제 가능
; ─────────────────────────────────────────────────────────────────────────
baseDir := "C:\Program Files\Blender Foundation"
foundBlenderExe := ""
foundBlenderVer := "0.0.0.0"
searchPath := baseDir . "\*"
Loop, Files, %searchPath%, D
{
    if InStr(A_LoopFileName, "Blender")
    {
        currentExe := A_LoopFileFullPath . "\blender.exe"
        if FileExist(currentExe)
        {
            currentVer := GetExeVersion(currentExe)
            if (currentVer = "")
                currentVer := "0.0.0.0"
            if (CompareVersion(currentVer, foundBlenderVer) = 1)
            {
                foundBlenderVer := currentVer
                foundBlenderExe := currentExe
            }
        }
    }
}
if (foundBlenderExe = "")
{
    MsgBox, Blender is not installed.
}
else
{
    MsgBox, Blender Version: %foundBlenderVer%
}

; ─────────────────────────────────────────────────────────────────────────
; [5] "설치 진행" 버튼 누르면 실행
;     - SW_모호(Program4): 파일 복사 로직 (여기선 생략)
;     - 블렌더(Program3): MSI 실행 (RunWait)
;     - 디스코드/프로그램1(Program1/2): 그냥 Run
; ─────────────────────────────────────────────────────────────────────────
InstallProgram:
{
    clickedBtn := A_GuiControl
    Loop, %ProgCount%
    {
        buttonVar := "buttonVar" A_Index
        if (clickedBtn = buttonVar)
        {
            var := "Program" A_Index "_Name"
            programName := %var%
            var := "Program" A_Index "_InstallPath"
            installPath := %var%
            var := "Program" A_Index "_SetupPath"
            setupPath := %var%

            ; 4) SW_모호
            if (A_Index = 4)
            {
                ; 예) FileDelete / FileCopy 등으로 복사
                ; ...
                GoSub, RefreshCheck
            }
            ; 3) 블렌더
            else if (A_Index = 3)
            {
                foundMsi := ""
                foundMsiVer := "0.0.0.0"
                if (FileExist(setupPath) and !(FileExist(setupPath) = "D"))
                {
                    foundMsi := setupPath
                    RegExMatch(setupPath, "blender-([\d\.]+)-windows", m)
                    if (m1 != "")
                        foundMsiVer := m1 ".0"
                }
                else
                {
                    patternMsi := setupPath . "\blender-*.msi"
                    Loop, Files, %patternMsi%
                    {
                        if RegExMatch(A_LoopFileName, "blender-([\d\.]+)-windows", m)
                        {
                            curVer := m1 . ".0"
                            if (CompareVersion(curVer, foundMsiVer) = 1)
                            {
                                foundMsiVer := curVer
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
                GoSub, RefreshCheck
            }
            ; 1) 디스코드 / 2) 프로그램1
            else
            {
                Run, %setupPath%
                ; 설치 끝나고 재확인하려면:
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
;  - "4.2.3.0" 형태를 '.'으로 나눠서 각각 정수로 비교
;  - A > B → 1, A = B → 0, A < B → -1
; ─────────────────────────────────────────────────────────────────────────
CompareVersion(a, b)
{
    arrA := SplitStrByDot(a)
    arrB := SplitStrByDot(b)
    maxLen := (arrA.MaxIndex() > arrB.MaxIndex()) ? arrA.MaxIndex() : arrB.MaxIndex()

    Loop, %maxLen%
    {
        ai := arrA[A_Index] ? arrA[A_Index] : 0
        bi := arrB[A_Index] ? arrB[A_Index] : 0
        if (ai < bi)
            return -1
        else if (ai > bi)
            return 1
    }
    return 0
}

; ─────────────────────────────────────────────────────────────────────────
; [보조 함수] SplitStrByDot(str)
;  - "4.2.3.0" → [4,2,3,0] 배열로 변환
; ─────────────────────────────────────────────────────────────────────────
SplitStrByDot(str)
{
    arr := []
    parts := StrSplit(str, ".")
    for k, v in parts
        arr.Push(v+0)  ; 문자열 "4" → 정수 4
    return arr
}
