#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%

; ========== 핫키 수정 가이드 ==========
; 현재 설정: F1 키
; 
; [핫키 수정 방법]
; 아래 'F1::' 부분을 원하는 단축키로 변경하시면 됩니다.
;
; [자주 사용하는 키 표기법]
; ^ = Ctrl
; ! = Alt
; + = Shift
; # = Windows 키
;
; [핫키 예시]
; F1::        ; F1 키
; ^c::        ; Ctrl + C
; !a::        ; Alt + A
; +b::        ; Shift + B
; ^!t::       ; Ctrl + Alt + T
; ^+s::       ; Ctrl + Shift + S
; #s::        ; Windows + S
;
; [기능키 예시]
; F1:: ~ F12::    ; F1 ~ F12
; Space::         ; 스페이스바
; Tab::           ; 탭
; Enter::         ; 엔터
; ESC::           ; ESC
; ==============================================

F1::
{
   Process, Exist, GestureSign.exe
   if (ErrorLevel) {  ; 프로세스가 존재하면
       Process, Close, GestureSign.exe
   } else {  ; 프로세스가 없으면
       Run, "C:\Users\user\AppData\Local\Microsoft\WindowsApps\GestureSign.exe"
   }
   return
}