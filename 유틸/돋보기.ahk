#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

OnExit, handle_exit

Gui, +AlwaysOnTop +Owner +Resize +ToolWindow ; window for the dock
Gui, Show, NoActivate w400 h400 x300 y50, 돋보기
Gui, Add, Text, y0 x10, 스페이스바를 누르면 돋보기 화면이 고정됩니다
Gui, Add, DDL, y20 x10 vzoom, 0.5|1|2||4|8|16
Gui, Add, Checkbox, y32 x150 vantialize, 안티에일리싱 ?
Gui, Add, Slider, vdelay x220 y20 Range15-200
Gui, Add, Text, x340 y32 w80 vdelay2

WinGet, PrintScreenID, id, 돋보기
WinSet, Transparent, 254, 돋보기

WinGet, PrintSourceID, id

hotkey, #x, toggle_follow
hotkey, +$LButton, click_through
Hotkey, ~Space, toggle_freeze ; 전역 핫키로 변경

toolbar_def := 55 ; 상단 메뉴 텍스트를 위해 높이 증가
toolbar := toolbar_def
follow := 0
freeze := 0 ; 화면 고정 상태를 저장할 새 변수

hdd_frame := DllCall("GetDC", UInt, PrintSourceID)
hdc_frame := DllCall("GetDC", UInt, PrintScreenID)

hdc_buffer := DllCall("gdi32.dll\CreateCompatibleDC", UInt, hdc_frame)
hbm_buffer := DllCall("gdi32.dll\CreateCompatibleBitmap", UInt, hdc_frame, Int, A_ScreenWidth, Int, A_ScreenHeight)

Gosub, Repaint
return

toggle_follow:
    follow := 1 - follow
    
    if (follow = 1)
    {
        WinSet, Region, 0-0 W%ww% H%wh% E, 돋보기
        toolbar := -12 ; 타이틀 바 높이 조정
        GuiControl, Hide, zoom
    }
    else
    {
        WinSet, Region,, 돋보기
        toolbar := toolbar_def
        GuiControl, Show, zoom
    }
Return

click_through:
    if (follow = 1)
    {
        Gui, Hide
        Send, {Click}
        SetTimer, Repaint, Off
        Sleep, 100
        Gui, Show
        SetTimer, Repaint, %delay%
    }
Return

toggle_freeze:
    ; 돋보기 창이 존재하는지 확인
    IfWinExist, 돋보기
    {
        freeze := 1 - freeze
        if (freeze = 1)
        {
            SetTimer, Repaint, Off
            ToolTip, 돋보기 화면 고정
        }
        else
        {
            SetTimer, Repaint, %delay%
            ToolTip, 돋보기 화면 고정 해제
        }
        SetTimer, RemoveToolTip, -1000
    }
Return

RemoveToolTip:
    ToolTip
Return

Repaint:
    if (freeze = 1)
        return

    CoordMode, Mouse, Screen
    MouseGetPos, start_x, start_y
    Gui, Submit, NoHide
    GuiControl,, delay2, delay %delay% ms
    WinGetPos, wx, wy, ww, wh, 돋보기

    wh2 := wh - toolbar

    DllCall("gdi32.dll\SetStretchBltMode", "uint", hdc_frame, "int", 4 * antialize)
    
    DllCall("gdi32.dll\StretchBlt", UInt, hdc_frame, Int, 0, Int, toolbar, Int, ww, Int, wh - toolbar
        , UInt, hdd_frame, Int
        , start_x-(ww / 2 / zoom)
        , Int, start_y -(wh2 / 2/zoom), Int, ww / zoom, Int, wh2 / zoom, UInt, 0xCC0020) ; SRCCOPY

    if (follow = 1)
        WinMove, 돋보기,, start_x - ww/2, start_y - wh/2
    
    SetTimer, Repaint, %delay%
Return

GuiClose:
handle_exit:
    DllCall("gdi32.dll\DeleteObject", UInt, hbm_buffer)
    DllCall("gdi32.dll\DeleteDC", UInt, hdc_frame)
    DllCall("gdi32.dll\DeleteDC", UInt, hdd_frame)
    DllCall("gdi32.dll\DeleteDC", UInt, hdc_buffer)
ExitApp