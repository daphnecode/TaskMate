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
├── firestore.indexes    # Firestore 인덱스 설정
├── web/                 # Web 빌드 관련 파일
├── android/             # Android 빌드 관련 파일
├── assets/              # 이미지 / 아이콘 리소스
└── README.md

````

---

## 🔐 Firestore Security Rules 테스트 방법

이 프로젝트는 **Firestore Emulator**를 사용해 보안 규칙 테스트를 수행합니다.

### ▶ 테스트 실행

```bash
npm run test:rules
````

### ▶ 동작 방식

* `rules.test.js` 또는 `firestore.test.json`에 정의된 테스트 케이스 실행
* 규칙이 의도대로 허용/거부되는지 검증

### ▶ 출력 해석

* `✔` : 테스트 성공
* `PERMISSION_DENIED` : 금지되어야 하는 요청이면 정상
* 마지막 줄 `pass X / fail 0` → 모든 테스트가 정상적으로 통과된 것

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

```

---
