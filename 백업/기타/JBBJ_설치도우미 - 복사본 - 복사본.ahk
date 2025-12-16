#SingleInstance, Force

; ─────────────────────────────────────────────────────────────────────
; [1] 확인할 프로그램 개수
; 기존 3개 + SW_모호(버전 체크) 1개 → 총 4
; ─────────────────────────────────────────────────────────────────────
ProgCount := 4

; ─────────────────────────────────────────────────────────────────────
; [2] 기존 프로그램 1~3 정보 (폴더 존재 여부로 체크)
; ─────────────────────────────────────────────────────────────────────
; -- 1) 디스코드 --
Program1_Name := "디스코드"
Program1_InstallPath := "C:\Users\" . A_UserName . "\AppData\Local\Discord"
Program1_SetupPath   := "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\DiscordSetup.exe"

; -- 2) 프로그램1 (예시) --
Program2_Name := "프로그램1"
Program2_InstallPath := "C:\Program Files\Program1"
Program2_SetupPath   := "G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들\Program1Setup.exe"

; -- 3) 블렌더  --
Program3_Name := "블렌더"
Program3_InstallPath := "C:\Program Files\Blender Foundation"
Program3_SetupPath   := "G:\공유 드라이브\JBBJ 자료실\애니메이션 관련 자료들\blender-4.2.3-windows-x64.msi"

; ─────────────────────────────────────────────────────────────────────
; [3] SW_모호 단축키 변경ver (버전 검사 + 파일 복사)
; ─────────────────────────────────────────────────────────────────────
; Name: GUI 표시용
; InstallPath: 시작프로그램 폴더 (실제 설치 위치)
; SetupPath:   새 버전 ahk가 있는 "소스 폴더" (버전이 높다면 여기서 복사)
; ─────────────────────────────────────────────────────────────────────
Program4_Name := "SW_모호 단축키 변경"
Program4_InstallPath := A_StartMenu "\Programs\Startup"  ; 시작프로그램 폴더
Program4_SetupPath   := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\테스트_마스터폴더" ; 예시: 새 버전 ahk 보관 폴더

; ─────────────────────────────────────────────────────────────────────
; [4] GUI 만들기
; 기존 구조 유지
; ─────────────────────────────────────────────────────────────────────
Gui, Destroy
Gui, +AlwaysOnTop +Resize
Gui, Font, s10

Gui, Add, Text, x10 y10 w300 h20 cBlue, ★ 설치 여부 확인 도구 ★
curY := 40

Loop, %ProgCount%
{
    installedVar    := "installedVar" A_Index   ; 초록 텍스트
    notInstalledVar := "notInstalledVar" A_Index ; 빨간 텍스트
    buttonVar       := "buttonVar" A_Index      ; "설치 진행" 버튼

    ; 초록 텍스트
    Gui, Font, s10 cGreen
    Gui, Add, Text, x20 y%curY% w380 v%installedVar% Hidden, [Program%A_Index%_Name] - 설치되어 있습니다.

    ; 빨간 텍스트
    Gui, Font, s10 cRed
    Gui, Add, Text, x20 y%curY% w380 v%notInstalledVar% Hidden, [Program%A_Index%_Name] - 설치되어 있지 않습니다.

    Gui, Font, s10 cBlack
    Gui, Add, Button, x+10 w70 v%buttonVar% gInstallProgram Hidden, 설치 진행

    curY += 30
}

Gui, Add, Button, x20 y+10 gRefreshCheck, 새로고침

GoSub, RefreshCheck
Gui, Show, w500 h%curY%, 설치 상태 확인
Return

; ─────────────────────────────────────────────────────────────────────
; [5] 리프레시 로직
; 기존 프로그램(1~3)은 폴더 존재로 확인
; Program4(SW_모호)는 별도 버전 체크
; ─────────────────────────────────────────────────────────────────────
RefreshCheck:
{
    Loop, %ProgCount%
    {
        programName := Program%A_Index%_Name
        installPath := Program%A_Index%_InstallPath
        setupPath   := Program%A_Index%_SetupPath

        installedVar    := "installedVar" A_Index
        notInstalledVar := "notInstalledVar" A_Index
        buttonVar       := "buttonVar" A_Index

        ; -----------------------------------------
        ; 1) Program4 특수 로직 (SW_모호 버전 체크)
        ; -----------------------------------------
        if (A_Index = 4)
        {
            ; (A) 시작프로그램 폴더에서 "SW_모호 단축키 변경ver_*.ahk" 중 가장 높은 버전 찾기
            startFile := ""
            startVer  := 0.0

            patternStart := installPath "\SW_모호 단축키 변경ver*.ahk"
            Loop, Files, %patternStart%
            {
                ; 파일명 예) "SW_모호 단축키 변경ver_2_1.ahk"
                RegExMatch(A_LoopFileName, "ver([\d_]+)\.ahk", m)
                if (m1 != "")
                {
                    tmpVerStr := RegExReplace(m1, "_", ".")  ; "2.1"
                    tmpFloat := tmpVerStr + 0
                    if (tmpFloat > startVer)
                    {
                        startVer  := tmpFloat
                        startFile := A_LoopFileFullPath
                    }
                }
            }

            ; (B) 소스 폴더에서 "SW_모호 단축키 변경ver_*.ahk" 최신 버전 찾기
            sourceFile := ""
            sourceVer  := 0.0

            patternSource := setupPath "\SW_모호 단축키 변경ver*.ahk"
            Loop, Files, %patternSource%
            {
                RegExMatch(A_LoopFileName, "ver([\d_]+)\.ahk", m)
                if (m1 != "")
                {
                    tmpVerStr := RegExReplace(m1, "_", ".")
                    tmpFloat := tmpVerStr + 0
                    if (tmpFloat > sourceVer)
                    {
                        sourceVer  := tmpFloat
                        sourceFile := A_LoopFileFullPath
                    }
                }
            }

            ; (C) 설치 유무/버전 비교
            if (startFile = "")
            {
                ; 시작프로그램 폴더에 아예 없음 => 설치 안 됨
                GuiControl,, %notInstalledVar%, [%programName%] - (파일 없음) 설치되어 있지 않습니다.
                GuiControl, Show, %notInstalledVar%
                GuiControl, Show, %buttonVar%  ; 설치 버튼 표시
                GuiControl, Hide, %installedVar%
            }
            else
            {
                if (sourceVer > startVer)
                {
                    ; 소스 폴더가 더 높은 버전
                    GuiControl,, %notInstalledVar%, [%programName%] - (구버전:%startVer%) 더 높은 버전:%sourceVer% 존재
                    GuiControl, Show, %notInstalledVar%
                    GuiControl, Show, %buttonVar%  ; 업데이트 버튼
                    GuiControl, Hide, %installedVar%
                }
                else
                {
                    ; 같거나 시작프로그램 쪽이 더 높음 → 설치됨
                    GuiControl,, %installedVar%, [%programName%] - 설치됨 (현재:%startVer%)
                    GuiControl, Show, %installedVar%
                    GuiControl, Hide, %notInstalledVar%
                    GuiControl, Hide, %buttonVar%
                }
            }
        }
        else
        {
            ; -----------------------------------------
            ; 2) 기존 프로그램(1~3) 폴더 존재 여부 체크
            ; -----------------------------------------
            pathAttr := FileExist(installPath)
            if (pathAttr != "" && InStr(pathAttr, "D"))
            {
                ; 설치됨
                GuiControl,, %installedVar%, [%programName%] - 설치되어 있습니다.
                GuiControl, Show, %installedVar%
                GuiControl, Hide, %notInstalledVar%
                GuiControl, Hide, %buttonVar%
            }
            else
            {
                ; 미설치
                GuiControl,, %notInstalledVar%, [%programName%] - 설치되어 있지 않습니다.
                GuiControl, Show, %notInstalledVar%
                GuiControl, Show, %buttonVar%
                GuiControl, Hide, %installedVar%
            }
        }
    }
}
return

; ─────────────────────────────────────────────────────────────────────
; [6] "설치 진행" 버튼 누르면 실행
; 기존 프로그램(1~3)은 Run Setup
; Program4는 "SW_모호 단축키"를 복사/갱신
; ─────────────────────────────────────────────────────────────────────
InstallProgram:
{
    clickedBtn := A_GuiControl

    Loop, %ProgCount%
    {
        buttonVar := "buttonVar" A_Index
        if (clickedBtn = buttonVar)
        {
            programName := Program%A_Index%_Name
            installPath := Program%A_Index%_InstallPath
            setupPath   := Program%A_Index%_SetupPath

            if (A_Index = 4)
            {
                ; Program4 (SW_모호 단축키 변경ver) → 파일 복사 로직
                ; 1) 소스 폴더에서 최신 버전 파일 찾기
                sourceFile := ""
                sourceVer  := 0.0

                patternSource := setupPath "\SW_모호 단축키 변경ver*.ahk"
                Loop, Files, %patternSource%
                {
                    RegExMatch(A_LoopFileName, "ver([\d_]+)\.ahk", m)
                    if (m1 != "")
                    {
                        tmpVerStr := RegExReplace(m1, "_", ".")
                        tmpFloat := tmpVerStr + 0
                        if (tmpFloat > sourceVer)
                        {
                            sourceVer  := tmpFloat
                            sourceFile := A_LoopFileFullPath
                        }
                    }
                }

                if (sourceFile = "")
                {
                    MsgBox, 48, 오류, 소스 폴더에 "SW_모호 단축키 변경ver*.ahk" 파일이 없습니다.
                    return
                }

                ; 2) 시작프로그램 폴더에서 기존 파일 삭제(필요 시)
                ;   버전별 여러 파일이 있을 수 있으니, 전부 삭제하거나
                ;   혹은 Move/Backup 하거나... 정책에 따라 다름
                oldPattern := installPath "\SW_모호 단축키 변경ver*.ahk"
                Loop, Files, %oldPattern%
                {
                    FileDelete, %A_LoopFileFullPath%
                }

                ; 3) 파일 복사
                FileCopy, %sourceFile%, %installPath%, 1
                MsgBox, 64, 완료, [%programName%] 최신 버전(%sourceVer%) 복사 완료!
                ; 복사 후 다시 리프레시
                GoSub, RefreshCheck
            }
            else
            {
                ; 기존 로직 (디스코드,프로그램1,블렌더 등)
                Run, %setupPath%
                ; 만약 설치 끝난 후 자동 확인:
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
