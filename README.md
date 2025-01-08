# Clokey_iOS
**`Clokey`는 `Closet`과 `Key`의 합성어로, 사용자의 옷장을 효율적으로 관리하고 활용할 수 있도록 도와주는 서비스입니다.**

Clokey iOS 팀과 컨벤션 규칙을 소개합니다.


## 👥 팀원
| 이름          | 역할              | GitHub ID           |
|---------------|-------------------|---------------------|
| 황상환         | iOS 팀 리더       | [@Hrepay](https://github.com/Hrepay) |
| 한태빈         | iOS 개발자        | [@taebin2](https://github.com/taebin2) |
| 한금준         | iOS 개발자        | [@Funital](https://github.com/Funital) |
| 소민준         | iOS 개발자        | [@sososominjun](https://github.com/sososominjun) |

<br>

## 🛠 프로젝트 컨벤션

### 🌿 브랜치 컨벤션
#### **Git-Flow 구조**
Git-Flow 방식을 따르며 브랜치 구조는 아래와 같습니다.
```zsh
main
  ├── develop
        ├── feature/login
        ├── feature/calendar_view
        ├── feature/edit_profile
        └── hotfix/critical_bug
```
-  **main** 
	- 항상 배포 가능한 상태를 유지하며, 최종 릴리즈 버전의 코드가 포함됩니다. 
-  **develop** 
	- 개발 중인 모든 기능이 병합되는 브랜치로, 안정적인 상태를 유지합니다. 
-  **feature/** 
	- 새로운 기능 개발을 위한 브랜치입니다.
	- 완료 후 develop 브랜치로 병합합니다. 
-  **release/** 
	- 배포 준비를 위한 브랜치입니다. 
	- 버그를 수정하고 최종 테스트를 거친 후 main에 병합합니다. 
- **hotfix/** 
	- main에서 발견된 긴급한 버그를 수정하기 위한 브랜치입니다. 
	- 수정 후 main과 develop에 병합됩니다.

<br>

### 🔧 브랜치 생성 및 작업 흐름
1. **`develop` 브랜치에서 작업할 브랜치를 생성**
	```zsh
	git checkout -b feature/<기능명>
	```
	- 예시: `feature/login`, `feature/sign-up`
	
2. **작업 후, 변경사항을 커밋**
	```zsh
	git add . 
	git commit -m "feat: 로그인 화면 UI 구현"
	```
3. **원격 저장소에 푸시**
	```zsh
	git push origin feature/<기능명>
	```
4. **푸시 후, PR을 생성**
	- PR 생성 시 `develop` 브랜치를 타겟으로 지정
	- 리뷰어를 지정하고 작업 내용 작성
<br>

### 💬 커밋 컨벤션

#### **커밋 메시지 형식**
```zsh
<타입>: <메시지>

- 세부사항1
- 세부사항2

#<이슈 번호>

```
-   **feat**: 새로운 기능 추가  
    예:  `feat: 로그인 화면 UI 구현`
-   **fix**: 버그 수정  
    예:  `fix: 로그인 오류 수정`
-   **chore**: 기타 작업 (빌드 설정, 패키지 추가 등)  
    예:  `chore: .gitignore 파일 수정`
- **docs**: 문서 추가/수정 (README, 주석 등)  
예: `docs: README 파일 수정`

<br>

### 🧹 코드 스타일 컨벤션
코드 스타일은 스타일쉐어에서 오픈소스로 배포하는 코딩 컨벤션 가이드를 활용합니다. <br> **코드 작성 전에 꼭 읽어주세요!** <br>
https://github.com/StyleShare/swift-style-guide

<br>

### 📂 디렉터리 구조 컨벤션
```zsh
Clokey/
├── Application/        # 앱 초기화 관련 파일
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Resources/          # 정적 리소스 (이미지, 폰트 등)
│   ├── Assets.xcassets
│   └── Fonts/
├── Sources/            # 앱 주요 소스
│   ├── Models/         # 데이터 모델 정의
│   ├── Views/          # UI 구성 요소
│   │   ├── Screens/    # 화면 단위 ViewController
│   │   └── Components/ # 재사용 가능한 UI 컴포넌트
│   ├── ViewModels/     # 뷰와 모델 간의 중간 로직 (데이터 가공, 상태 관리)
│   ├── Services/       # 네트워크 요청 및 API 호출
│   └── Utilities/      # 공통 함수 및 확장 기능
└── Supporting Files/   # 프로젝트 설정 파일
    └── Info.plist
```
> 이 디렉터리 구조는 프로젝트 요구사항에 따라 변경될 수 있습니다. <br>
> Signing & Capabilities에서 자신의 Apple ID로 Team을 변경해주세요. <br>
> Bundle Identifier를 자신의 것으로 수정해주세요. <br>

<br>

### ⚠️ 이슈 & PR 컨벤션
- **이슈와 PR은 템플릿을 참고해서 작성해주세요!**
- **리뷰어와 태그는 꼭 해주세요!**

<br>

### ⚙️ 사용 프레임워크
1. **Then (필수)**: 초기화 설정을 간결하게 도와주는 유틸리티 라이브러리
2. **SnapKit (필수)**: 코드 기반으로 Auto Layout을 작성할 수 있는 DSL 기반 라이브러리
3. **Alamofire (필수)**: HTTP 네트워크 요청과 응답 처리를 쉽게 해주는 라이브러리
4. **RxSwift (선택)**: 반응형 프로그래밍을 지원하며, 데이터와 이벤트 스트림을 처리하는 라이브러리
> 필수 프레임워크는 모든 팀원이 반드시 설치 및 활용해야 합니다. <br>
> 선택 프레임워크는 필요에 따라 사용할 수 있으며, 사용 시 커밋과 이슈를 통해 공지하도록 합니다.  <br>


