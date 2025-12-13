Gui, Font, S14 CDefault, Verdana
Gui, Add, Text, x152 y9 w160 h20 , JBBJ 작업 마법사
Gui, Font, S10 CDefault, Verdana
Gui, Add, Text, x12 y49 w340 h20 , 여러분의 작업의 편의성을 위해 제작한 JBBJ 작업 마법사입니다.
Gui, Add, Text, x12 y29 w70 h20 , 안녕하세요.
Gui, Add, GroupBox, x12 y69 w330 h190 , 기본 기능
Gui, Add, Text, x22 y119 w310 h50 , 자동으로 한/영 전환 명령을 내려`, 단축키를 입력할 때 한글로 입력되는 경우를 방지하여 작업 효율과 집중도를 높입니다. 지원 프로그램 목록을 참고해주세요.
Gui, Font, S13 Cgreen Bold, Verdana
Gui, Add, Text, x22 y89 w110 h30 , 자동 한/영전환
Gui, Add, Text, x22 y169 w150 h30 , 파일 경로 쉽게열기
Gui, Font, S10 Cblack, Verdana
Gui, Font, S10 Cblack, Verdana
Gui, Font, , 
Gui, Add, Button, x132 y89 w80 h30 , 초기 설정
Gui, Add, Button, x212 y89 w120 h30 , 지원 프로그램 목록
Gui, Font, S8, 
Gui, Add, CheckBox, x352 y69 w90 h30 , CheckBox
Gui, Add, Button, x12 y589 w140 h40 , 피드백 전송
Gui, Add, Button, x302 y589 w140 h40 , 창 닫기
Gui, Add, Button, x12 y269 w130 h40 , SVG변환기
Gui, Add, GroupBox, x12 y369 w140 h210 , GroupBox
Gui, Add, Button, x22 y399 w120 h50 , 딴짓하기
Gui, Add, Button, x22 y459 w120 h50 , 저녁메뉴 추천
Gui, Add, Button, x22 y519 w120 h50 , 오늘의 운세
Gui, Add, Button, x162 y269 w130 h40 , 컬러 픽커
Gui, Add, Button, x12 y319 w90 h40 , 연차관리
Gui, Add, Button, x312 y269 w130 h40 , 개발중
Gui, Font, S10, Verdana
Gui, Add, Text, x22 y199 w310 h50 , 파일 경로를 탐색기에 일일히 붙여넣기 할 필요 없이`, 파일 경로 선택 후 Ctrl+C 를 누르고 Caps Lock 키를 두번 누르면 해당 경로가 파일 탐색기에 열립니다.
Gui, Add, Progress, x162 y549 w280 h30 , 87
Gui, Add, Button, x352 y119 w90 h30 , 디버그 모드
Gui, Add, MonthCal, x182 y369 w230 h170 , 
Gui, Font, S8 Italic, Verdana
Gui, Add, Text, x182 y629 w260 h20 +Right, Powered by__Bae
Gui, Font, S10, Verdana
Gui, Add, Button, x112 y319 w110 h40 , 익명으로 칭찬하기
Gui, Font, S10, Verdana
Gui, Font, , Verdana
Gui, Font, S8 Cgray, Verdana
Gui, Add, Text, x352 y39 w90 h30 , 사실 제가쓰려고 만들었습니다
; Generated using SmartGUI Creator 4.0
Gui, Show, x572 y418 h664 w456, New GUI Window
Return

GuiClose:
ExitApp