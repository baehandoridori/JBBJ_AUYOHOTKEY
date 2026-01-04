#NoEnv
#Warn
SendMode Input
SetWorkingDir %A_ScriptDir%

DetectHiddenWindows, On
startupFolder := A_Startup
searchKeyword := "JBBJ_작업도우미_배포용"

; 현재 실행중인 AHK 창 검색
WinGet, AHKList, List, ahk_class AutoHotkey
foundScript := ""
foundVersion := 0.0

Loop %AHKList%
{
    WinGetTitle, thisTitle, % "ahk_id " . AHKList%A_Index%
    if InStr(thisTitle, searchKeyword)
    {
        foundScript := thisTitle
        RegExMatch(thisTitle, "_v([\d_]+)\.ahk", m)
        if (m1 != "")
            foundVersion := RegExReplace(m1, "_", ".") + 0
        break
    }
}

if (foundScript = "")
{
    MsgBox, 48, 안내, 실행 중인 JBBJ 작업도우미 배포용을 찾을 수 없습니다.
    ExitApp
}

; 시작프로그램의 작업도우미 검색
startupVersion := 0.0
Loop, %startupFolder%\*.ahk
{
    if InStr(A_LoopFileName, searchKeyword)
    {
        RegExMatch(A_LoopFileName, "_v([\d_]+)\.ahk", m)
        if (m1 != "")
            startupVersion := RegExReplace(m1, "_", ".") + 0
        break
    }
}

SplitPath, foundScript, fileName
destFile := startupFolder . "\" . fileName

MsgBox, Debug정보:`n원본:%foundScript%`n대상:%destFile%

if (startupVersion = 0.0)
{
    FileCopy, %foundScript%, %destFile%, 1
    if ErrorLevel
    {
        MsgBox, 16, 오류, 파일 복사 실패
        ExitApp
    }
    MsgBox, 64, 완료, 작업도우미를 시작프로그램에 등록했습니다.
    Run, explorer.exe %startupFolder%
}
else if (foundVersion > startupVersion)
{
    FileCopy, %foundScript%, %destFile%, 1
    if ErrorLevel
    {
        MsgBox, 16, 오류, 파일 복사 실패
        ExitApp
    }
    MsgBox, 64, 완료, 시작프로그램의 작업도우미를 새 버전으로 업데이트했습니다.
    Run, explorer.exe %startupFolder%
}
else
{
    MsgBox, 64, 안내, 시작프로그램에 이미 같거나 더 높은 버전이 등록되어 있습니다.
}

ExitApp