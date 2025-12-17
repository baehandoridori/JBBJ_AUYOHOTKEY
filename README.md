<p align="center">
  <h1 align="center">JBBJ 작업마법사</h1>
  <p align="center">
    <strong>JBBJ 스튜디오 팀의 작업 효율을 높이는 자동화 도구</strong>
  </p>
  <p align="center">
    AutoHotkey 기반 | Windows 전용
  </p>
</p>

---

## 목차

- [빠른 시작](#빠른-시작)
- [주요 기능](#주요-기능)
- [폴더 구조](#폴더-구조)
- [설정](#설정)
- [설치 방법](#설치-방법)
- [버전](#버전)
- [문서](#문서)
- [문의](#문의)

---

## 빠른 시작

```bash
1. AutoHotkey v1.1 설치
2. 소스/JBBJ_작업도우미_배포용_v2_0.ahk 실행
3. 끝!
```

---

## 주요 기능

### 작업도우미 단축키

| 단축키 | 기능 | 설명 |
|:------:|------|------|
| `CapsLock` x2 | 경로 열기 | 텍스트 경로 드래그 후 더블탭 |
| `Alt` + `F12` | 파일 공유 | 선택한 파일을 Slack으로 전송 |
| `Ctrl+Shift+V` | 경로 링크 | Slack에서 G:\ 경로를 클릭 가능한 링크로 붙여넣기 |
| `Alt` + `` ` `` | 창 고정 | 현재 창을 항상 위에 표시 |
| `Win` + `G` | 게임 | 미니게임 실행 |

### 자동 기능

| 기능 | 설명 |
|------|------|
| 자동 한영전환 | 지정된 프로그램에서 마우스 이동 시 영문 전환 |
| 타임 트래커 | 프로그램별 사용 시간 자동 기록 |
| 자리비움 감지 | 2분 미입력 시 자동 표시 |
| 경로 감지 | G:\ 경로 복사 시 자동 감지하여 Slack 하이퍼링크 준비 |

### Slack 경로 공유 (jbbj:// 프로토콜)

G드라이브 경로를 Slack에서 클릭 가능한 링크로 공유하는 기능

**사용 방법:**
```
1. 파일 탐색기에서 G:\ 경로 복사 (Ctrl+C)
2. 툴팁 확인: "경로 감지됨"
3. Slack 채팅창에서 Ctrl+Shift+V
4. 완료! 경로가 클릭 가능한 하이퍼링크로 표시됨
```

**동작 원리:**
```
복사: G:\공유 드라이브\JBBJ 자료실\파일.psd
         ↓
Slack에 표시: G:\공유 드라이브\JBBJ 자료실\파일.psd (클릭 가능)
         ↓
클릭 시: 파일 탐색기에서 해당 경로 열림
```

---

## 폴더 구조

```
JBBJ_AUYOHOTKEY/
│
├── 소스/           # 메인 스크립트
├── 유틸/           # 유틸리티 도구
├── 게임/           # 미니게임
├── 설정/           # 설정 파일 (★)
├── 라이브러리/     # 외부 라이브러리
└── 백업/           # 이전 버전
```

<details>
<summary><b>상세 구조 보기</b></summary>

```
소스/
├── JBBJ_작업도우미_배포용_v2_0.ahk   # 메인
├── JBBJ_설치도우미_1_4.ahk          # 설치 도우미
└── 경로공유_UIA최종_수정1.ahk       # Slack 파일 공유

유틸/
├── 마우스컬러_V1_4.ahk    # 컬러 픽커
├── 돋보기.ahk            # 화면 확대
├── 컷넘버입력기.ahk      # MOHO용
├── 피드백.ahk            # 피드백 전송
├── 익명_칭찬합시다.ahk    # 익명 칭찬
├── 오늘의운세.ahk        # 운세
└── 저녁메뉴추천.ahk      # 메뉴 추천

게임/
├── 스네이크게임.ahk
├── 숫자야구게임_v2.ahk
└── 숫자게임.ahk

설정/
├── settings.ini          # 경로 설정 (★ 이것만 수정)
├── alias.ini             # 프로그램 별명
├── program_classes.txt   # 한영전환 대상
└── config.ini            # 기타 설정
```

</details>

---

## 설정

### settings.ini (경로 설정)

> 경로가 바뀌면 이 파일만 수정하세요

```ini
[경로]
자료실=G:\공유 드라이브\JBBJ 자료실
설치파일=G:\공유 드라이브\JBBJ 자료실\PC 설치 자료들

[AutoHotkey]
AHKv2=C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe
```

### alias.ini (타임트래커 표시명)

```ini
[Alias]
chrome=크롬
afterfx=애프터이펙트
moho=모호
```

### program_classes.txt (자동 한영전환)

```
ahk_class AE_CApplication_25.0
ahk_class Photoshop
ahk_class Premiere Pro
```

---

## 설치 방법

### 요구사항
- Windows 10/11
- AutoHotkey v1.1
- AutoHotkey v2 (파일 공유 기능)

### 설치

1. **AutoHotkey 설치**
   - [autohotkey.com](https://www.autohotkey.com/) 에서 다운로드

2. **폴더 복사**
   - 이 폴더를 G드라이브에 복사

3. **실행**
   - `소스/JBBJ_작업도우미_배포용_v2_0.ahk` 더블클릭

4. **(선택) 자동 시작**
   - 바로가기를 시작프로그램 폴더에 추가
   - `Win+R` → `shell:startup`

---

## 버전

| 버전 | 내용 |
|------|------|
| v2.0 | 설정 파일 분리, 폴더 구조 개선 |
| v1.x | 기능 안정화 |
| v0.x | 초기 개발 |

---

## 문서

- [todo.md](./todo.md) - 할 일 목록
- [CLAUDE.md](./CLAUDE.md) - AI 어시스턴트 가이드
- [DEVLOG.md](./DEVLOG.md) - 개발 일지

---

## 문의

스크립트 관련 문의는 **배한솔**에게 연락해주세요.
