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
categoriesArray := ["최우선설치프로그램", "제작도구", "커뮤니케이션", "작업효율", "유틸리티1", "유틸리티2" ]  ; 대괄호 제거됨
for index, category in categoriesArray


; [1] 프로그램 등록 (Programs 배열 구성)
Programs := []

; ┌─────────────────────────────────────────────────────────────────────┐
; │ 구글 드라이브 (최우선 설치 프로그램, 유틸리티)                         │
; └─────────────────────────────────────────────────────────────────────┘
googledriveObj := {}
googledriveObj["Name"] := "구글 드라이브"
googledriveObj["InstallPath"] := "C:\\Program Files\\Google\\Drive File Stream"
googledriveObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\GoogleDriveSetup.exe"
googledriveObj["CheckFunc"] := Func("DefaultCheck")
googledriveObj["InstallFunc"] := Func("DefaultInstall")
googledriveObj["Categories"] := [categoriesArray[1], categoriesArray[5]]  ; 배열에서 직접 가져오기
Programs.Push(googledriveObj)

; 슬랙

slackObj := {}
slackObj["Name"] := "슬랙"
slackObj["installPath"] := "C:\\Users\\" . A_UserName . "\\AppData\\Local\\slack"
slackObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\SlackSetup.exe"
slackObj["CheckFunc"] := Func("DefaultCheck")
slackObj["InstallFunc"] := Func("Defaultinstall")
slackObj["Categories"] := [categoriesArray[1], categoriesArray[3]]
programs.Push(slackObj)

;디스코드

discordObj := {}
discordObj["Name"] := "디스코드"
discordObj["InstallPath"] := "C:\\Users\\" . A_UserName . "\\AppData\\Local\\Discord"
discordObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\DiscordSetup.exe"
discordObj["CheckFunc"] := Func("DefaultCheck")   ; 설치 여부 확인 => DefaultCheck 함수 사용
discordObj["InstallFunc"] := Func("DefaultInstall") ; 설치 진행 => DefaultInstall 함수 사용
discordObj["Categories"] := [categoriesArray[3]]
Programs.Push(discordObj)


; 카톡
kakaotalkObj := {}
kakaotalkObj["Name"] := "카톡"
kakaotalkObj["InstallPath"] := "C:\\Program Files (x86)\\Kakao"
kakaotalkObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\KakaoTalk_Setup.exe"
kakaotalkObj["CheckFunc"] :=  Func("DefaultCheck")
kakaotalkObj["InstallFunc"] :=  Func("DefaultInstall")
kakaotalkObj["Categories"] := [categoriesArray[3]]
programs.Push(kakaotalkObj)

;==== 스크립트 내 구성상 알아보기 쉽게 여기까지가 메신저====

; 모호
mohoObj := {}
mohoObj["Name"] := "모호14"
mohoObj["InstallPath"] := "C:\\Program Files\\Moho 14"
mohoObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\애니메이션 관련 자료들"
mohoObj["CheckFunc"] :=  Func("CheckMohoVersion")  ; ★ 함수 교체!
mohoObj["InstallFunc"] :=  Func("DefaultInstall")
mohoObj["Categories"] := [categoriesArray[1], categoriesArray[2]]
programs.Push(mohoObj)

;블렌더

blenderObj := {}
blenderObj["Name"] := "블렌더"
blenderObj["InstallPath"] := "C:\\Program Files\\Blender Foundation"
blenderObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\애니메이션 관련 자료들\\blender-4.2.3-windows-x64.msi"
blenderObj["CheckFunc"] := Func("CheckBlenderByFolder")
blenderObj["InstallFunc"] := Func("InstallBlender")
blenderObj["Categories"] := [categoriesArray[2]]
Programs.Push(blenderObj)



; 어도비 크리에이트 클라우드
AdobeCloudObj := {}
AdobeCloudObj["Name"] := "어도비 크리에이트 클라우드"
AdobeCloudObj["InstallPath"] := "C:\\Program Files\\Adobe\\Adobe Creative Cloud"
AdobeCloudObj["SetupPath"] := "https://www.adobe.com/kr/creativecloud.html?gclid=CjwKCAiA74G9BhAEEiwA8kNfpagkbelAWU7vjHorRym7-_6DfY8yG9TGt3zsUDqfNgbMfBtdqoTupBoCcGUQAvD_BwE&sdid=DHWC19Q8&mv=search&mv2=paidsearch&ef_id=CjwKCAiA74G9BhAEEiwA8kNfpagkbelAWU7vjHorRym7-_6DfY8yG9TGt3zsUDqfNgbMfBtdqoTupBoCcGUQAvD_BwE:G:s&s_kwcid=AL!3085!3!589558741352!e!!g!!%EC%96%B4%EB%8F%84%EB%B9%84%20%ED%81%AC%EB%A6%AC%EC%97%90%EC%9D%B4%ED%8B%B0%EB%B8%8C%20%ED%81%B4%EB%9D%BC%EC%9A%B0%EB%93%9C!1559096857!64669119332&gad_source=1"
AdobeCloudObj["CheckFunc"] :=  Func("DefaultCheck")
AdobeCloudObj["InstallFunc"] :=  Func("DefaultInstall")
AdobeCloudObj["Categories"] := [categoriesArray[2], categoriesArray[5]]
Programs.Push(AdobeCloudObj)


;애니메이트

;AnObj
;"C:\\Program Files\\Adobe\\Adobe Creative Cloud\\ACC\\Creative Cloud.exe"
; 애니메이트
AnObj := {}
AnObj["Name"] := "어도비 애니메이트"
AnObj["InstallPath"] := "C:\\Program Files\\Adobe"
AnObj["SetupPath"] := "C:\\Program Files\\Adobe\\Adobe Creative Cloud\\ACC\\Creative Cloud.exe"
AnObj["CheckFunc"] := Func("CheckAdobeFolderVersion")
AnObj["InstallFunc"] := Func("DefaultInstall")
AnObj["Categories"] := [categoriesArray[1] ,categoriesArray[2]]  ; 예: "제작도구" 등 원하는 카테고리
Programs.Push(AnObj)

; 프리미어
PrObj := {}
PrObj["Name"] := "어도비 프리미어 프로"
PrObj["InstallPath"] := "C:\\Program Files\\Adobe"
PrObj["SetupPath"] := "C:\\Program Files\\Adobe\\Adobe Creative Cloud\\ACC\\Creative Cloud.exe"
PrObj["CheckFunc"] := Func("CheckAdobeFolderVersion")
PrObj["InstallFunc"] := Func("DefaultInstall")
PrObj["Categories"] := [categoriesArray[1] ,categoriesArray[2]]  ; 예: "제작도구"
Programs.Push(PrObj)

; 에프터이펙트
AEObj := {}
AEObj["Name"] := "어도비 애프터이펙트"
AEObj["InstallPath"] := "C:\\Program Files\\Adobe"
AEObj["SetupPath"] := "C:\\Program Files\\Adobe\\Adobe Creative Cloud\\ACC\\Creative Cloud.exe"
AEObj["CheckFunc"] := Func("CheckAdobeFolderVersion")
AEObj["InstallFunc"] := Func("DefaultInstall")
AEObj["Categories"] := [categoriesArray[2]]  ; 예: "제작도구"
Programs.Push(AEObj)

; 미디어인코더
MeObj := {}
MeObj["Name"] := "어도비 미디어인코더"
MeObj["InstallPath"] := "C:\\Program Files\\Adobe"
MeObj["SetupPath"] := "C:\\Program Files\\Adobe\\Adobe Creative Cloud\\ACC\\Creative Cloud.exe"
MeObj["CheckFunc"] := Func("CheckAdobeFolderVersion")
MeObj["InstallFunc"] := Func("DefaultInstall")
MeObj["Categories"] := [categoriesArray[1] ,categoriesArray[2]]  ; 예: "제작도구"
Programs.Push(MeObj)

; 포토샵
PhObj := {}
PhObj["Name"] := "어도비 포토샵"
PhObj["InstallPath"] := "C:\\Program Files\\Adobe"
PhObj["SetupPath"] := "C:\\Program Files\\Adobe\\Adobe Creative Cloud\\ACC\\Creative Cloud.exe"
PhObj["CheckFunc"] := Func("CheckAdobeFolderVersion")
PhObj["InstallFunc"] := Func("DefaultInstall")
PhObj["Categories"] := [categoriesArray[2]]
Programs.Push(PhObj)



;==================여기까지가 일단 작업도구==================


;오토핫키 1

Ahk1Obj := {}
Ahk1Obj["Name"] := "오토핫키v1"
Ahk1Obj["InstallPath"] := "C:\\Program Files\\AutoHotkey\\v1.1.37.02"
Ahk1Obj["SetupPath"] := "G:\공유 드라이브\JBBJ 자료실\애니메이션 관련 자료들\편리한 단축키 추가 사용 오토핫키\AutoHotkey_1.1.37.02_setup.exe"
Ahk1Obj["CheckFunc"] :=  Func("DefaultCheck")
Ahk1Obj["InstallFunc"] :=  Func("DefaultInstall")
Ahk1Obj["Categories"] := [categoriesArray[1], categoriesArray[5]]
programs.Push(Ahk1Obj)

;오토핫키 2

Ahk2Obj := {}
Ahk2Obj["Name"] := "오토핫키v2"
Ahk2Obj["InstallPath"] := "C:\\Program Files\\AutoHotkey\\v2"
Ahk2Obj["SetupPath"] := "G:\공유 드라이브\JBBJ 자료실\애니메이션 관련 자료들\편리한 단축키 추가 사용 오토핫키\AutoHotkey_2.0.10_setup.exe"
Ahk2Obj["CheckFunc"] :=  Func("DefaultCheck")
Ahk2Obj["InstallFunc"] :=  Func("DefaultInstall")
Ahk2Obj["Categories"] := [categoriesArray[1], categoriesArray[5]]
programs.Push(Ahk2Obj)

; 구글 크롬

ChromeObj := {}
ChromeObj["Name"] := "구글 크롬"
ChromeObj["installpath"] := "C:\\Program Files\\Google\\Chrome"
ChromeObj["setuppath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\ChromeSetup.exe"
ChromeObj["Checkfunc"] :=  Func("DefaultCheck")
ChromeObj["Installfunc"] :=  Func("DefaultInstall")
ChromeObj["Categories"] := [categoriesArray[5]]
programs.Push(ChromeObj)


;파섹
parsecObj := {}
parsecObj["Name"] := "파섹"
parsecObj["installPath"] := "C:\\Program Files\\Parsec"
parsecObj["setuppath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\parsec-windows.exe"
parsecObj["CheckFunc"] :=  Func("DefaultCheck")
parsecObj["InstallFunc"] :=  Func("DefaultInstall")
parsecObj["Categories"] := [categoriesArray[5]]
Programs.Push(parsecObj)

; 팟플레이어
{
    potplayer64Obj := {}
    potplayer64Obj["Name"] := "팟플레이어"
    potplayer64Obj["installPath"] := ""
    potplayer64Obj["setuppath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\PotPlayerSetup64.exe"
    potplayer64Obj["CheckFunc"] :=  Func("CheckPotPlayerPaths")
    potplayer64Obj["InstallFunc"] :=  Func("DefaultInstall")
    potplayer64Obj["Categories"] := [categoriesArray[5]]
    Programs.Push(potplayer64Obj)
}


; 엔비디아 앱 (그래픽카드 드라이버버)
NvidiaObj := {}
NvidiaObj["Name"] := "엔비디아 앱"
NvidiaObj["installPath"] := "C:\\Program Files\\NVIDIA Corporation\\NVIDIA app\\CEF"
NvidiaObj["setuppath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\NVIDIA_app_v11.0.2.312.exe"
NvidiaObj["CheckFunc"] :=  Func("DefaultCheck")
NvidiaObj["InstallFunc"] :=  Func("DefaultInstall")
NvidiaObj["Categories"] := [categoriesArray[1]]
Programs.Push(NvidiaObj)


; 리스터리
ListaryObj := {}
ListaryObj["Name"] := "리스터리_크랙은 배씨에게 요청"
ListaryObj["installpath"] := "C:\\Program Files\\Listary"
ListaryObj["setuppath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\Listary.exe"
ListaryObj["CheckFunc"] :=  Func("DefaultCheck")
ListaryObj["InstallFunc"]  :=  Func("DefaultInstall")
ListaryObj["Categories"] := [categoriesArray[5]]
Programs.Push(ListaryObj)

;인존허브

inzonehubObj := {}
inzonehubObj["Name"] := "인존허브"
inzonehubObj["installpath"] := "C:\\Program Files\\Sony\\INZONE Hub"
inzonehubObj["setuppath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\INZONEHub_Setup_1.0.13.0.exe"
inzonehubObj["CheckFunc"] :=  Func("DefaultCheck")
inzonehubObj["InstallFunc"]  :=  Func("DefaultInstall")
inzonehubObj["Categories"] := [categoriesArray[5]]
programs.Push(inzonehubObj)


;로지옵션+
logiObj := {}
logiObj["Name"] := "로지옵션"
logiObj["installpath"] := "C:\\Program Files\\LogiOptionsPlus"
logiObj["setuppath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\logioptionsplus_installer.exe"
logiObj["CheckFunc"] :=  Func("DefaultCheck")
logiObj["InstallFunc"]  :=  Func("DefaultInstall")
logiObj["Categories"] := [categoriesArray[5]]
Programs.Push(logiObj)


;반디집
BDzipObj := {}
BDzipObj["Name"] := "반디집"
BDzipObj["installpath"] := "C:\Program Files\Bandizip"
BDzipObj["setuppath"] := "G:\\공유 드라이브\\JBBJ 자료실\\PC 설치 자료들\\BANDIZIP-SETUP-STD-X64.EXE"
BDzipObj["CheckFunc"] :=  Func("DefaultCheck")
BDzipObj["InstallFunc"]  :=  Func("DefaultInstall")
BDzipObj["Categories"] := [categoriesArray[5]]
Programs.Push(BDzipObj)


; 테스트오브젝트
testObj := {}
testObj["Name"] := "테스트"
testObj["InstallPath"] := "c:\\program files\\testtest"
testObj["SetupPath"] := "G:\\공유드라이브\\tset.exe"
testObj["CheckFunc"] := Func("DefaultCheck")
testObj["InstallFunc"] := Func("DefaultInstall")
testObj["Categories"] := [categoriesArray[1], categoriesArray[3]]
Programs.Push(testObj)



;====================일단 여기까지 유틸 ========================


swMohoObj := {}
swMohoObj["Name"] := "SW_모호 단축키 변경"
swMohoObj["InstallPath"] := A_StartMenu "\Programs\Startup"
swMohoObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\MOHO universal\\성원 오토핫키"
swMohoObj["CheckFunc"] := Func("CheckSWMoho")
swMohoObj["InstallFunc"] := Func("InstallSWMoho")
swMohoObj["Categories"] := [categoriesArray[4]]
Programs.Push(swMohoObj)


JbbjObj := {}
JbbjObj["name"] := "Jbbj 작업도우미"
JbbjObj["installpath"] := A_StartMenu "\Programs\Startup"
JbbjObj["SetupPath"] := "G:\\공유 드라이브\\JBBJ 자료실\\MOHO universal\\JBBJ작업도우미"
JbbjObj["CheckFunc"] := Func("CheckJbbj")
JbbjObj["InstallFunc"] := Func("InstallJbbj")
JbbjObj["Categories"] := [categoriesArray[4]]
Programs.Push(JbbjObj)

; (이하 동일... 슬랙, 디스코드, 모호, 블렌더, etc. 전부 등록)
; ...
; (중략)

global gPrograms := Programs


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
        currentCatClean := RegExReplace(currentCat, "\s+", "_")
        Gui, Tab, %A_Index%
        

        curY := 50

        for progIndex, prog in gPrograms
        {
            if IsObject(prog.Categories)
            {
                isInCurrentCategory := false
                for _, progCategory in prog.Categories
                {
                    if (progCategory == currentCat)
                    {
                        isInCurrentCategory := true
                        break
                    }
                }
                
                if (!isInCurrentCategory)
                    continue
            }
            else if (prog.Categories != currentCat)
                continue

            progNameClean := RegExReplace(prog.Name, "\s+", "_")

            installedCtrlName := "installed_" . progNameClean . "_" . currentCatClean . "_" . A_Index
            notInstalledCtrlName := "notinstalled_" . progNameClean . "_" . currentCatClean . "_" . A_Index
            buttonCtrlName := "button_" . progNameClean . "_" . currentCatClean . "_" . A_Index

            if !IsObject(prog.guiControls)
                prog.guiControls := {}
            if !IsObject(prog.guiControls[currentCat])
                prog.guiControls[currentCat] := {}
            
            prog.guiControls[currentCat].installedCtrl := installedCtrlName
            prog.guiControls[currentCat].notInstalledCtrl := notInstalledCtrlName
            prog.guiControls[currentCat].buttonCtrl := buttonCtrlName

            

            Gui, Font, s10 cGreen
            Gui, Add, Text, x20 y%curY% w450 v%installedCtrlName% Hidden
                , % "[" . prog.Name . "] - 설치되어 있습니다."
            
            Gui, Font, s10 cRed
            Gui, Add, Text, x20 y%curY% w450 v%notInstalledCtrlName% Hidden
                , % "[" . prog.Name . "] - 설치되어 있지 않습니다."
            
            Gui, Font, s10 cBlack
            Gui, Add, Button, x+50 w70 v%buttonCtrlName% gInstallProgram Hidden
                , 설치 진행

            curY += 30
        }
    }

    Gui, Tab
    Gui, Add, Button, x20 y420 gRefreshCheck, 새로고침
    Gui, Show, w640 h450, JBBJ 자료실실

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
; CheckAdobeFolderVersion(index, prog)
;   - "C:\Program Files\Adobe" 폴더 아래에 있는
;     "Adobe Animate 2025", "Adobe After Effects 2025" 등 폴더를 찾아,
;     폴더 이름 끝의 숫자 부분을 버전으로 인식하여 표시.
;   - 예) "Adobe After Effects 2025" → 버전 "25"
; ---------------------------------------------------------------------------
CheckAdobeFolderVersion(index, prog)
{
    ; (1) 프로그램 이름(예: "어도비 애니메이트", "어도비 프리미어 프로" 등)
    local productName := prog.Name

    ; (2) Adobe 폴더에 있는 "Adobe ??? 2025" 같은 하위 폴더를 찾는다
    local foundVer := ""
    Loop, Files, % prog.InstallPath . "\Adobe* *", D  ; D = 디렉토리만
    {
        ; A_LoopFileName 예: "Adobe Animate 2025"
        ; 정규식으로 끝의 숫자 부분만 추출 (예: "2025" → version "25")
        ; - 또는 "20\d\d" → "Adobe Animate 2025" => "2025" (뒤 4자리)
        
        if RegExMatch(A_LoopFileName, "20(\d\d)$", m)
        {
            tmpVer := m1  ; 예: "25"
            if (tmpVer != "")
                foundVer := tmpVer
        }
    }

    if (foundVer = "")
    {
        ; 폴더가 전혀 없으면 -> "미설치"
        local text := "[" . productName . "] - 설치 폴더를 찾지 못했습니다."
        ShowProgramAsInstalledOrNot(prog, text, true)
    }
    else
    {
        ; ex) 버전 "25"를 찾았다고 가정
        local text := "[" . productName . "] - 설치됨 (현재버전:" . foundVer . ")"
        ShowProgramAsInstalledOrNot(prog, text, false)
    }
}





; -------------------------------
; [용도] SW_모호 단축키 변경의 버전 체크
;        (파일명 "SW_모호 단축키 변경ver*.ahk"에서 버전 추출)
; -------------------------------
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
; ---------------------------------------------------------------------------
; CheckSWMoho(index, prog)
;   - SW_모호 단축키 변경 파일(바로 가기.ahk) 버전 비교
; ---------------------------------------------------------------------------
CheckSWMoho(index, prog)
{
    ; (A) 시작프로그램 폴더(InstallPath)에서 바로가기 파일 검색
    patternStart := prog.InstallPath . "\SW_모호 단축키 변경ver* - 바로 가기.*"
    startVer := "0.0"

    Loop, Files, %patternStart%
    {
        RegExMatch(A_LoopFileName, "SW_모호\s단축키\s변경ver([\d_]+)\s-\s바로\s가기", m)
        if (m1 != "")
        {
            tmpVer := RegExReplace(m1, "_", ".")
            if (CompareVersion(tmpVer, startVer) = 1)
                startVer := tmpVer
        }
    }

    ; (B) 자료실(SetupPath) 쪽도 동일한 패턴 적용
    patternSource := prog.SetupPath . "\SW_모호 단축키 변경ver* - 바로 가기.*"
    sourceVer := "0.0"

    Loop, Files, %patternSource%
    {
        RegExMatch(A_LoopFileName, "SW_모호\s단축키\s변경ver([\d_]+)\s-\s바로\s가기", m)
        if (m1 != "")
        {
            tmpVer := RegExReplace(m1, "_", ".")
            if (CompareVersion(tmpVer, sourceVer) = 1)
                sourceVer := tmpVer
        }
    }

    ; (C) 설치 X / 구버전 / 최신 버전 판별
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


CheckJbbj(index, prog)
{
    local patternStart
    patternStart := prog.InstallPath . "\JBBJ_작업도우미_배포용_v*.ahk"

    local startVer
    startVer := "0.0"

    Loop, Files, %patternStart%
    {
        RegExMatch(A_LoopFileName, "v([\d_]+)\.ahk", m)
        if (m1 != "")
        {
            tmpVer := RegExReplace(m1, "_", ".")
            if (CompareVersion(tmpVer, startVer) = 1)
                startVer := tmpVer
        }
    }

    local patternSource
    patternSource := prog.SetupPath . "\JBBJ_작업도우미_배포용_v*.ahk"

    local sourceVer
    sourceVer := "0.0"

    Loop, Files, %patternSource%
    {
        RegExMatch(A_LoopFileName, "v([\d_]+)\.ahk", m)
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

; --------------------------------------------
; ★새로 추가★ CheckPotPlayerPaths(index, prog)
; --------------------------------------------
CheckPotPlayerPaths(index, prog)
{
    ; 한 줄 배열 리터럴 (쉼표로 구분)
    possiblePaths := ["C:\\Program Files (x86)\\DAUM\\PotPlayer", "C:\\Program Files\\DAUM\\PotPlayer"]

    installed := false
    for i, path in possiblePaths
    {
        if (FileExist(path) && InStr(FileExist(path), "D"))
        {
            installed := true
            break
        }
    }

    if installed
    {
        text := "[" . prog.Name . "] - 설치되어 있습니다."
        ShowProgramAsInstalledOrNot(prog, text, false)
    }
    else
    {
        text := "[" . prog.Name . "] - 설치되어 있지 않습니다."
        ShowProgramAsInstalledOrNot(prog, text, true)
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
    patternInstalled := prog.InstallPath . "\SW_모호 단축키 변경ver* - 바로 가기.*"

    Loop, Files, %patternInstalled%
    {
        FileDelete, %A_LoopFileFullPath%
    }

    local patternMaster
    patternMaster := prog.SetupPath . "\SW_모호 단축키 변경ver* - 바로 가기.*"

    local bestFile, bestVer
    bestFile := ""
    bestVer  := "0.0"

    Loop, Files, %patternMaster%
    {
        RegExMatch(A_LoopFileName, "SW_모호\s단축키\s변경ver([\d_]+)\s-\s바로\s가기", m)
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
; ---------------------------------------------------------------------------
; InstallJbbj(index, prog)
;   - JBBJ 작업도우미 변경 파일 복사/업데이트 로직
; ---------------------------------------------------------------------------
InstallJbbj(index, prog)
{
    local patternInstalled
    patternInstalled := prog.InstallPath . "\JBBJ_작업도우미_배포용_v*.ahk"

    Loop, Files, %patternInstalled%
    {
        FileDelete, %A_LoopFileFullPath%
    }

    local patternMaster
    patternMaster := prog.SetupPath . "\JBBJ_작업도우미_배포용_v*.ahk"

    local bestFile, bestVer
    bestFile := ""
    bestVer  := "0.0"

    Loop, Files, %patternMaster%
    {
        RegExMatch(A_LoopFileName, "v([\d_]+)\.ahk", m)
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
        MsgBox, 48, 오류, 최신 버전의 JBBJ 작업도우미 파일을 찾지 못했습니다.
        return
    }

    destPath := prog.InstallPath
    FileCopy, %bestFile%, %destPath%, 1

    MsgBox, 64, 안내, JBBJ 작업도우미 설치(업데이트)가 완료되었습니다.
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
