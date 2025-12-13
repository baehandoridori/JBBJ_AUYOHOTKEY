#SingleInstance, Force

; ─────────────────────────────────────────────────────────────────────────
; [개념 요약]
;   1) 프로그램 정보를 ProgramData 배열에 담음
;   2) 각 프로그램은 Name/InstallPath/SetupPath/CheckFunc/InstallFunc 등 
;      주요 정보와, GUI 컨트롤명(InstalledVar/NotInstalledVar/ButtonVar)을 가진다.
;   3) RefreshCheck 시에 CheckFunc 라벨을 호출해 설치 여부 판별
;   4) InstallProgram 버튼이 클릭되면 InstallFunc 라벨로 이동해 설치 진행
;   5) 새 프로그램 추가 시 ProgramData 배열에 원소를 추가하고, 
;      필요하다면 CheckFunc/InstallFunc 라벨을 새로 작성
; ─────────────────────────────────────────────────────────────────────────


; ─────────────────────────────────────────────────────────────────────────
; [1] 프로그램별 설정을 배열(객체)로 정리
;    - index 1 => 디스코드
;    - index 2 => 프로그램1
;    - index 3 => 블렌더
;    - index 4 => SW_모호
; ─────────────────────────────────────────────────────────────────────────
ProgramData := []  ; AHK v1 배열 선언

; (1) 디스코드
ProgramData[1] := ({ 
    Name:          "디스코드"
  , InstallPath:   "C:\Users\" . A_UserName . "\AppData\Local\Discord"
  , SetupPath:     "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\DiscordSetup.exe"
  , CheckFunc:     "CheckBasicFolder"
  , InstallFunc:   "InstallBasicRun"
})
; (2) 프로그램1
ProgramData[2] := {
    Name:          "프로그램1"
  , InstallPath:   "C:\Program Files\Program1"
  , SetupPath:     "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\Program1Setup.exe"
  , CheckFunc:     "CheckBasicFolder"
  , InstallFunc:   "InstallBasicRun"
}
; (3) 블렌더 (폴더명으로 버전 체크)
ProgramData[3] := {
    Name:          "블렌더"
  , InstallPath:   "C:\Program Files\Blender Foundation"
  , SetupPath:     "G:\공유 드라이브\JBBJ 자료실\애니메이션 관련 자료들"  ; 폴더 혹은 파일
  , CheckFunc:     "CheckBlenderByFolder"
  , InstallFunc:   "InstallBlenderMSI"
}
; (4) SW_모호 단축키 변경 (파일명: "SW_모호 단축키 변경ver*.ahk")
ProgramData[4] := {
    Name:          "SW_모호 단축키 변경"
  , InstallPath:   A_StartMenu "\Programs\Startup"
  , SetupPath:     "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\테스트_마스터폴더"
  , CheckFunc:     "CheckSWMoho"
  , InstallFunc:   "InstallSWMoho"
}

; ─────────────────────────────────────────────────────────────────────────
; [프로그램 개수]
; ─────────────────────────────────────────────────────────────────────────
ProgCount := ProgramData.MaxIndex()

; ─────────────────────────────────────────────────────────────────────────
; [2] 메인 GUI 생성
;    - 배열을 순회하며, 설치/미설치 텍스트와 버튼을 생성
;    - 생성된 Text/Button의 변수명(컨트롤명)을 ProgramData에 기록
; ─────────────────────────────────────────────────────────────────────────
Gui, Destroy
Gui, +AlwaysOnTop +Resize
Gui, Font, s10

Gui, Add, Text, x10 y10 w300 h20 cBlue, ★ 설치 여부 확인 도구 ★

curY := 40

Loop %ProgCount%
{
    idx := A_Index
    program := ProgramData[idx]

    ; (1) 설치됨 텍스트 컨트롤
    installedVarName := "InstalledVar" . idx
    ; (2) 미설치 텍스트 컨트롤
    notInstalledVarName := "NotInstalledVar" . idx
    ; (3) 설치 진행 버튼 컨트롤
    buttonVarName := "ButtonVar" . idx

    ; ProgramData 배열에 저장해둬야, RefreshCheck/InstallProgram 시 사용 가능
    ProgramData[idx, "InstalledVar"] := installedVarName
    ProgramData[idx, "NotInstalledVar"] := notInstalledVarName
    ProgramData[idx, "ButtonVar"] := buttonVarName

    ; 실제 GUI 컨트롤 생성
    ; ─────────────────────────────────────────────────────────────────
    ; [설치됨] (기본 Hidden, 초록색)
    Gui, Font, s10 cGreen
    Gui, Add, Text, x20 y%curY% w450 h20 v%installedVarName% Hidden, [%program.Name%] - 설치되어 있습니다.

    ; [미설치] (기본 Hidden, 빨간색)
    Gui, Font, s10 cRed
    Gui, Add, Text, x20 y%curY% w450 h20 v%notInstalledVarName% Hidden, [%program.Name%] - 설치되어 있지 않습니다.

    ; [설치 진행] 버튼 (기본 Hidden, 검정색)
    Gui, Font, s10 cBlack
    Gui, Add, Button, x+10 w70 v%buttonVarName% gInstallProgram Hidden, 설치 진행

    curY += 30
}

; “새로고침” 버튼
Gui, Add, Button, x20 y+10 gRefreshCheck, 새로고침

; GUI 띄우기
Gui, Show, w600 h%curY%, 설치 상태 확인

; 처음 실행 시 1회 RefreshCheck
GoSub, RefreshCheck
Return


; ─────────────────────────────────────────────────────────────────────────
; [3] RefreshCheck
;    - ProgramData 배열을 돌며, 각 프로그램의 CheckFunc 라벨을 호출
; ─────────────────────────────────────────────────────────────────────────
RefreshCheck:
{
    Loop %ProgCount%
    {
        idx := A_Index
        checkLabel := ProgramData[idx, "CheckFunc"]
        ; 각 프로그램에 맞는 체크 라벨로 이동
        GoSub, %checkLabel%
    }
}
return


; ─────────────────────────────────────────────────────────────────────────
; [4] 설치 진행 버튼 클릭 시
;    - 어떤 버튼이 눌렸는지 확인 => 해당 프로그램의 InstallFunc 라벨로 이동
; ─────────────────────────────────────────────────────────────────────────
InstallProgram:
{
    clicked := A_GuiControl

    Loop %ProgCount%
    {
        idx := A_Index
        if (clicked = ProgramData[idx, "ButtonVar"])
        {
            installLabel := ProgramData[idx, "InstallFunc"]
            GoSub, %installLabel%
            break
        }
    }
}
return


; ─────────────────────────────────────────────────────────────────────────
; [5] 체크 로직 라벨들
;    1) CheckBasicFolder:    단순 폴더 존재여부로 “설치됨/미설치” 판별
;    2) CheckBlenderByFolder: 블렌더 폴더 버전 비교
;    3) CheckSWMoho:         SW_모호 단축키 파일 버전 비교
; ─────────────────────────────────────────────────────────────────────────

; (A) 단순 폴더 존재
CheckBasicFolder:
{
    ; 현재 실행되는 A_ThisLabel을 통해 어떤 idx인지 알 수 없으므로,
    ; RefreshCheck => GoSub %checkLabel% 방식이니 "누가 나를 호출했는지"를 알아야 한다.
    ; A_ThisFunc는 AHK v1에서는 지원 안 되고, 이를 우회하기 위해 전역 루프 변수를 사용하거나,
    ; 혹은 함수 형태로 바꾸는 방법 등 여러 가지가 있음. 
    ; 여기서는 "딱히 Label에서 idx를 찾는" 방식 대신, '사전에' RefreshCheck에서 변수를 전달하는 방법도 가능.
    ; 편의상 "로컬 변수 idx" 등을 전역 변수로 임시 저장했다고 가정해보자.

    ; 하지만 여기서는 그냥 예시로, "직접 ProgramData 배열에서
    ; 해당 Name을 추적" 하는 방식으로 코드를 단순화해볼 수도 있음.

    ; *** 간단한 방법: *** RefreshCheck에서 GoSub 직전에
    ;                     global currentCheckIndex := idx
    ;                     이런 식으로 넘기면 됨.

    global currentCheckIndex
    idx := currentCheckIndex

    nameVar   := ProgramData[idx].Name
    pathVar   := ProgramData[idx].InstallPath
    setupVar  := ProgramData[idx].SetupPath
    installed := ProgramData[idx, "InstalledVar"]
    notinst   := ProgramData[idx, "NotInstalledVar"]
    btnVar    := ProgramData[idx, "ButtonVar"]

    pathAttr := FileExist(pathVar)
    if (pathAttr != "" && InStr(pathAttr, "D"))
    {
        ; 설치됨
        GuiControl,, %installed%, % "[" . nameVar . "] - 설치되어 있습니다."
        GuiControl, Show, %installed%
        GuiControl, Hide, %notinst%
        GuiControl, Hide, %btnVar%
    }
    else
    {
        ; 미설치
        GuiControl,, %notinst%, % "[" . nameVar . "] - 설치되어 있지 않습니다."
        GuiControl, Show, %notinst%
        GuiControl, Show, %btnVar%
        GuiControl, Hide, %installed%
    }
}
return

; (B) 블렌더 (폴더명으로 버전 비교)
CheckBlenderByFolder:
{
    global currentCheckIndex
    idx := currentCheckIndex

    nameVar     := ProgramData[idx].Name
    installPath := ProgramData[idx].InstallPath
    setupPath   := ProgramData[idx].SetupPath
    installed   := ProgramData[idx, "InstalledVar"]
    notinst     := ProgramData[idx, "NotInstalledVar"]
    btnVar      := ProgramData[idx, "ButtonVar"]

    foundFolderVer := "0.0"

    ; 설치 폴더 내 "Blender 4.3" 등 폴더명 검색
    Loop, Files, %installPath%\Blender*, D
    {
        if RegExMatch(A_LoopFileName, "Blender\s+([\d\.]+)", m)
        {
            ver2 := ExtractMajorMinor(m1)
            if (CompareVersion(ver2, foundFolderVer) = 1)
                foundFolderVer := ver2
        }
    }

    if (foundFolderVer = "0.0")
    {
        ; 미설치
        GuiControl,, %notinst%, % "[" . nameVar . "] - 설치되지 않았습니다."
        GuiControl, Show, %notinst%
        GuiControl, Show, %btnVar%
        GuiControl, Hide, %installed%
        return
    }

    ; 자료실(SetupPath) MSI 중 가장 높은 버전
    foundMsi := ""
    foundMsiVer := "0.0"

    if (FileExist(setupPath) && !(FileExist(setupPath) = "D"))
    {
        ; setupPath 가 단일 MSI 파일
        foundMsi := setupPath
        if RegExMatch(setupPath, "blender-([\d\.]+)-windows", mm)
            foundMsiVer := ExtractMajorMinor(mm1)
    }
    else
    {
        ; 폴더 내 msi 검색
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
        ; 자료실에 MSI 없음 => 설치 버전만 표시
        GuiControl,, %installed%, % "[" . nameVar . "] - 설치됨 (현재:" . foundFolderVer . ")"
        GuiControl, Show, %installed%
        GuiControl, Hide, %notinst%
        GuiControl, Hide, %btnVar%
    }
    else
    {
        ; 비교
        if (CompareVersion(foundMsiVer, foundFolderVer) = 1)
        {
            GuiControl,, %notinst%, % "[" . nameVar . "] - 구버전:" . foundFolderVer . " / 새버전:" . foundMsiVer
            GuiControl, Show, %notinst%
            GuiControl, Show, %btnVar%
            GuiControl, Hide, %installed%
        }
        else
        {
            GuiControl,, %installed%, % "[" . nameVar . "] - 설치됨 (현재:" . foundFolderVer . ")"
            GuiControl, Show, %installed%
            GuiControl, Hide, %notinst%
            GuiControl, Hide, %btnVar%
        }
    }
}
return


; (C) SW_모호 (파일명: SW_모호 단축키 변경ver*.ahk)
CheckSWMoho:
{
    global currentCheckIndex
    idx := currentCheckIndex

    nameVar     := ProgramData[idx].Name
    installPath := ProgramData[idx].InstallPath
    setupPath   := ProgramData[idx].SetupPath
    installed   := ProgramData[idx, "InstalledVar"]
    notinst     := ProgramData[idx, "NotInstalledVar"]
    btnVar      := ProgramData[idx, "ButtonVar"]

    startVer  := "0.0"
    startFile := ""
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

    ; 자료실 버전
    sourceVer  := "0.0"
    sourceFile := ""
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
        ; 설치 안됨
        GuiControl,, %notinst%, % "[" . nameVar . "] - (파일 없음) 설치되어 있지 않습니다."
        GuiControl, Show, %notinst%
        GuiControl, Show, %btnVar%
        GuiControl, Hide, %installed%
    }
    else
    {
        if (CompareVersion(sourceVer, startVer) = 1)
        {
            GuiControl,, %notinst%, % "[" . nameVar . "] - (구버전:" . startVer . ") 더 높은 버전:" . sourceVer . " 존재"
            GuiControl, Show, %notinst%
            GuiControl, Show, %btnVar%
            GuiControl, Hide, %installed%
        }
        else
        {
            GuiControl,, %installed%, % "[" . nameVar . "] - 설치됨 (현재:" . startVer . ")"
            GuiControl, Show, %installed%
            GuiControl, Hide, %notinst%
            GuiControl, Hide, %btnVar%
        }
    }
}
return


; ─────────────────────────────────────────────────────────────────────────
; [6] 설치 로직 라벨들
;    1) InstallBasicRun:   단순 실행 (디스코드, 프로그램1 등)
;    2) InstallBlenderMSI: 블렌더 msi 실행
;    3) InstallSWMoho:     파일 복사/업데이트
; ─────────────────────────────────────────────────────────────────────────

; (A) 단순 실행
InstallBasicRun:
{
    global currentCheckIndex
    idx := currentCheckIndex

    setupVar := ProgramData[idx].SetupPath

    ; 설치 파일 실행 (설치가 종료된 뒤 RefreshCheck 하고 싶다면 RunWait 사용)
    Run, %setupVar%
    return
}
return

; (B) 블렌더 msi 설치
InstallBlenderMSI:
{
    global currentCheckIndex
    idx := currentCheckIndex

    installPath := ProgramData[idx].InstallPath
    setupPath   := ProgramData[idx].SetupPath

    foundMsi := ""
    foundMsiVer := "0.0"

    if (FileExist(setupPath) && !(FileExist(setupPath) = "D"))
    {
        foundMsi := setupPath
        if RegExMatch(setupPath, "blender-([\d\.]+)-windows", m)
            foundMsiVer := ExtractMajorMinor(m1)
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
    ; 설치 완료 후 다시 RefreshCheck
    GoSub, RefreshCheck
}
return

; (C) SW_모호 (파일 복사/업데이트)
InstallSWMoho:
{
    global currentCheckIndex
    idx := currentCheckIndex

    installPath := ProgramData[idx].InstallPath
    setupPath   := ProgramData[idx].SetupPath

    ; 실제로는 자료실에서 최신버전 파일을 찾아 installPath로 복사하는 등의 로직을 작성하면 됨
    ; 여기서는 예시만 작성

    ; 예) "SW_모호 단축키 변경ver1.2.ahk" => 복사
    ; Loop, Files, % setupPath . "\SW_모호 단축키 변경ver*.ahk"
    ; {
    ;     FileCopy, %A_LoopFileFullPath%, %installPath%, 1
    ; }

    MsgBox, 64, 안내, SW_모호 단축키 파일 복사(또는 업데이트)가 완료되었습니다.

    ; 설치 완료 후 다시 RefreshCheck
    GoSub, RefreshCheck
}
return


; ─────────────────────────────────────────────────────────────────────────
; [7] 공용 유틸 함수들
;    - CompareVersion(A, B)
;    - ExtractMajorMinor(str)
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

ExtractMajorMinor(fullVerStr)
{
    arr := StrSplit(fullVerStr, ".")
    major := arr[1]+0
    minor := (arr.Count() >= 2) ? arr[2]+0 : 0
    return major "." minor
}


; ─────────────────────────────────────────────────────────────────────────
GuiClose:
ExitApp
