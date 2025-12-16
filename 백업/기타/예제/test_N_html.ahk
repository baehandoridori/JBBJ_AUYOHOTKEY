; test_inline.ahk
; ----------------------------------------------

/*
  멀티 라인 문자열에 html을 담아두고,
  "about:blank" 로 이동한 후, document.write() 하는 방식
*/

myHtml :=
( 
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Inline Calendar</title>
    <style>
    .calendar { border:1px solid #ccc; display:inline-block; }
    .calendar th, .calendar td { width:40px; height:40px; border:1px solid #eee; text-align:center; }
    </style>
</head>
<body>
    <h2>Inline Calendar Example</h2>
    <table class="calendar">
        <thead>
            <tr>
                <th>일</th><th>월</th><th>화</th>
                <th>수</th><th>목</th><th>금</th><th>토</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td style="color:red">1</td>
                <td>2</td><td>3</td>
                <td>4</td><td>5</td><td>6</td><td>7</td>
            </tr>
        </tbody>
    </table>
</body>
</html>
)

Gui, +Resize
Gui, Add, ActiveX, x0 y0 w800 h600 vWB, Shell.Explorer

GuiControlGet, wbObj, , WB
wbObj.Navigate("about:blank")        ; 빈 페이지로 이동
wbObj.document.write(myHtml)        ; 직접 문서에 HTML 코드를 씁니다
wbObj.document.close()

Gui, Show, w820 h620, Inline HTML Calendar Test
Return

GuiClose:
ExitApp
