; 초기 설정
backupDir := "C:\ScriptsAndShortCut_Backup"
if not FileExist(backupDir)
{
    FileCreateDir, %backupDir%
}

masterFolder := "G:\MasterFolder" ; 마스터 폴더 경로 설정

; GUI 구성
Gui, Add, ComboBox, vSelectedFile gUpdatePath, % GetFileList(masterFolder)
Gui, Add, Button, gCheckVersion, 파일 버전 검증
Gui, Add, Button, gUpdateFile, 파일 업데이트
Gui, Add, Edit, vLogEdit w400 h200 ReadOnly

Gui, Show,, 파일 업데이트 시스템
return