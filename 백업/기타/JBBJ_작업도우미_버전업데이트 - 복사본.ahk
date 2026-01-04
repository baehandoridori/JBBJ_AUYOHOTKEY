; *****************************************************
;  AutoHotkey 스크립트 예시
;  기능:
;    1) 현재 실행 중인 프로세스 중, "JBBJ_작업도우미_배포용" 이라는 문자열을 (언더스코어 무시) 포함한 AHK 스크립트를 찾는다.
;    2) 찾은 스크립트(예: "JBBJ_작업도우미_배포용_ver3.ahk")를 버전 비교하여 시작프로그램 폴더(shell:startup)에 복사한다.
;    3) 이미 시작프로그램 폴더에 동일 이름(“JBBJ_작업도우미_배포용”)이 있는 경우, 버전 비교 후 덮어씌울지 물어본다.
;    4) "작업도우미_버전업데이트" 라는 문자열이 포함된 스크립트는 시작프로그램 대상에서 제외한다.
;    5) 언더스코어(_)가 없어도 검색될 수 있도록, 비교 시 cmdLine과 키워드 모두 `_`를 제거한 후에 InStr() 처리한다.
; *****************************************************

#NoEnv                          ; (권장 설정) 스크립트 실행 시 환경 변수를 깨끗이.
#Warn                           ; (권장 설정) 경고 활성화.
SendMode Input                  ; (권장 설정) 키 입력 모드를 빠르고 안정적으로 설정.
SetWorkingDir %A_ScriptDir%     ; 스크립트의 현재 작업 디렉터리를 스크립트 파일이 있는 폴더로 지정.
DetectHiddenWindows, On   ; 숨긴 창(트레이 아이콘 등)도 검색하기

; ------------------------------------------
; [핵심] WMI를 이용해 AutoHotkey.exe 프로세스 열거 및 커맨드라인 확인
;       - "언더스코어 제거" 로직 추가
; ------------------------------------------

; 변수 초기화
foundScriptPath := ""     ; "JBBJ_작업도우미_배포용" 스크립트 경로 (처음에는 빈 값)
foundScriptVer  := 0      ; 위 스크립트의 버전 (처음에는 0으로 설정)

; 우리가 찾고자 하는 키워드(원본)
searchKeyword         := "JBBJ_작업도우미_배포용"
; 언더스코어 제거된 키워드
searchKeywordNoUnder  := RegExReplace(searchKeyword, "_", "")

wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
colProcesses := wmi.ExecQuery("SELECT * FROM Win32_Process WHERE Name='AutoHotkey.exe'")

for process in colProcesses
{
    ; process.CommandLine : 예) "C:\Program Files\AutoHotkey\AutoHotkey.exe" "C:\Scripts\JBBJ_작업도우미_배포용_ver3.ahk"
    ; process.ExecutablePath : 예) "C:\Program Files\AutoHotkey\AutoHotkey.exe"
    
    cmdLine := process.CommandLine
    if !cmdLine
        continue
    
    ; "작업도우미_버전업데이트" 가 포함된 프로세스는 제외
    if InStr(cmdLine, "작업도우미_버전업데이트")
        continue

    ; -----------------------------------------------
    ;  (중요 추가) 언더스코어를 제거해서 비교하기
    ; -----------------------------------------------
    tempCmdLineNoUnder := RegExReplace(cmdLine, "_", "")
    ; 예: "C:\Scripts\JBBJ_작업도우미_배포용_ver3.ahk" -> "C:\Scripts\JBBJ작업도우미배포용ver3.ahk"

    ; 만약 언더스코어를 제거한 cmdLine 문자열 안에
    ; 언더스코어를 제거한 searchKeyword("JBBJ작업도우미배포용")가 들어 있다면,
    ; 즉, 로우바가 있든 없든 검색이 되도록 함.
    if InStr(tempCmdLineNoUnder, searchKeywordNoUnder)
    {
        ; 버전 추출: 
        ; 실제 파일명이 "_ver(\d+).ahk" 형태로 되어 있어야 정규식 매칭이 됨
        RegExMatch(cmdLine, ".*_v([\d_]+)\.ahk", m)
        rawVersion := m1  ; 예: "0_7"
        
        ; 더 높은 버전을 우선하여 저장 (또는 처음 찾은 프로세스만)
        if (rawVersion != "")
            {
                ; "0_7" -> "0.7"
                versionString := RegExReplace(rawVersion, "_", ".")
                ; AHK에서 "0.7" + 0 => 0.7 (float)
                floatVer := versionString + 0
                
                MsgBox, 
                (
                추출된 버전(문자열): %rawVersion%
                변환된 버전(실수): %floatVer%
                )
            }
            else
            {
                MsgBox, "버전 패턴(_v숫자_숫자.ahk)을 찾지 못했습니다."
            }
    }
}

; ------------------------------------------
; 결과 확인 후, 시작프로그램에 추가하는 로직
; ------------------------------------------
if (foundScriptPath = "")
{
    MsgBox, 48, 안내,
    (
"JBBJ_작업도우미_배포용" 문자열을 포함한 AutoHotkey 프로세스(스크립트)를 찾지 못했습니다.`n
(언더스코어 제거 후 검색했으나 발견되지 않음)
    )
    ExitApp
}
else
{
    MsgBox, 64, 확인,
    (
찾은 스크립트 경로: %foundScriptPath%`n
버전: %foundScriptVer%
    )
    ; 여기에서 FileCopy 등으로 시작프로그램에 등록하는 로직 실행
}

ExitApp


; ---------------------------------------------------------
; 아래 부분(함수 등)은 원본 예시에 있던 내용 그대로 유지
; ---------------------------------------------------------

; -------------------------
; 1) [함수] AHK 프로세스의 실행 경로(cmdline) 가져오기
;    AHK v1 기준 예시. AHK v2와는 문법이 다를 수 있음.
; -------------------------
GetAhkCmdLine(pid) 
{
    ; AutoHotkey가 실행 중인 프로세스에서 실제 스크립트 경로를 가져오기 위한 예시 함수입니다.
    ; PID를 입력받아 WM_GETTEXT 등을 통해 명령줄 정보를 추출하거나,
    ; WMI, PowerShell 등을 이용해 명령줄을 가져올 수 있습니다.
    ; 여기서는 가장 간단한 예시로, WinGetCmdLine() 함수가 있다고 가정(사용자 정의).
    ; 실제 구현은 별도의 라이브러리가 필요할 수 있음.
    
    Local cmdLine  ; cmdLine을 지역 변수로 선언한다.
    cmdLine := ""
    return cmdLine
}

; -------------------------
; 2) 현재 실행 중인 프로세스 중 AHK(=AutoHotkey.exe) 프로세스를 훑어보며
;    "JBBJ_작업도우미_배포용" 문자가 파일명에 포함된 스크립트 경로를 찾는다.
; -------------------------

DetectHiddenWindows, On
Process, Exist, AutoHotkey.exe
Loop
{
    break
}

pidList := [1234, 2345, 3456]  ; 여러 AutoHotkey.exe PID 예시 (실제론 동적으로 가져와야 함)

For each, pid in pidList
{
    cmdLine := GetAhkCmdLine(pid)
    if (InStr(cmdLine, "JBBJ_작업도우미_배포용") && !InStr(cmdLine, "작업도우미_버전업데이트"))
    {
        RegExMatch(cmdLine, ".*_ver(\d+).ahk", verMatch)
        tempVer := (verMatch1 ? verMatch1 : 1)
        
        if (tempVer > foundScriptVer)
        {
            foundScriptVer := tempVer
            foundScriptPath := cmdLine
        }
    }
}

; -------------------------
; 3) "JBBJ_작업도우미_배포용" 스크립트를 찾았다면, 시작프로그램 폴더에 등록/업데이트
; -------------------------

if (foundScriptPath = "")
{
    MsgBox, 48, 안내,
    (
"JBBJ_작업도우미_배포용" 스크립트를 실행 중인 프로세스가 없거나
"작업도우미_버전업데이트"라는 문자열이 포함된 항목만 있어서
업데이트 대상이 없습니다.
    )
    ExitApp
}
else
{
    ; -- 이하 로직 (기존 코드 동일) --
    ; 버전 비교 → 덮어씌우기 → 시작프로그램 폴더 열기 등
    ; ...
}
