YPosIcon1 = 97
YPosIcon2 = 97
YPosIcon3 = 97
YPosIcon4 = 97

TestText = 
(LTrim
  Producer:`t`tMom`n
  AssistantProducer:`tDad`n
  Sound:`t`t`tBaby`n
  This will go on for a while. 
  Believe me.
  It's not worth reading on.
  C'mon - quit now.
  Close the gui`n
  Hello?`n`n
  It's useless reading on.`n`n
  Oh look how nice it scrolls
  So you wanted it.
  I'll close the gui for you.`n`n`n`n`n`n
  BYE
)

If ( A_OSType = "WIN32_WINDOWS" )  ; Windows 9x
    DefaultItem = %A_WinDir%\system\shell32.dll
Else
    DefaultItem = %A_WinDir%\system32\shell32.dll

Gui +ToolWindow +AlwaysOnTop
Gui, Margin, 0, 0

Gui, Add, Picture, vIcon1 x72 ym+95 h16 w16 Icon44 AltSubmit, %DefaultItem%
Gui, Add, Text, vText1 x90 ym+95 , Chris
Gui, Add, Picture, vIcon2 x72 ym+95 h16 w16 Icon13 AltSubmit, %DefaultItem%
Gui, Add, Text, vText2 x95 ym+95, John Doe
Gui, Add, Picture, vIcon3 x72 ym+95 h16 w16 Icon95 AltSubmit, %DefaultItem%
Gui, Add, Text, vText3 x95 ym+95, Jane Doe
Gui, Add, Text, vText4 x23 ym+95, %TestText%
Gui, Add, GroupBox, xm ym-6 w189 h100
Gui, Show, w189 h93, Credits:

GoSub, ScrollUp
Return

GuiClose:
  ExitApp

ScrollUp:
  Loop, 264
    {
        If A_Index <=55
          {
            YPosIcon1 -= 2
            GuiControl, Move, Icon1, x72 y%YPosIcon1%
            GuiControl, Move, Text1, x90 y%YPosIcon1%
          }
        If (A_Index >= 27) AND (A_Index <= 82)
          {
            YPosIcon2 -= 2
            GuiControl, Move, Icon2, x72 y%YPosIcon2%
            GuiControl, Move, Text2, x90 y%YPosIcon2%
          }
        If (A_Index >= 54) AND (A_Index <= 109)
          {
            YPosIcon3 -= 2
            GuiControl, Move, Icon3, x72 y%YPosIcon3%
            GuiControl, Move, Text3, x90 y%YPosIcon3%
          }
        If (A_Index >= 78) AND (A_Index <= 262)
          {
            YPosIcon4 -= 2
            GuiControl, Move, Text4, y%YPosIcon4%
          }
        If (A_Index = 264)
          {
            GoSub, GuiClose
          }
        Sleep, 150
    }
Return