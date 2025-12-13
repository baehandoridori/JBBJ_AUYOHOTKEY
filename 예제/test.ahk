; -------------------------------------------------------------
; test_embed.ahk - 오토핫키 GUI 내에 HTML 달력을 임베드하는 예시
; -------------------------------------------------------------

#NoEnv
#Warn
SendMode Input
SetWorkingDir %A_ScriptDir%

; ----------------------------------------
; 1. 먼저, 예시 HTML 코드를 넣어 둡니다.
; ----------------------------------------
myHtml =
(
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>달력 예제</title>
    <style>
        body { font-family: sans-serif; }
        h1 { color: #333; }
        table {
            border:1px solid #ccc;
            border-collapse: collapse;
            margin-top: 10px;
        }
        th, td {
            width:40px; height:40px; border:1px solid #ccc; text-align:center;
        }
        th { background-color: #f0f0f0; }
        .red { color: red; }
    </style>
</head>
<body>
    <h1>표시되는 달력</h1>
    <table>
        <thead>
            <tr>
                <th>일</th><th>월</th><th>화</th>
                <th>수</th><th>목</th><th>금</th>
                <th>토</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td class='red'>1</td><td>2</td><td>3</td><td>4</td>
                <td>5</td><td>6</td><td>7</td>
            </tr>
            <tr>
                <td>8</td><td>9</td><td>10</td><td>11</td>
                <td>12</td><td>13</td><td>14</td>
            </tr>
        </tbody>
    </table>
</body>
</html>
)


; ----------------------------------------
; 2. GUI 생성 및 컨트롤 배치
; ----------------------------------------

Gui, +Resize        ; 창 크기 조절 가능
Gui, Margin, 10, 10 ; 컨트롤 간 여백

; 예시: 간단한 Text/Edit/Button
Gui, Add, Text, x10 y10, [사용자 이름]
Gui, Add, Edit, x100 y5 w120 vUserName, 홍길동
Gui, Add, Button, x230 y5 w60 gOnClick, 확인

; 이 아래쪽 혹은 옆에 ActiveX 달력 표시
Gui, Add, ActiveX, x10 y50 w300 h300 vWB, Shell.Explorer

; ----------------------------------------
; 3. GUI 표시
; ----------------------------------------
Gui, Show, w530 h370, HTML 달력 임베드 예시
GoSub, LoadCalendar
Return


; ----------------------------------------
; 4. 달력을 로드하는 서브루틴
;    - about:blank 로 이동 후, document.write()로 HTML 표시
; ----------------------------------------
LoadCalendar:
GuiControlGet, wbObj,, WB
wbObj.Navigate("about:blank")
wbObj.document.write(myHtml)
wbObj.document.close()
return


; ----------------------------------------
; 5. 버튼 클릭 시 이벤트(예시)
; ----------------------------------------
OnClick:
Gui, Submit, NoHide
MsgBox, 64, 정보, 사용자 이름: %UserName%
return


; ----------------------------------------
; 6. 닫기 처리
; ----------------------------------------
GuiClose:
ExitApp
