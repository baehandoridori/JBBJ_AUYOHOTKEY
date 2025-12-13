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


; =============================================================================
; [0] "카테고리" 목록 정의
;     - 원하는 순서와 이름대로 설정하세요.
; =============================================================================
categoriesArray := ["최우선 설치 프로그램", "제작 도구", "커뮤니케이션", "작업 효율", "유틸리티"]


; -----------------------------------------------------------------------------
; [1] 프로그램 등록 (Programs 배열 구성)
;    - 신규 프로그램을 추가하거나, 순서를 바꾸고 싶다면 이 부분만 수정하면 됩니다.
; -----------------------------------------------------------------------------

; 1) 전역 배열 Programs를 만듭니다. (각 프로그램마다 '객체'를 Push 해줄 예정)
Programs := []



; 구글 드라이브

googledriveObj := {}
googledriveObj["Name"] := "구글 드라이브"
googledriveObj["InstallPath"] := "C:\\Program Files\\Google\\Drive File Stream"
googledriveObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\GoogleDriveSetup.exe"
googledriveObj["CheckFunc"] :=  Func("DefaultCheck")
googledriveObj["InstallFunc"] :=  Func("DefaultInstall")
googledriveObj["Categories"] := "최우선 설치 프로그램,유틸리티"
Programs.Push(googledriveObj)


; 슬랙
slackObj := {}
slackObj["Name"] := "슬랙"
slackObj["installPath"] := "C:\\Users\\" . A_UserName . "\\AppData\\Local\\slack"
slackObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\SlackSetup.exe"
slackObj["CheckFunc"] := Func("DefaultCheck")
slackObj["InstallFunc"] := Func("Defaultinstall")
programs.Push(slackObj)

; ┌─────────────────────────────────────────────────────────────────────┐
; │  A. "디스코드" 항목 등록                                             │
; └─────────────────────────────────────────────────────────────────────┘
discordObj := {}
discordObj["Name"] := "디스코드"
discordObj["InstallPath"] := "C:\\Users\\" . A_UserName . "\\AppData\\Local\\Discord"
discordObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\DiscordSetup.exe"
discordObj["CheckFunc"] := Func("DefaultCheck")   ; 설치 여부 확인 => DefaultCheck 함수 사용
discordObj["InstallFunc"] := Func("DefaultInstall") ; 설치 진행 => DefaultInstall 함수 사용
Programs.Push(discordObj)

; 카톡
kakaotalkObj := {}
kakaotalkObj["Name"] := "카톡"
kakaotalkObj["InstallPath"] := "C:\\Program Files (x86)\\Kakao"
kakaotalkObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\KakaoTalk_Setup.exe"
kakaotalkObj["CheckFunc"] :=  Func("DefaultCheck")
kakaotalkObj["InstallFunc"] :=  Func("DefaultInstall")
programs.Push(kakaotalkObj)


; 모호
mohoObj := {}
mohoObj["Name"] := "모호14"
mohoObj["InstallPath"] := "C:\\Program Files\\Moho 14"
mohoObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\애니메이션 관련 자료들"
mohoObj["CheckFunc"] :=  Func("CheckMohoVersion")  ; ★ 함수 교체!
mohoObj["InstallFunc"] :=  Func("DefaultInstall")
programs.Push(mohoObj)


; ┌─────────────────────────────────────────────────────────────────────┐
; │  C. "블렌더" 항목 등록                                             │
; └─────────────────────────────────────────────────────────────────────┘
blenderObj := {}
blenderObj["Name"] := "블렌더"
blenderObj["InstallPath"] := "C:\\Program Files\\Blender Foundation"
blenderObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\애니메이션 관련 자료들\\blender-4.2.3-windows-x64.msi"
blenderObj["CheckFunc"] := Func("CheckBlenderByFolder")
blenderObj["InstallFunc"] := Func("InstallBlender")
Programs.Push(blenderObj)

; 어도비 크리에이트 클라우드
AdobeCloudObj := {}
AdobeCloudObj["Name"] := "어도비 크리에이트 클라우드"
AdobeCloudObj["InstallPath"] := "C:\\Program Files\\Adobe\\Adobe Creative Cloud"
AdobeCloudObj["SetupPath"] := "https://www.adobe.com/kr/creativecloud.html?gclid=CjwKCAiA74G9BhAEEiwA8kNfpagkbelAWU7vjHorRym7-_6DfY8yG9TGt3zsUDqfNgbMfBtdqoTupBoCcGUQAvD_BwE&sdid=DHWC19Q8&mv=search&mv2=paidsearch&ef_id=CjwKCAiA74G9BhAEEiwA8kNfpagkbelAWU7vjHorRym7-_6DfY8yG9TGt3zsUDqfNgbMfBtdqoTupBoCcGUQAvD_BwE:G:s&s_kwcid=AL!3085!3!589558741352!e!!g!!%EC%96%B4%EB%8F%84%EB%B9%84%20%ED%81%AC%EB%A6%AC%EC%97%90%EC%9D%B4%ED%8B%B0%EB%B8%8C%20%ED%81%B4%EB%9D%BC%EC%9A%B0%EB%93%9C!1559096857!64669119332&gad_source=1"
AdobeCloudObj["CheckFunc"] :=  Func("DefaultCheck")
AdobeCloudObj["InstallFunc"] :=  Func("DefaultInstall")
Programs.Push(AdobeCloudObj)


;애니메이트

;AnObj


;프리미어

;PrObj


;에프터이펙트

;AEObj


;미디어인코더

;MeObj


;포토샵
;PhObj


;오토핫키 1

Ahk1Obj := {}
Ahk1Obj["Name"] := "오토핫키v1"
Ahk1Obj["InstallPath"] := "C:\\Program Files\\AutoHotkey\\v1.1.37.02"
Ahk1Obj["SetupPath"] := "G:\공유 드라이브\JBBJ 자료실\애니메이션 관련 자료들\편리한 단축키 추가 사용 오토핫키\AutoHotkey_1.1.37.02_setup.exe"
Ahk1Obj["CheckFunc"] :=  Func("DefaultCheck")
Ahk1Obj["InstallFunc"] :=  Func("DefaultInstall")
Ahk1Obj["Categories"] := "최우선 설치 프로그램,유틸리티"
programs.Push(Ahk1Obj)

;오토핫키 2

Ahk2Obj := {}
Ahk2Obj["Name"] := "오토핫키v2"
Ahk2Obj["InstallPath"] := "C:\\Program Files\\utoHotkey\\v2"
Ahk2Obj["SetupPath"] := "G:\공유 드라이브\JBBJ 자료실\애니메이션 관련 자료들\편리한 단축키 추가 사용 오토핫키\AutoHotkey_2.0.10_setup.exe"
Ahk2Obj["CheckFunc"] :=  Func("DefaultCheck")
Ahk2Obj["InstallFunc"] :=  Func("DefaultInstall")
Ahk2Obj["Categories"] := "최우선 설치 프로그램,유틸리티"
programs.Push(Ahk2Obj)

; 구글 크롬

ChromeObj := {}
ChromeObj["Name"] := "구글 크롬"
ChromeObj["installpath"] := "C:\\Program Files\\Google\\Chrome"
ChromeObj["setuppath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\ChromeSetup.exe"
ChromeObj["Checkfunc"] :=  Func("DefaultCheck")
ChromeObj["Installfunc"] :=  Func("DefaultInstall")
ChromeObj["Categories"] := "유틸리티"
programs.Push(ChromeObj)

;지포스 익스피리언스


;파섹

parsecObj := {}
parsecObj["Name"] := "파섹"
parsecObj["installPath"] := "C:\\Program Files\\Parsec"
parsecObj["setuppath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\parsec-windows.exe"
parsecObj["CheckFunc"] :=  Func("DefaultCheck")
parsecObj["InstallFunc"] :=  Func("DefaultInstall")
parsecObj["Categories"] := "유틸리티"
Programs.Push(parsecObj)

; 팟플레이어

potplayer64Obj := {}
potplayer64Obj["Name"] := "팟플레이어"
potplayer64Obj["installPath"] := "C:\\Program Files (x86)\\DAUM\\PotPlayer"
potplayer64Obj["setuppath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\PotPlayerSetup64.exe"
potplayer64Obj["CheckFunc"] :=  Func("DefaultCheck")
potplayer64Obj["InstallFunc"] :=  Func("DefaultInstall")
potplayer64Obj["Categories"] := "유틸리티"
Programs.Push(potplayer64Obj)


; 리스터리
ListaryObj := {}
ListaryObj["Name"] := "Listary(Pro 버전은 따로 문의)"
ListaryObj["installpath"] := "C:\Program Files\Listary"
ListaryObj["setuppath"] := "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\Listary.exe"
ListaryObj["CheckFunc"] :=  Func("DefaultCheck")
ListaryObj["InstallFunc"]  :=  Func("DefaultInstall")
ListaryObj["Categories"] := "유틸리티"
Programs.Push(ListaryObj)

;인존허브

inzonehubObj := {}
inzonehubObj["Name"] := "인존허브(무선 이어폰 유틸리티)"
inzonehubObj["installpath"] := "C:\Program Files\Sony\INZONE Hub"
inzonehubObj["setuppath"] := "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\INZONEHub_Setup_1.0.13.0.exe"
inzonehubObj["CheckFunc"] :=  Func("DefaultCheck")
inzonehubObj["InstallFunc"]  :=  Func("DefaultInstall")
inzonehubObj["Categories"] := "유틸리티"
programs.Push(inzonehubObj)


;로지옵션+
logiObj["Name"] := "로지옵션+"
logiObj["installpath"] := "C:\Program Files\LogiOptionsPlus"
logiObj["setuppath"] := "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\logioptionsplus_installer.exe"
logiObj["CheckFunc"] :=  Func("DefaultCheck")
logiObj["InstallFunc"]  :=  Func("DefaultInstall")
logiObj["Categories"] := "유틸리티"
Programs.Push(logiObj)


; ┌─────────────────────────────────────────────────────────────────────┐
; │  D. "SW_모호 단축키 변경" 항목 등록                                 │
; └─────────────────────────────────────────────────────────────────────┘
swMohoObj := {}
swMohoObj["Name"] := "SW_모호 단축키 변경"
swMohoObj["InstallPath"] := A_StartMenu "\Programs\Startup"
swMohoObj["SetupPath"] := "G:\\공유 드라이브\\개인작업일지 모음\\개인작업일지_배한솔\\테스트_마스터폴더"
swMohoObj["CheckFunc"] := Func("CheckSWMoho")
swMohoObj["InstallFunc"] := Func("InstallSWMoho")
Programs.Push(swMohoObj)



; ┌─────────────────────────────────────────────────────────────────────┐
; │  B. "프로그램1" 항목 등록                                          │
; └─────────────────────────────────────────────────────────────────────┘
prog1Obj := {}
prog1Obj["Name"] := "프로그램1"
prog1Obj["InstallPath"] := "C:\\Program Files\\Program1"
prog1Obj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\Program1Setup.exe"
prog1Obj["CheckFunc"] := Func("DefaultCheck")
prog1Obj["InstallFunc"] := Func("DefaultInstall")
Programs.Push(prog1Obj)






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

; 전역 변수로 관리 (아래 함수들에서 참조할 수 있도록)
global gPrograms := Programs



; =============================================================================
; [2-A] 탭 기반 GUI 생성: BuildGuiWithTabs()
; =============================================================================
BuildGuiWithTabs()
{
    global gPrograms, categoriesArray

    Gui, Destroy
    Gui, +Resize
    Gui, Font, s10

    ; 탭 컨트롤 생성 (변수명 vMainTab 제거 → 오류 방지)
    categoriesStr := JoinCategoriesWithBar(categoriesArray)
    Gui, Add, Tab2, x10 y10 w600 h400, %categoriesStr%

    catIndex := 0
    for eachCat in categoriesArray
    {
        catIndex++
        Gui, Tab, % eachCat
        curY := 50

        for index, prog in gPrograms
        {
            ; 카테고리 매칭
            if !prog.HasKey("Categories")
                continue
            if !InStr(prog["Categories"], eachCat)
                continue

            if !IsObject(prog.guiControls)
                prog.guiControls := {}
            if !IsObject(prog.guiControls[eachCat])
                prog.guiControls[eachCat] := {}

            installedCtrlName    := "installedVar" . index . "_" . catIndex
            notInstalledCtrlName := "notInstalledVar" . index . "_" . catIndex
            buttonCtrlName       := "buttonVar"     . index . "_" . catIndex

            prog.guiControls[eachCat].installedCtrl    := installedCtrlName
            prog.guiControls[eachCat].notInstalledCtrl := notInstalledCtrlName
            prog.guiControls[eachCat].buttonCtrl       := buttonCtrlName

            Gui, Font, s10 cGreen
            Gui, Add, Text, x20 y%curY% w450 h20 v%installedCtrlName% Hidden,
            Gui, Font, s10 cRed
            Gui, Add, Text, x20 y%curY% w450 h20 v%notInstalledCtrlName% Hidden,
            Gui, Font, s10 cBlack
            Gui, Add, Button, x+10 w70 v%buttonCtrlName% gInstallProgram Hidden, 설치 진행

            curY += 30
        }
    }

    Gui, Tab  ; 탭 해제
    Gui, Add, Button, x20 y+10 gRefreshCheck, 새로고침
    Gui, Show, w640 h450, 탭 기반 설치 상태 확인

    ; 최초 1회 체크
    RefreshCheck()
}


; 보조함수: 카테고리 배열 -> 탭 문자열
JoinCategoriesWithBar(arr)
{
    local result := ""
    for i, val in arr
    {
        if (i > 1)
            result .= "|"
        result .= val
    }
    return result
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
        ; - 각 객체의 CheckFunc에 담긴 함수를 호출
        ; - Call(인덱스, 프로그램객체) 형태로 파라미터를 전달
        prog.CheckFunc.Call(index, prog)
    }
}


; -------------------------------
; DefaultCheck(index, prog)
; -------------------------------
; [용도] 폴더가 있는지만 확인하는 간단한 로직
; [추가 설명]
;   - prog.InstallPath가 실제 폴더로 존재하면 '설치됨'으로 처리
;   - 아니면 '미설치'로 처리
; -------------------------------
DefaultCheck(index, prog)
{
    if (FileExist(prog.InstallPath) && InStr(FileExist(prog.InstallPath), "D"))
    {
        text := "[" . prog.Name . "] - 설치되어 있습니다."
        ShowProgramAsInstalledOrNot(prog, text, false)  ; 설치됨 => 버튼 숨김
    }
    else
    {
        text := "[" . prog.Name . "] - 설치되어 있지 않습니다."
        ShowProgramAsInstalledOrNot(prog, text, true)   ; 미설치 => 버튼 노출
    }
}

; -------------------------------
; CheckSWMoho(index, prog)
; -------------------------------
; [용도] SW_모호 단축키 변경의 버전 체크
;        (파일명 "SW_모호 단축키 변경ver*.ahk"에서 버전 추출)
; -------------------------------
CheckSWMoho(index, prog)
{
    local installedCtrl    := prog.installedControl
    local notInstalledCtrl := prog.notInstalledControl
    local buttonCtrl       := prog.buttonControl

    local patternStart := prog.InstallPath . "\SW_모호 단축키 변경ver*.ahk"
    local startVer := "0.0"
    local startFile := ""

    Loop, Files, %patternStart%
    {
        RegExMatch(A_LoopFileName, "ver([\d_]+)\.ahk", m)
        if (m1 != "")
        {
            tmpVer := RegExReplace(m1, "_", ".")
            if (CompareVersion(tmpVer, startVer) = 1)
            {
                startVer := tmpVer
                startFile := A_LoopFileFullPath
            }
        }
    }

    local patternSource := prog.SetupPath . "\SW_모호 단축키 변경ver*.ahk"
    local sourceVer := "0.0"
    local sourceFile := ""

    Loop, Files, %patternSource%
    {
        RegExMatch(A_LoopFileName, "ver([\d_]+)\.ahk", m)
        if (m1 != "")
        {
            tmpVer := RegExReplace(m1, "_", ".")
            if (CompareVersion(tmpVer, sourceVer) = 1)
            {
                sourceVer := tmpVer
                sourceFile := A_LoopFileFullPath
            }
        }
    }

    if (startFile = "")
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


; -------------------------------
; CheckBlenderByFolder(index, prog)
; -------------------------------
; [용도] 블렌더 설치 폴더("Blender 4.3" 등)와 MSI 파일 버전을 비교
; -------------------------------
CheckBlenderByFolder(index, prog)
{
    local installedCtrl    := prog.installedControl
    local notInstalledCtrl := prog.notInstalledControl
    local buttonCtrl       := prog.buttonControl

    local foundFolderVer := "0.0"

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
        GuiControl,, %notInstalledCtrl%, % "[" . prog.Name . "] - 설치되지 않았습니다."
        GuiControl, Show, %notInstalledCtrl%
        GuiControl, Show, %buttonCtrl%
        GuiControl, Hide, %installedCtrl%
        return
    }

    local foundMsi := ""
    local foundMsiVer := "0.0"

    if (FileExist(prog.SetupPath) && !(FileExist(prog.SetupPath) = "D"))
    {
        foundMsi := prog.SetupPath
        if RegExMatch(prog.SetupPath, "blender-([\d\.]+)-windows", x)
            foundMsiVer := ExtractMajorMinor(x1)
    }
    else
    {
        local patternMsi := prog.SetupPath . "\blender-*.msi"
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

    if (startFile = "")
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


; ---------------------------------------------------------------------------
; [새로 추가] CheckMohoVersion(index, prog)
; ---------------------------------------------------------------------------
CheckMohoVersion(index, prog)
{
    local installedCtrl    := prog.installedControl
    local notInstalledCtrl := prog.notInstalledControl
    local buttonCtrl       := prog.buttonControl

    ; 모호 실행 파일 경로
    exePath := prog.InstallPath . "\Moho.exe"

    ; exe가 없으면 => 미설치
    if !FileExist(exePath)
    {
        GuiControl,, %notInstalledCtrl%, % "[" . prog.Name . "] - 설치되어 있지 않습니다."
        GuiControl, Show, %notInstalledCtrl%
        GuiControl, Show, %buttonCtrl%
        GuiControl, Hide, %installedCtrl%
        return
    }

    ; 파일 버전 얻기
    FileGetVersion, mohoExeVersion, %exePath%
    installedVer := ExtractMajorMinor(mohoExeVersion)

    ; "G:\공유 드라이브\JBBJ 자료실\애니메이션 관련 자료들\Moho*.exe" 패턴 탐색
    latestSetupFile := ""
    latestSetupVer  := "0.0"

    patternMoho := prog.SetupPath . "\Moho*.exe"
    Loop, Files, %patternMoho%
    {
        ; 예: "Moho1430_Win.exe" => 정규식으로 "14.3" 뽑기
        if RegExMatch(A_LoopFileName, "Moho(\d+)(\d+)0_Win", m)
        {
            major := m1
            minor := m2
            setupVer := major "." minor  ; "14.3"

            if (CompareVersion(setupVer, latestSetupVer) = 1)
            {
                latestSetupVer := setupVer
                latestSetupFile := A_LoopFileFullPath
            }
        }
    }

    ; 설치 파일이 하나도 없으면 => 현재 버전만 안내
    if (latestSetupFile = "")
    {
        GuiControl,, %installedCtrl%, % "[" . prog.Name . "] - 설치됨 (현재:" . installedVer . ")"
        GuiControl, Show, %installedCtrl%
        GuiControl, Hide, %notInstalledCtrl%
        GuiControl, Hide, %buttonCtrl%
        return
    }

    ; 구버전 여부 체크
    if (CompareVersion(latestSetupVer, installedVer) = 1)
    {
        GuiControl,, %notInstalledCtrl%, % "[" . prog.Name . "] - (구버전:" . installedVer . ") 새버전:" . latestSetupVer
        GuiControl, Show, %notInstalledCtrl%
        GuiControl, Show, %buttonCtrl%
        GuiControl, Hide, %installedCtrl%
    }
    else
    {
        GuiControl,, %installedCtrl%, % "[" . prog.Name . "] - 설치됨 (현재:" . installedVer . ")"
        GuiControl, Show, %installedCtrl%
        GuiControl, Hide, %notInstalledCtrl%
        GuiControl, Hide, %buttonCtrl%
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

    for index, prog in gPrograms
    {
        if (clickedBtn = prog.buttonControl)
        {
            prog.InstallFunc.Call(index, prog)
            break
        }
    }
}
Return


; -------------------------------
; DefaultInstall(index, prog)
; -------------------------------
; [용도] 설치 파일을 단순 Run (혹은 RunWait)하는 기본 로직
; -------------------------------
DefaultInstall(index, prog)
{
    Run, % prog.SetupPath
    ; 설치 완료 후 자동 새로고침을 하고 싶다면 아래처럼:
    ; RunWait, % prog.SetupPath
    ; RefreshCheck()
}


; -------------------------------
; InstallBlender(index, prog)
; -------------------------------
; [용도] 블렌더 MSI 실행 후 RefreshCheck
; -------------------------------
InstallBlender(index, prog)
{
    local foundMsi := ""
    local foundMsiVer := "0.0"

    if (FileExist(prog.SetupPath) && !(FileExist(prog.SetupPath) = "D"))
    {
        foundMsi := prog.SetupPath
        if RegExMatch(prog.SetupPath, "blender-([\d\.]+)-windows", m)
            foundMsiVer := ExtractMajorMinor(m1)
    }
    else
    {
        local patternMsi := prog.SetupPath . "\blender-*.msi"
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

    RunWait, % foundMsi
    RefreshCheck()
}


; -------------------------------
; InstallSWMoho(index, prog)
; -------------------------------
; [용도] SW_모호 파일 복사/업데이트 로직 (예시)
; -------------------------------
InstallSWMoho(index, prog)
{
    ; (1) 기존 설치된 SW_모호 단축키 변경 ver*.ahk 파일을 모두 삭제
    patternInstalled := prog.InstallPath . "\SW_모호 단축키 변경ver*.ahk"
    Loop, Files, %patternInstalled%
    {
        FileDelete, % A_LoopFileFullPath
    }

    ; (2) 마스터 폴더(SetupPath)에서 가장 최신 버전 파일 찾기
    patternMaster := prog.SetupPath . "\SW_모호 단축키 변경ver*.ahk"
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

    ; (3) 가장 최신 파일을 시작프로그램 폴더(InstallPath)에 복사
    ;     -> "Local destPath" 문법 없이, 그냥 바로 할당하면 자동으로 로컬 변수
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
; [6] 보조 함수들 (버전 비교, 버전 문자열 가공)
; =============================================================================

; -------------------------------
; CompareVersion(a, b)
; -------------------------------
; **버전 문자열**(*"4.2"나 "4.3.1"처럼*)을 '.' 기준으로 나눈 뒤 앞에서부터 숫자를 비교
; - a > b => return 1
; - a = b => return 0
; - a < b => return -1
; -------------------------------
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

; -------------------------------
; ShowProgramAsInstalledOrNot(prog, text, showButton := false)
; -------------------------------
;  - 한 프로그램이 여러 탭(카테고리)에 걸쳐 있을 수 있으므로,
;    prog.guiControls[카테고리] 안의 모든 컨트롤(설치됨/미설치/버튼)을 일괄 갱신
; -------------------------------
ShowProgramAsInstalledOrNot(prog, text, showButton := false)
{
    ; 혹시 guiControls가 없으면 그냥 리턴
    if !IsObject(prog.guiControls)
        return

    ; prog.guiControls 구조 예:
    ;   {
    ;     "최우선 설치 프로그램": { installedCtrl:..., notInstalledCtrl:..., buttonCtrl:... },
    ;     "유틸리티": { ... },
    ;     ...
    ;   }
    ; => 각 카테고리에 대해 loop
    for eachCat, ctrlSet in prog.guiControls
    {
        installedCtrlName    := ctrlSet.installedCtrl
        notInstalledCtrlName := ctrlSet.notInstalledCtrl
        buttonCtrlName       := ctrlSet.buttonCtrl

        if showButton
        {
            ; 미설치 or 구버전
            GuiControl,, %notInstalledCtrlName%, % text
            GuiControl, Show, %notInstalledCtrlName%
            GuiControl, Show, %buttonCtrlName%
            GuiControl, Hide, %installedCtrlName%
        }
        else
        {
            ; 설치됨
            GuiControl,, %installedCtrlName%, % text
            GuiControl, Show, %installedCtrlName%
            GuiControl, Hide, %notInstalledCtrlName%
            GuiControl, Hide, %buttonCtrlName%
        }
    }
}

; -------------------------------
; ExtractMajorMinor(fullVerStr)
; -------------------------------
; 예: "4.2.3" -> "4.2"
;     "4.10.1" -> "4.10"
; -------------------------------
ExtractMajorMinor(fullVerStr)
{
    arr := StrSplit(fullVerStr, ".")
    major := arr[1] + 0
    minor := (arr.MaxIndex() >= 2) ? arr[2] + 0 : 0
    return major "." minor
}
