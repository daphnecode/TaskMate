# TaskMate

Flutter 기반 플래너 + 가상 펫 육성 서비스
(Android App & Web App 지원)

---

## 🚀 프로젝트 개요

TaskMate는 사용자의 작업 완료 여부에 따라 포인트를 지급하고,  
해당 포인트로 가상 펫을 성장시키는 동기부여 애플리케이션입니다.

- **Frontend**: Flutter (Android, Web)
- **Backend / DB**: Firebase  
  - Firebase Authentication  
  - Firestore  
  - Firebase Cloud Functions  
  - Firebase Hosting  
  - Firebase Emulator Suite (테스트용)

---

## 📂 프로젝트 구조

```

project-root/
├── lib/                 # Flutter 앱 소스 코드
├── functions/           # Firebase Cloud Functions
├── firestore.rules      # Firestore 보안 규칙
├── rules-test           # Firestore 보안 규칙 테스트
├── web/                 # Web 빌드 관련 파일
├── android/             # Android 빌드 관련 파일
├── assets/              # 이미지 / 아이콘 리소스
├── pubspec.yaml
└── README.md

```
---

## 📋 요구사항 (Requirements)

이 프로젝트를 실행하기 위해 필요한 환경은 다음과 같습니다:

- **Flutter SDK**: 3.32.4
- **Dart SDK**: 3.8.1
- **Node.js**: 22.16.0 이상 (Firebase CLI용)
- **Firebase Tools**: 14.22.0 이상
- **Android Studio**: version 2024.3 (Android 빌드용)
- **Chrome 브라우저** (Web 빌드용)

자세한 의존성 목록은 [`pubspec.yaml`](./pubspec.yaml)를 참고하세요.

---

## 🔧 Firebase 프로젝트 설정

이 프로젝트는 **Firebase Auth, Cloud Firestore, Cloud Functions, Firebase Hosting**을 기반으로 동작합니다.  
아래 절차는 새로운 Firebase 프로젝트를 생성하고, **Web App**과 **Android App**을 연결하는 방법을 설명합니다.

---

### 1. Firebase 프로젝트 생성

1. https://console.firebase.google.com 에 접속
2. **프로젝트 추가(Create Project)** 클릭
3. 프로젝트 이름 입력 (예: `taskmate`)
4. Google Analytics는 필요에 따라 활성화 또는 비활성화
5. 프로젝트 생성 완료 후 콘솔로 이동

### 2. Web App 등록 (Firebase Hosting + Flutter Web 빌드용)

1. Firebase Console 좌측 메뉴 → **Project Overview**  
2. **앱 추가 → Web(</>)** 선택
3. 앱 이름 입력 (예: `taskmate-web`)
4. Hosting 사용 여부 체크(선택)
5. 생성 버튼 클릭 후 제공된 설정 값을 확인

> Flutter에서는 Web 설정을 `firebase_options.dart`로 관리하므로 직접 JS 파일을 수정할 필요는 없음.

### 3. Android App 등록

1. Firebase Console → **Project Overview**
2. **앱 추가 → Android** 선택
3. 다음 정보를 입력:

   | 항목 | 예시 |
   |------|------|
   | Android 패키지명 | `com.example.taskmate` |
   | 앱 닉네임 | 선택 |
   | SHA-1 | 필요 시 입력 (Google 로그인/푸시 알림 등에서 필요) |

4. google-services.json 파일 다운로드
5. Flutter 프로젝트의 경로에 추가:
  android/app/google-services.json
6. android/build.gradle에 플러그인 등록

  plugins {
      // Google services plugin (Firebase)
      id("com.google.gms.google-services") version "4.4.3" apply false
  }
7. android/app/build.gradle에 플러그인 적용
  plugins {
      id("com.android.application")
      id("kotlin-android")
      id("com.google.gms.google-services") // Firebase 사용 시 필요
  }

### 4. lib/firebase_options.dart

1. firebase_options.dart 파일 작성.

```
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "YOUR_WEB_KEY",
        appId: "YOUR_WEB_ID",
        messagingSenderId: "YOUR_SENDER_ID",
        projectId: "YOUR_PROJECT_ID",
        authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
        storageBucket: "YOUR_PROJECT_ID.firebasestorage.app",
        measurementId: "YOUR_WEB_MEASUREMENT_ID",
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: "YOUR_ANDROID_API_KEY",
          appId: "YOUR_ANDROID_APP_ID",
          messagingSenderId: "YOUR_SENDER_ID",
          projectId: "YOUR_PROJECT_ID",
          storageBucket: "YOUR_PROJECT_ID.firebasestorage.app",
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS/macOS.',
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows/Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
```

2. Firebase 초기화 코드

main.dart에서 Firebase를 다음처럼 초기화합니다.

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

---

## ⚙️ Firebase Cloud Functions 초기 설정

이 프로젝트는 서버 로직을 위해 Firebase Cloud Functions를 사용합니다.

### 1. Functions 초기화

프로젝트 루트에서 Firebase Functions 환경을 초기화합니다.

```bash
firebase init functions
```

설정 항목:
- 언어: JavaScript 또는 TypeScript (본 프로젝트는 TypeScript 권장)
- ESLint: 선택
- Functions 디렉토리: 기본값(functions/)
- 첫 배포: 이후 firebase deploy에서 수행

### 2. Functions 배포

```bash
firebase deploy --only functions
```

---

## 🗄️ Firestore 초기 설정

서비스 데이터 저장을 위해 Cloud Firestore를 사용합니다.

### Firestore 생성

Firebase Console 
→ Firestore Database
→ Create Database
→ 모드: Production Mode
→ 로케이션 선택 후 생성

---

## 🔐 Firestore Security Rules 테스트 방법

이 프로젝트는 **Firestore Emulator**를 사용해 보안 규칙 테스트를 수행합니다.

### ▶ 테스트 실행
```bash
npm run test:rules
```

### ▶ 동작 방식

* `rules.test.js` 또는 `firestore.test.json`에 정의된 테스트 케이스 실행
* 규칙이 의도대로 허용/거부되는지 검증

### ▶ 출력 해석

* `✔` : 테스트 성공
* `PERMISSION_DENIED` : 금지되어야 하는 요청이면 정상
* 마지막 줄 `pass X / fail 0` → 모든 테스트가 정상적으로 통과된 것

---

# 🚀 배포 가이드 (Web & Android)

이 문서는 프로젝트를 Web(App)과 Android(App) 환경에 배포하는 과정을 정리한 가이드입니다.
Flutter SDK 기반으로 작성되었으며, Firebase Hosting 및 Android 빌드에 필요한 명령어들을 포함합니다.

---

## 로컬 개발 환경 실행

### 1. 패키지 설치

```bash
flutter pub get
```

### 2. 로컬 웹 실행

```bash
flutter run -d chrome
```

## ▶️ 3. 로컬 안드로이드 실행

```bash
flutter run -d android
```

---

## 🌐 Web App 배포 (Firebase Hosting)

### ✔️ 사전 준비

#### 1. Firebase CLI 로그인

```bash
firebase login
```

#### 2. Firebase 프로젝트 선택

```bash
firebase use --add
```

#### 3. Web 빌드 생성

```bash
flutter build web --release
```

빌드 결과는 아래 위치에 생성됨:

```
build/web/
```

---

## 🚀 Firebase Hosting에 배포

### 1. Firebase Hosting 초기 설정 (최초 1회)

```sh
firebase init hosting
```

설정 예시:

* **? What do you want to use as your public directory?**
  → `build/web`
* **? Configure as a single-page app? (rewrite all urls to /index.html)?**
  → `Yes`
* **Overwrite index.html?**
  → `No`

### 2. 배포 명령어

```bash
firebase deploy --only hosting
```

배포 완료 후 Firebase가 제공하는 URL 또는 커스텀 도메인에서 접속할 수 있습니다.

---

# 🤖 Android App 배포

Android 앱은 APK 파일을 직접 전달하여 테스트할 수 있습니다.

---

## 📱 Android APK 빌드

### ▶️ APK 빌드 (테스트 용도로 가장 많이 사용)

```sh
flutter build apk --release
```

생성 위치:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📦 아이콘 라이선스

이 프로젝트는 다음 아이콘을 사용합니다:

* **Basic Straight Lineal**
    * 라이선스: Freepik License (Attribution Required)
    * 출처:  [https://www.freepik.com](https://www.freepik.com)
> 본 프로젝트에서는 해당 아이콘을 Freepik License에 따라 사용하고 있으며, 아이콘의 저작권은 Freepik에 있습니다.


* **WebHostingHub Glyphs**
    * 라이선스: SIL Open Font License 1.1
    * 출처:  [https://www.webhostinghub.com/glyphs](https://www.webhostinghub.com/glyphs)

> 본 프로젝트에서는 해당 아이콘을 SIL Open Font License 1.1에 따라 사용하고 있으며, 아이콘의 저작권은 WebHostingHub에 있습니다.

---

## 📄 라이선스

본 프로젝트의 코드는 팀의 학습 및 시연 목적을 위해 사용됩니다.

---
