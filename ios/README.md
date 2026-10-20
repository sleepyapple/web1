# Jaerim's homp — 아이폰 앱

웹사이트(`1.html` ~ `7.html`)와 같은 내용을 담은 **아이폰 전용 앱**이에요.
여기에 **공유 확장(Share Extension)**이 들어 있어서, 밀리의서재에서 **공유** 버튼을 누르면
공유 목록에 **"Jaerim's homp"**가 나오고, 문장이나 링크를 앱에 저장할 수 있어요.

## 화면 구성

| 탭 | 내용 |
|---|---|
| **시간표** | 웹사이트의 MON ~ SUN 페이지 그대로. 블로그 링크 포함, 앱을 열면 오늘 요일이 먼저 보임 |
| **공유함** | 밀리의서재 등에서 공유한 문장 / 링크 / 이미지 목록. 메모 추가, 밀어서 삭제, 다시 공유 가능 |

## 밀리의서재에서 쓰는 법

1. 밀리의서재에서 책을 읽다가 문장을 길게 눌러 선택한 뒤 **공유**(또는 책 화면의 공유 버튼)를 눌러요.
2. 카카오톡 같은 앱 목록이 아니라 iOS 공유 시트가 떠야 해요. 밀리 자체 공유 메뉴가 먼저 나오면 **더보기** / **기타**를 눌러요.
3. 앱 줄에서 **Jaerim's homp**를 눌러요. 처음엔 안 보일 수 있으니 맨 끝 **더보기**에서 켜 주세요.
4. 메모를 적고 싶으면 적고 **저장** → 앱의 **공유함** 탭에서 확인해요.

> 공유 확장은 텍스트, 웹 링크, 이미지 1장을 받아요. 밀리의서재가 공유 시트로 넘겨주는 형식이 이 중 하나라면 동작해요.
> (밀리의서재가 넘기는 정확한 형식은 앱 버전에 따라 다를 수 있어요.)

## 아이폰에 설치하기 (Mac 필요)

준비물: **Mac + Xcode 16 이상**, 아이폰(iOS 17 이상), Apple ID

1. 이 저장소를 Mac에 내려받고 `ios/JaerimHomp.xcodeproj`를 Xcode로 열어요.
2. 왼쪽에서 맨 위 **JaerimHomp** 프로젝트를 누르고 **Build Settings** 탭 → 검색창에 `BASE_BUNDLE_ID` 입력.
   `com.sleepyapple.jaerimhomp`를 나만의 값으로 바꿔요 (예: `com.내아이디.jaerimhomp`).
   앱 ID, 공유 확장 ID, App Group 이름이 이 값 하나로 같이 바뀌어요.
3. **JaerimHomp** 타깃과 **ShareExtension** 타깃 각각 **Signing & Capabilities** 탭에서 **Team**에 내 Apple ID를 선택해요.
   (App Groups 항목에 `group.<위에서 정한 값>`이 보이면 됨. 빨간 경고가 나오면 체크박스를 한 번 눌러 새로고침)
4. 아이폰을 USB로 연결하고, 위쪽에서 기기를 고른 뒤 ▶︎ (Run).
5. 처음 실행할 때 아이폰에서 **설정 → 일반 → VPN 및 기기 관리**에서 개발자 앱을 신뢰해 줘요.

> 무료 Apple ID로 설치하면 7일마다 Xcode에서 다시 설치해야 해요.
> 계속 쓰거나 App Store에 올리려면 Apple Developer Program(유료)이 필요해요.

## 폴더 구조

```
ios/
├── JaerimHomp.xcodeproj      Xcode 프로젝트 (scripts/generate_project.rb 로 생성)
├── JaerimHomp/               앱 본체
│   ├── JaerimHompApp.swift   앱 시작점, 탭 구성
│   ├── Schedule.swift        요일별 내용 (웹사이트 1~7.html 내용)
│   ├── ScheduleView.swift    시간표 화면
│   ├── SharedListView.swift  공유함 화면
│   └── Assets.xcassets       앱 아이콘, 색상
├── ShareExtension/           공유 시트에 뜨는 확장
│   └── ShareViewController.swift
├── Shared/                   앱과 확장이 같이 쓰는 코드 (저장소)
└── scripts/generate_project.rb
```

시간표 내용을 바꾸려면 `JaerimHomp/Schedule.swift`만 고치면 돼요.

## 프로젝트 파일 다시 만들기

파일을 추가하거나 빌드 설정을 바꿨다면:

```sh
gem install xcodeproj
ruby scripts/generate_project.rb
```
