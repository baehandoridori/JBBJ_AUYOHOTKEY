# 집중 모드 (FocusMode)

활성 창을 제외한 모든 영역을 어둡게 처리하여 집중력을 높여주는 프로그램입니다.

## 기능

- 멀티모니터 지원 (모든 모니터에 오버레이)
- 활성 창 영역만 투명하게 표시
- 실시간 창 위치/크기 추적
- 오퍼시티 조절 (10% ~ 100%)
- 핫키 토글 (Ctrl+Alt+F)
- 더블클릭으로 종료
- 트레이 아이콘 지원

## 사용 방법

1. 집중할 창을 클릭하여 활성화
2. `Ctrl+Alt+F` 누르기 (또는 설정창에서 "집중 모드 시작")
3. 활성 창 외의 모든 영역이 어둡게 됨
4. 종료: `Ctrl+Alt+F` 다시 누르기 또는 어두운 영역 더블클릭

## 트레이 아이콘 메뉴

- **설정 열기**: 설정 창 표시
- **집중 모드 켜기/끄기**: 토글
- **종료**: 프로그램 종료

## 빌드 방법

### 요구사항

- .NET 6.0 SDK ([다운로드](https://dotnet.microsoft.com/download/dotnet/6.0))

### 개발/테스트용 빌드

```bash
cd FocusMode
dotnet build
dotnet run
```

### 배포용 빌드 (Self-Contained)

팀원들이 아무것도 설치할 필요 없이 exe 파일만으로 실행 가능:

```bash
cd FocusMode
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o publish
```

결과물: `publish/FocusMode.exe` (약 60~80MB)

### 클린 빌드

문제가 있을 경우:

```bash
dotnet clean
dotnet build
```

## 파일 구조

```
FocusMode/
├── FocusMode.csproj     # 프로젝트 파일
├── App.xaml             # 앱 정의
├── App.xaml.cs          # 트레이 아이콘, 앱 시작
├── MainWindow.xaml      # 설정 창 UI
├── MainWindow.xaml.cs   # 핫키, 창 추적 로직
├── OverlayWindow.xaml   # 오버레이 UI
├── OverlayWindow.xaml.cs# 오버레이 로직
└── publish/             # 배포용 exe 출력 폴더
```

## 단축키

| 단축키 | 기능 |
|--------|------|
| Ctrl+Alt+F | 집중 모드 토글 |
| 더블클릭 (어두운 영역) | 집중 모드 종료 |
