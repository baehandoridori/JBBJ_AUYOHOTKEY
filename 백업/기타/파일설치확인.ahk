#SingleInstance, Force

; ─────────────────────────────────────────────────────────────────────
; [1] 확인할 프로그램 개수
; ─────────────────────────────────────────────────────────────────────
ProgCount := 4

; ─────────────────────────────────────────────────────────────────────
; [2] 프로그램별 정보
;     - 필요한 만큼 Program3, Program4... 식으로 늘려가면 됨
; ─────────────────────────────────────────────────────────────────────
; -- 1) 디스코드 --
Program1_Name := "디스코드"
Program1_InstallPath := "C:\Users\" . A_UserName . "\AppData\Local\Discord"
Program1_SetupPath   := "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\DiscordSetup.exe"

; -- 2) 프로그램1 (예시) --
Program2_Name := "프로그램1"
Program2_InstallPath := "C:\Program Files\Program1"
Program2_SetupPath   := "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\Program1Setup.exe"

; -- 3) 프로그램3 (블렌더) 실제 설치 폴더 경로는 Blender Foundation 폴더 하위에 Blender x.x(버전) 아래에 응용 프로그램이 설치되지만, 
; -- 3) 설치시 생성되는 상위 폴더만 확인하는 것으로 수정함. 참고바람!
Program3_Name := "블렌더"
Program3_InstallPath := "C:\Program Files\Blender Foundation"
Program3_SetupPath   := "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\blender-4.3.0-windows-x64.msi"


Program4_Name := "구글 크롬"
Program4_InstallPath := "C:\Program Files\Google\Chrome"
Program4_SetupPath   := "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\ChromeSetup.exe"

; 만약 새 프로그램3을 추가하려면:
;  - ProgCount := 3 으로 수정
;  - 아래처럼 변수 3개 추가:
; Program3_Name := "프로그램3"
; Program3_InstallPath := "C:\Program Files\Program3"
; Program3_SetupPath   := "G:\...\Program3Setup.exe"

; ─────────────────────────────────────────────────────────────────────
; [3] GUI 만들기
; ─────────────────────────────────────────────────────────────────────
Gui, Destroy
Gui, +AlwaysOnTop +Resize
Gui, Font, s10

Gui, Add, Text, x10 y10 w300 h20 cBlue, ★ 설치 여부 확인 도구 ★
curY := 40

; 3-1) 각 프로그램마다 "설치됨 텍스트(초록)" + "설치안됨 텍스트(빨간)" + "설치버튼" 생성
Loop, %ProgCount%
{
    ; 프로그램별 고유 GUI 컨트롤 변수명 정하기
    installedVar    := "installedVar" A_Index   ; 초록 텍스트
    notInstalledVar := "notInstalledVar" A_Index ; 빨간 텍스트
    buttonVar       := "buttonVar" A_Index      ; "설치 진행" 버튼

    ; -- 초록색 텍스트 --
    Gui, Font, s10 cGreen
    Gui, Add, Text, x20 y%curY% w300 v%installedVar% Hidden, [Program%A_Index%_Name] - 설치되어 있습니다.

    ; -- 빨간색 텍스트 --
    Gui, Font, s10 cRed
    Gui, Add, Text, x20 y%curY% w300 v%notInstalledVar% Hidden, [Program%A_Index%_Name] - 설치되어 있지 않습니다.

    ; -- 폰트 기본으로 복원 --
    Gui, Font, s10 cBlack

    ; -- 설치 진행 버튼 (처음엔 숨김) --
    Gui, Add, Button, x+10 w70 v%buttonVar% gInstallProgram Hidden, 설치 진행

    curY += 30
}

; "리프레시" 버튼
Gui, Add, Button, x20 y+10 gRefreshCheck, 리프레시

; GUI 표시 전에 1회 상태 갱신
GoSub, RefreshCheck

Gui, Show, w450 h%curY%, 설치 상태 확인
Return


; ─────────────────────────────────────────────────────────────────────
; [4] 리프레시: 설치 여부 다시 확인
; ─────────────────────────────────────────────────────────────────────
RefreshCheck:
{
    Loop, %ProgCount%
    {
        ; 동적 변수 읽기
        programName := Program%A_Index%_Name
        installPath := Program%A_Index%_InstallPath
        setupPath   := Program%A_Index%_SetupPath

        installedVar    := "installedVar" A_Index
        notInstalledVar := "notInstalledVar" A_Index
        buttonVar       := "buttonVar" A_Index

        ; 폴더 존재 여부 검사
        pathAttr := FileExist(installPath)
        if (pathAttr != "" && InStr(pathAttr, "D"))
        {
            ; 설치됨 → 초록 텍스트 보여주고, 빨간 텍스트 & 버튼 숨김
            GuiControl,, %installedVar%, [%programName%] - 설치되어 있습니다.
            GuiControl, Show, %installedVar%
            GuiControl, Hide, %notInstalledVar%
            GuiControl, Hide, %buttonVar%
        }
        else
        {
            ; 미설치 → 빨간 텍스트와 설치 버튼 보여주고, 초록 텍스트 숨김
            GuiControl,, %notInstalledVar%, [%programName%] - 설치되어 있지 않습니다.
            GuiControl, Show, %notInstalledVar%
            GuiControl, Show, %buttonVar%
            GuiControl, Hide, %installedVar%
        }
    }
}
return


; ─────────────────────────────────────────────────────────────────────
; [5] "설치 진행" 버튼: 어떤 버튼이 눌렸는지 판단하여 설치 파일 실행
; ─────────────────────────────────────────────────────────────────────
InstallProgram:
{
    clickedBtn := A_GuiControl

    Loop, %ProgCount%
    {
        buttonVar := "buttonVar" A_Index
        if (clickedBtn = buttonVar)
        {
            setupPath := Program%A_Index%_SetupPath
            Run, %setupPath%
            ; 설치 종료 후 자동 확인하고 싶으면:
            ; RunWait, % setupPath%
            ; GoSub, RefreshCheck
            break
        }
    }
}
return


; GUI 닫으면 스크립트 종료
GuiClose:
ExitApp
