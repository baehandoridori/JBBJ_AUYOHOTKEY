; ==========================================================================
; JBBJ Protocol Handler
; jbbj:// 프로토콜을 받아서 파일 탐색기로 경로를 여는 스크립트
; ==========================================================================
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; 명령줄 인자 받기 (jbbj://open/G:/경로/...)
fullUrl := A_Args[1]

if (fullUrl = "")
{
    MsgBox, 48, JBBJ Protocol Handler, 경로가 전달되지 않았습니다.
    ExitApp
}

; <> 및 jbbj://open/ 제거하고 경로 추출
path := fullUrl
path := RegExReplace(path, "^<", "")      ; 앞쪽 < 제거
path := RegExReplace(path, ">$", "")      ; 뒤쪽 > 제거
path := RegExReplace(path, "^jbbj://open/", "")
path := RegExReplace(path, "^jbbj://", "")

; URL 디코딩 (공백 등 처리)
path := UriDecode(path)

; 슬래시를 백슬래시로 변환
path := StrReplace(path, "/", "\")

; 앞뒤 공백 제거
path := Trim(path)

; 경로 존재 확인 후 열기
if FileExist(path)
{
    ; 파일인지 폴더인지 확인
    FileGetAttrib, attr, %path%
    if InStr(attr, "D")
    {
        ; 폴더면 그냥 열기
        Run, explorer "%path%"
    }
    else
    {
        ; 파일이면 해당 파일 선택해서 열기
        Run, explorer /select`,"%path%"
    }
}
else
{
    MsgBox, 48, JBBJ Protocol Handler, 경로를 찾을 수 없습니다:`n`n%path%
}

ExitApp

; --------------------------------------------------------------------------
; URL 디코딩 함수
; --------------------------------------------------------------------------
UriDecode(uri)
{
    Loop
    {
        if !RegExMatch(uri, "i)(%[0-9A-F]{2})", match)
            break
        StringTrimLeft, hex, match, 1
        Transform, char, Chr, 0x%hex%
        StringReplace, uri, uri, %match%, %char%, All
    }
    ; + 를 공백으로
    StringReplace, uri, uri, +, %A_Space%, All
    return uri
}
