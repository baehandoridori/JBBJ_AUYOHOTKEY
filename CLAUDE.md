# CLAUDE.md

> 이 파일은 Claude Code AI 어시스턴트가 프로젝트를 이해하는 데 사용됩니다.

## 프로젝트 개요

JBBJ 작업마법사는 JBBJ 스튜디오 팀의 작업 효율을 높이기 위한 AutoHotkey 기반 자동화 도구입니다.

- **사용자**: JBBJ 스튜디오 팀원 (비개발자)
- **환경**: Windows, 공유 G드라이브 사용
- **언어**: AutoHotkey v1.1 (메인), AutoHotkey v2 (UIA)

## 폴더 구조

```
소스/       - 핵심 스크립트 (메인, 설치도우미, 파일공유)
유틸/       - 보조 유틸리티
게임/       - 미니게임
설정/       - 설정 파일 (settings.ini가 핵심)
라이브러리/ - 외부 라이브러리 (UIA 등)
백업/       - 이전 버전 보관
```

## 코딩 컨벤션

### AutoHotkey v1.1
- 전역 변수: `g_` 접두사 사용 (예: `g_RootDir`)
- 함수명: PascalCase (예: `InitializePaths()`)
- 섹션 구분: `; [섹션명]` 형식의 주석 블록
- 경로: 하드코딩 금지, `settings.ini`에서 로드

### 주석
- 한국어 주석 사용
- 섹션 시작: `; ----------` 구분선 사용
- 기능 블록: `; [기능명 - 단축키]` 형식

### 설정 파일
- `settings.ini`: 외부 경로 (G드라이브 등)
- `alias.ini`: 프로그램 표시명
- `program_classes.txt`: 한영전환 대상 프로그램

## 핵심 파일

| 파일 | 설명 |
|------|------|
| `소스/JBBJ_작업도우미_배포용_v2_0.ahk` | 메인 스크립트 |
| `소스/경로공유_UIA최종_수정1.ahk` | Slack 파일 공유 (AHK v2) |
| `설정/settings.ini` | 경로 설정 (★ 중요) |

## 주요 기능

1. **자동 한영전환**: 특정 프로그램에서 마우스 이동 시 영문 전환
2. **타임 트래커**: 프로그램별 사용 시간 추적
3. **파일 공유**: Slack으로 파일 전송 (UIA 사용)
4. **경로 열기**: 텍스트 경로를 탐색기로 열기

## 개발 시 주의사항

1. **경로 하드코딩 금지**
   - 모든 외부 경로는 `settings.ini`에서 로드
   - `A_ScriptDir` 기반 상대 경로 사용

2. **버전 관리**
   - 구버전은 `백업/` 폴더로 이동
   - 파일명에 버전 포함 (예: `_v2_0.ahk`)

3. **호환성**
   - AHK v1.1과 v2 혼용 중 (v2는 파일 공유만)
   - 팀원 PC는 동일한 G드라이브 경로 사용

4. **비활성화된 기능**
   - 바로가기 생성 (`Ctrl+CapsLock`) - 주석처리됨
   - 바로가기 원본열기 (`Alt+I`) - 주석처리됨

## 자주 사용하는 명령어

```bash
# Git 작업
git add . && git commit -m "메시지" && git push

# 팀 배포
# Git에서 G드라이브로 수동 복사 후 팀원에게 바로가기 배포
```

## TODO 관리

할 일 목록은 `todo.md` 파일에서 관리합니다.

## 참고 자료

- [AutoHotkey v1 문서](https://www.autohotkey.com/docs/v1/)
- [AutoHotkey v2 문서](https://www.autohotkey.com/docs/v2/)
- [UIA 라이브러리](https://github.com/Descolada/UIA-v2)
