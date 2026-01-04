#NoEnv
#Warn
#SingleInstance Force

myHtml := "
(
<!DOCTYPE html>
<html>
<head>
    <meta charset=""utf-8"">
    <title>테스트</title>
</head>
<body>
    <h1 style=""color:blue"">Hello AHK!</h1>
</body>
</html>
)
"

Gui, +Resize
Gui, Add, ActiveX, w600 h400 vWB, Shell.Explorer
Gui, Show, w650 h450, 멀티라인 문자열 테스트

GuiControlGet, wbObj,, WB
wbObj.Navigate("about:blank")
wbObj.document.write(myHtml)
wbObj.document.close()

return

GuiClose:
ExitApp
