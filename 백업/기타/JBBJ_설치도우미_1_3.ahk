#SingleInstance, Force

; =============================================================================
; 프로그램 설치 상태 및 원클릭 설치 도구
; =============================================================================
; 이 스크립트는 여러 프로그램의 설치 여부를 확인하고, 미설치(또는 구버전)
; 상태일 경우 원클릭 설치 기능을 제공합니다.
;
; ★ 유지보수를 쉽게 하기 위한 설계 포인트 ★
;   1) **객체 배열**(*Programs*)을 사용해 프로그램 정보를 한데 묶어서 관리합니다.
;   2) 각 프로그램별로 **체크 함수(설치 여부 확인 로직)**와 **설치 함수**를 연결하여,
;      프로그램을 쉽게 추가하거나 순서를 변경할 수 있습니다.
;   3) **프로그램 추가** 시에는 배열에 새 **객체**(오브젝트)를 만들어 **Push**해주기만 하면 됩니다.
;   4) **프로그램 순서 변경** 시에는 객체를 Push하는 순서를 바꾸거나, 배열에서의 위치만 바꿔주면 됩니다.
;
; (사용 환경: AutoHotkey v1.x)
; =============================================================================



; -----------------------------------------------------------------------------
; ★ [프로그램 추가/수정/삭제/순서변경 방법] 요약 ★
; -----------------------------------------------------------------------------
; 1) "Programs" 배열에 있는 각 'Push' 부분이 프로그램 하나를 의미합니다.
;    - 예) discordObj, prog1Obj, blenderObj 등
; 2) "이름Obj := {}"로 객체를 만들고,
;    -   객체["Name"] := "프로그램이름"
;    -   객체["InstallPath"] := "..."
;    -   객체["SetupPath"] := "..."
;    -   객체["CheckFunc"] := Func("...")
;    -   객체["InstallFunc"] := Func("...")
;    로 값을 넣습니다.
; 3) 만든 객체를 Programs.Push(이름Obj)로 '배열'에 집어넣습니다.
; 4) "프로그램 순서 변경"은, Push 순서만 바꾸면 됩니다.
;    - 배열은 푸시된 순서대로 GUI에 나열되므로, 
;      디스코드를 가장 마지막에 보이게 하려면 해당 Push를 맨 뒤로 옮기면 됩니다.
; 5) "특수 로직"이 필요하다면, CheckFunc/InstallFunc에 새 함수(예: MyCheckFunc, MyInstallFunc)를 
;    만들어 등록하고, 그 로직을 새 함수에 작성하세요.
; -----------------------------------------------------------------------------
; 
; 예) "새 프로그램"을 추가하고 싶다면?
;   newObj := {}
;   newObj["Name"] := "새 프로그램"
;   newObj["InstallPath"] := "C:\\Program Files\\MyApp"
;   newObj["SetupPath"]   := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\MyAppSetup.exe"
;   newObj["CheckFunc"]   := Func("DefaultCheck")   ; 혹은 자신만의 함수
;   newObj["InstallFunc"] := Func("DefaultInstall") ; 혹은 자신만의 함수
;   Programs.Push(newObj)
; 
;  이렇게 한 블록을 추가하면 끝!
;   일반적으로는 CheckFunc에 DefaultCheck를, InstallFunc에 DefaultInstall을 추가하면 됨.
; -----------------------------------------------------------------------------





; [0] "카테고리" 목록 정의 (탭으로 표시할 카테고리들)
; [0] "카테고리" 목록 정의 (탭으로 표시할 카테고리들)
categoriesArray := ["최우선설치프로그램", "제작도구", "커뮤니케이션", "작업효율", "유틸리티"]  ; 대괄호 제거됨
MsgBox, % "카테고리 배열 크기: " . categoriesArray.Length()
for index, category in categoriesArray
{
    MsgBox, % "카테고리 " . index . ": " . category
}

; [1] 프로그램 등록 (Programs 배열 구성)
Programs := []

; ┌─────────────────────────────────────────────────────────────────────┐
; │ 예시: 구글 드라이브 (최우선 설치 프로그램, 유틸리티)               │
; └─────────────────────────────────────────────────────────────────────┘
googledriveObj := {}
googledriveObj["Name"] := "구글 드라이브"
googledriveObj["InstallPath"] := "C:\\Program Files\\Google\\Drive File Stream"
googledriveObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\GoogleDriveSetup.exe"
googledriveObj["CheckFunc"] := Func("DefaultCheck")
googledriveObj["InstallFunc"] := Func("DefaultInstall")
googledriveObj["Categories"] := [categoriesArray[1], categoriesArray[5]]  ; 배열에서 직접 가져오기
Programs.Push(googledriveObj)

MsgBox, % "Programs 배열 초기 크기: " . Programs.Length()

; (이하 동일... 슬랙, 디스코드, 모호, 블렌더, etc. 전부 등록)
; ...
; (중략)

global gPrograms := Programs
MsgBox, % "gPrograms 배열 크기: " . gPrograms.Length()

; =============================================================================
; [2-A] 탭 기반 GUI 생성: BuildGuiWithTabs()
; =============================================================================

BuildGuiWithTabs()
{
    global

    Gui, Destroy
    Gui, +Resize
    Gui, Font, s10

    tabStr := ""
    Loop, % categoriesArray.Length()
    {
        if (A_Index > 1)
            tabStr .= "|"
        tabStr .= categoriesArray[A_Index]
    }

    Gui, Add, Tab, x10 y10 w600 h400 vMyTab, %tabStr%

    Loop, % categoriesArray.Length()
    {
        currentCat := categoriesArray[A_Index]
        Gui, Tab, %A_Index%
        
        Gui, Add, Text, x20 y50, % "현재 탭: " . currentCat

        curY := 80

        for progIndex, prog in gPrograms
        {
            ; 프로그램의 카테고리가 배열인지 확인
            if IsObject(prog.Categories)
            {
                ; 배열을 순회하며 현재 카테고리와 일치하는지 확인
                for _, progCategory in prog.Categories
                {
                    if (progCategory == currentCat)
                    {
                        textCtrlName := "Text" . progIndex . "_" . A_Index
                        btnCtrlName := "Btn" . progIndex . "_" . A_Index

                        Gui, Add, Text, x20 y%curY% w450 v%textCtrlName%, % "[" . prog.Name . "]"
                        Gui, Add, Button, x+10 w70 v%btnCtrlName% gInstallProgram, 설치 진행
                        
                        curY += 30
                        break
                    }
                }
            }
            else if (prog.Categories == currentCat)  ; 단일 카테고리인 경우 기존 방식대로 처리
            {
                textCtrlName := "Text" . progIndex . "_" . A_Index
                btnCtrlName := "Btn" . progIndex . "_" . A_Index

                Gui, Add, Text, x20 y%curY% w450 v%textCtrlName%, % "[" . prog.Name . "]"
                Gui, Add, Button, x+10 w70 v%btnCtrlName% gInstallProgram, 설치 진행
                
                curY += 30
            }
        }
    }

    Gui, Tab
    Gui, Add, Button, x20 y420 gRefreshCheck, 새로고침
    Gui, Show, w640 h450, 탭 기반 설치 상태 확인

    RefreshCheck()
}
; [2-B] 메인 GUI 실행
BuildGuiWithTabs()
return


; =============================================================================
; [3] 상태 체크 함수들
; =============================================================================

RefreshCheck()
{
    global gPrograms
    for index, prog in gPrograms
    {
        prog.CheckFunc.Call(index, prog)
    }
}

; ---------------------------------------------------------------------------
; DefaultCheck(index, prog)
;   - 폴더가 있는지 확인하여 '설치됨' 또는 '미설치' 표시
; ---------------------------------------------------------------------------
DefaultCheck(index, prog)
{
    if (FileExist(prog.InstallPath) && InStr(FileExist(prog.InstallPath), "D"))
    {
        text := "[" . prog.Name . "] - 설치되어 있습니다."
        ShowProgramAsInstalledOrNot(prog, text, showButton := false)
    }
    else
    {
        text := "[" . prog.Name . "] - 설치되어 있지 않습니다."
        ShowProgramAsInstalledOrNot(prog, text, true)
    }
}

; ---------------------------------------------------------------------------
; CheckBlenderByFolder(index, prog)
;   - 블렌더 설치 폴더 버전 vs MSI 버전을 비교
;   - local 변수 선언을 2줄로 분리 (AHK v1 문법)
; ---------------------------------------------------------------------------
CheckBlenderByFolder(index, prog)
{
    local foundFolderVer
    foundFolderVer := "0.0"

    Loop, Files, % prog.InstallPath . "\Blender*", D
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
        text := "[" . prog.Name . "] - 설치되지 않았습니다."
        ShowProgramAsInstalledOrNot(prog, text, true)
        return
    }

    local foundMsi, foundMsiVer
    foundMsi := ""
    foundMsiVer := "0.0"

    if (FileExist(prog.SetupPath) && !(FileExist(prog.SetupPath) = "D"))
    {
        foundMsi := prog.SetupPath
        if RegExMatch(prog.SetupPath, "blender-([\d\.]+)-windows", x)
            foundMsiVer := ExtractMajorMinor(x1)
    }
    else
    {
        local patternMsi
        patternMsi := prog.SetupPath . "\blender-*.msi"

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
        text := "[" . prog.Name . "] - 설치됨 (현재:" . foundFolderVer . ")"
        ShowProgramAsInstalledOrNot(prog, text, false)
    }
    else
    {
        if (CompareVersion(foundMsiVer, foundFolderVer) = 1)
        {
            text := "[" . prog.Name . "] - 구버전:" . foundFolderVer . " / 새버전:" . foundMsiVer
            ShowProgramAsInstalledOrNot(prog, text, true)
        }
        else
        {
            text := "[" . prog.Name . "] - 설치됨 (현재:" . foundFolderVer . ")"
            ShowProgramAsInstalledOrNot(prog, text, false)
        }
    }
}

; ---------------------------------------------------------------------------
; CheckMohoVersion(index, prog)
;   - 모호 exe 버전 vs 설치 파일 버전 비교
; ---------------------------------------------------------------------------
CheckMohoVersion(index, prog)
{
    exePath := prog.InstallPath . "\Moho.exe"
    if !FileExist(exePath)
    {
        text := "[" . prog.Name . "] - 설치되어 있지 않습니다."
        ShowProgramAsInstalledOrNot(prog, text, true)
        return
    }

    FileGetVersion, mohoExeVersion, %exePath%
    installedVer := ExtractMajorMinor(mohoExeVersion)

    patternMoho := prog.SetupPath . "\Moho*.exe"

    
    latestSetupFile := ""
    latestSetupVer  := "0.0"

    Loop, Files, %patternMoho%
    {
        if RegExMatch(A_LoopFileName, "Moho(\d+)(\d+)0_Win", m)
        {
            major := m1
            minor := m2
            setupVer := major "." minor
            if (CompareVersion(setupVer, latestSetupVer) = 1)
            {
                latestSetupVer := setupVer
                latestSetupFile := A_LoopFileFullPath
            }
        }
    }

    if (latestSetupFile = "")
    {
        text := "[" . prog.Name . "] - 설치됨 (현재:" . installedVer . ")"
        ShowProgramAsInstalledOrNot(prog, text, false)
        return
    }

    if (CompareVersion(latestSetupVer, installedVer) = 1)
    {
        text := "[" . prog.Name . "] - (구버전:" . installedVer . ") 새버전:" . latestSetupVer
        ShowProgramAsInstalledOrNot(prog, text, true)
    }
    else
    {
        text := "[" . prog.Name . "] - 설치됨 (현재:" . installedVer . ")"
        ShowProgramAsInstalledOrNot(prog, text, false)
    }
}

; ---------------------------------------------------------------------------
; CheckSWMoho(index, prog)
;   - SW_모호 단축키 변경 파일 버전 비교
; ---------------------------------------------------------------------------
CheckSWMoho(index, prog)
{
    local patternStart
    patternStart := prog.InstallPath . "\SW_모호 단축키 변경ver*.ahk"

    local startVer
    startVer := "0.0"

    Loop, Files, %patternStart%
    {
        RegExMatch(A_LoopFileName, "ver([\d_]+)\.ahk", m)
        if (m1 != "")
        {
            tmpVer := RegExReplace(m1, "_", ".")
            if (CompareVersion(tmpVer, startVer) = 1)
                startVer := tmpVer
        }
    }

    local patternSource
    patternSource := prog.SetupPath . "\SW_모호 단축키 변경ver*.ahk"

    local sourceVer
    sourceVer := "0.0"

    Loop, Files, %patternSource%
    {
        RegExMatch(A_LoopFileName, "ver([\d_]+)\.ahk", m)
        if (m1 != "")
        {
            tmpVer := RegExReplace(m1, "_", ".")
            if (CompareVersion(tmpVer, sourceVer) = 1)
                sourceVer := tmpVer
        }
    }

    if (startVer = "0.0")
    {
        text := "[" . prog.Name . "] - (파일 없음) 설치되어 있지 않습니다."
        ShowProgramAsInstalledOrNot(prog, text, true)
    }
    else
    {
        if (CompareVersion(sourceVer, startVer) = 1)
        {
            text := "[" . prog.Name . "] - (구버전:" . startVer . ") 더 높은 버전:" . sourceVer . " 존재"
            ShowProgramAsInstalledOrNot(prog, text, true)
        }
        else
        {
            text := "[" . prog.Name . "] - 설치됨 (현재:" . startVer . ")"
            ShowProgramAsInstalledOrNot(prog, text, false)
        }
    }
}


; =============================================================================
; [4] 설치(Install) 관련 함수
; =============================================================================

; ---------------------------------------------------------------------------
; InstallProgram:
;   - 설치 진행 버튼을 클릭하면 어떤 프로그램이 눌렸는지 확인 후,
;     prog.InstallFunc 함수를 호출
; ---------------------------------------------------------------------------
InstallProgram:
{
    global gPrograms
    clickedBtn := A_GuiControl

    ; 탭/카테고리 관계없이, 어떤 program의 buttonCtrl와 일치하는지 검색
    for index, prog in gPrograms
    {
        if !IsObject(prog.guiControls)
            continue

        for eachCat, ctrlSet in prog.guiControls
        {
            if (clickedBtn = ctrlSet.buttonCtrl)
            {
                prog.InstallFunc.Call(index, prog)
                return
            }
        }
    }
}
Return

; ---------------------------------------------------------------------------
; DefaultInstall(index, prog)
;   - 설치 파일을 단순 Run (혹은 RunWait) 하는 기본 로직
; ---------------------------------------------------------------------------
DefaultInstall(index, prog)
{
    Run, % prog.SetupPath
    ; 설치 완료 후 자동 새로고침:
    ; RunWait, % prog.SetupPath
    ; RefreshCheck()
}

; ---------------------------------------------------------------------------
; InstallBlender(index, prog)
;   - 블렌더 MSI 실행 후 RefreshCheck
; ---------------------------------------------------------------------------
InstallBlender(index, prog)
{
    local foundMsi, foundMsiVer
    foundMsi := ""
    foundMsiVer := "0.0"

    if (FileExist(prog.SetupPath) && !(FileExist(prog.SetupPath) = "D"))
    {
        foundMsi := prog.SetupPath
        if RegExMatch(prog.SetupPath, "blender-([\d\.]+)-windows", m)
            foundMsiVer := ExtractMajorMinor(m1)
    }
    else
    {
        local patternMsi
        patternMsi := prog.SetupPath . "\blender-*.msi"

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
    RefreshCheck()
}

; ---------------------------------------------------------------------------
; InstallSWMoho(index, prog)
;   - SW_모호 단축키 변경 파일 복사/업데이트 로직
; ---------------------------------------------------------------------------
InstallSWMoho(index, prog)
{
    local patternInstalled
    patternInstalled := prog.InstallPath . "\SW_모호 단축키 변경ver*.ahk"

    Loop, Files, %patternInstalled%
    {
        FileDelete, %A_LoopFileFullPath%
    }

    local patternMaster
    patternMaster := prog.SetupPath . "\SW_모호 단축키 변경ver*.ahk"

    local bestFile, bestVer
    bestFile := ""
    bestVer  := "0.0"

    Loop, Files, %patternMaster%
    {
        RegExMatch(A_LoopFileName, "ver([\d_]+)\.ahk", m)
        if (m1 != "")
        {
            tmpVer := RegExReplace(m1, "_", ".")
            if (CompareVersion(tmpVer, bestVer) = 1)
            {
                bestVer  := tmpVer
                bestFile := A_LoopFileFullPath
            }
        }
    }

    if (bestFile = "")
    {
        MsgBox, 48, 오류, 최신 버전의 SW_모호 단축키 변경 파일을 찾지 못했습니다.
        return
    }

    destPath := prog.InstallPath
    FileCopy, %bestFile%, %destPath%, 1

    MsgBox, 64, 안내, SW_모호 단축키 변경 설치(업데이트)가 완료되었습니다.
    RefreshCheck()
}


; =============================================================================
; [5] GUI 종료 처리
; =============================================================================
GuiClose:
    ExitApp


; =============================================================================
; [6] 보조 함수들 (버전 비교, ShowProgramAsInstalledOrNot, 버전 문자열 가공)
; =============================================================================

; CompareVersion(a, b)
;   - 버전 문자열(예: "4.2.1")을 . 기준으로 분할 후 숫자 비교
CompareVersion(a, b)
{
    arrA := StrSplit(a, ".")
    arrB := StrSplit(b, ".")
    maxLen := (arrA.MaxIndex() > arrB.MaxIndex()) ? arrA.MaxIndex() : arrB.MaxIndex()

    Loop, %maxLen%
    {
        ai := (arrA[A_Index] = "") ? 0 : arrA[A_Index] + 0
        bi := (arrB[A_Index] = "") ? 0 : arrB[A_Index] + 0
        if (ai < bi)
            return -1
        else if (ai > bi)
            return 1
    }
    return 0
}

; ★ "설치됨" / "미설치" / "구버전" 등을 여러 탭에 중복 표시
ShowProgramAsInstalledOrNot(prog, text, showButton := false)
{
    if !IsObject(prog.guiControls)
        return

    MsgBox, % "ShowProgramAsInstalledOrNot 호출됨:`n프로그램: " . prog.Name . "`n텍스트: " . text . "`n버튼표시: " . showButton

    for eachCat, ctrlSet in prog.guiControls
    {
        installedCtrlName    := ctrlSet.installedCtrl
        notInstalledCtrlName := ctrlSet.notInstalledCtrl
        buttonCtrlName       := ctrlSet.buttonCtrl

        if showButton
        {
            GuiControl,, %notInstalledCtrlName%, % text
            GuiControl, Show, %notInstalledCtrlName%
            GuiControl, Show, %buttonCtrlName%
            GuiControl, Hide, %installedCtrlName%
        }
        else
        {
            GuiControl,, %installedCtrlName%, % text
            GuiControl, Show, %installedCtrlName%
            GuiControl, Hide, %notInstalledCtrlName%
            GuiControl, Hide, %buttonCtrlName%
        }
    }
}

; ExtractMajorMinor(fullVerStr)
;   - 예: "4.10.3" -> "4.10"
ExtractMajorMinor(fullVerStr)
{
    arr := StrSplit(fullVerStr, ".")
    major := arr[1] + 0
    minor := (arr.MaxIndex() >= 2) ? arr[2] + 0 : 0
    return major "." minor
}
