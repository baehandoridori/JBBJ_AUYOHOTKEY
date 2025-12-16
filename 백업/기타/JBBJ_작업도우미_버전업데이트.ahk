; *****************************************************
; [작업도우미_버전업데이트.ahk]
;  기능:
;    1) JBBJDOUMIPATH.ini에서 "작업도우미가 들어 있는 폴더" 경로를 읽는다.
;    2) 해당 폴더 내 "JBBJ_작업도우미_배포용_v*.ahk" 파일 중 가장 높은 버전을 찾는다.
;    3) 시작프로그램 폴더에 이미 있는 작업도우미와 비교 -> 최신 파일이면 덮어씌우기
;    4) (%.2f) 대신 Round() 사용 -> 한글 메시지 정상 처리
;
;  인코딩/환경:
;   - 스크립트 파일: UTF-8 with BOM 로 저장
;   - INI 파일도 UTF-8 with BOM (또는 영문만 사용)
;   - AutoHotkey Unicode 버전 사용 권장
; *****************************************************

#NoEnv
#Warn
SendMode Input
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On

; -- INI 경로 지정 (스크립트와 같은 폴더에 있다고 가정) --
iniFilePath := "G:\공유 드라이브\개인작업일지 모음\개인작업일지_배한솔\02_업무\프로젝트\07_오토핫키 한솔프로젝트\new\JBBJDOUMIPATH.ini"

; -- INI에서 폴더 경로 읽기 --
IniRead, WorkerFolder, %iniFilePath%, WorkerPathSection, WorkerFolder
if (workerFolder = "ERROR") or (workerFolder = "")
{
    MsgBox, 48, 오류, "작업도우미 폴더 경로를 INI에서 가져올 수 없습니다."
    ExitApp
}

; -- 해당 폴더에 있는 "JBBJ_작업도우미_배포용_v*.ahk" 중 가장 높은 버전 찾기 --
pattern := workerFolder "\JBBJ_작업도우미_배포용_v*.ahk"
latestFile := ""
latestFloatVer := 0.0

Loop, Files, %pattern%
{
    ; 파일명 예) "JBBJ_작업도우미_배포용_v1_3.ahk"
    RegExMatch(A_LoopFileName, ".*_v([\d_]+)\.ahk", m)
    if (m1 != "")
    {
        tmpVerStr := RegExReplace(m1, "_", ".") ; 예 "1.3" 또는 "0.7"
        tmpFloat := tmpVerStr + 0
        if (tmpFloat > latestFloatVer)
        {
            latestFloatVer := tmpFloat
            latestFile := A_LoopFileFullPath
        }
    }
}

if (latestFile = "")
{
    MsgBox, 48, 안내,
    (
"%workerFolder%" 경로에 "JBBJ_작업도우미_배포용_v*.ahk" 파일이 없습니다.`n
업데이트 대상이 없습니다.
    )
    ExitApp
}

; -- 시작프로그램 폴더에서 기존 파일 검색 --
startupFolder := A_StartMenu "\Programs\Startup"
existingFile := ""
existingFloatVer := 0.0

Loop, Files, %startupFolder%\*.ahk
{
    if InStr(A_LoopFileName, "JBBJ_작업도우미_배포용")
    {
        RegExMatch(A_LoopFileName, ".*_v([\d_]+)\.ahk", ex)
        if (ex1 != "")
        {
            tmpVerStr := RegExReplace(ex1, "_", ".")
            tmpFloat := tmpVerStr + 0
            existingFile := A_LoopFileFullPath
            existingFloatVer := tmpFloat
        }
        break
    }
}

; -- 복사/업데이트 로직 --
if (existingFile = "")
{
    ; 시작프로그램 폴더에 전혀 없음 -> 바로 복사
    newVerRound := Round(latestFloatVer, 2)
    MsgBox, 64, 안내,
    (
현재 사용자에게 작업도우미가 없는 것으로 확인되었습니다.`n
현재 폴더에서 찾은 버전(%newVerRound%)을 복사합니다.
    )
    FileCopy, %latestFile%, %startupFolder%, 1
    MsgBox, 64, 완료, 복사 작업 완료!
}
else
{
    ; 이미 존재 -> 버전 비교
    newVer := Round(latestFloatVer, 2)
    oldVer := Round(existingFloatVer, 2)

    if (latestFloatVer > existingFloatVer)
    {
        MsgBox, 4, 알림, 상위 버전 (%newVer%) (현재 버전: %oldVer%) 발견, 덮어씌울까요?  ; 4 = Yes/No
        IfMsgBox Yes
            {
                ; 사용자가 "예(Yes)"를 누름
                ; => 실제로 덮어씌우는 로직
                FileDelete, %existingFile%
                FileCopy, %latestFile%, %startupFolder%, 1
                MsgBox, 64, 완료, "업데이트 완료!"
            }
            else
                {
                    ; 사용자가 "아니오(No)"를 누름
                    MsgBox, 64, 취소, "덮어씌우기를 취소했습니다."
                }
    }
    else
    {
        MsgBox, 64, 안내,
        (
현재 사용자에게 설치된 작업도우미 버전이 최신 버전입니다.`n (현재버전: %oldVer%) (최신 버전: %newVer%)`n
업데이트가 필요 없습니다.
        )
    }
}

ExitApp
