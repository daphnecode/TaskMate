# taskmate

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 📦 아이콘 출처 및 라이선스

이 프로젝트에서 사용된 아이콘은 다음과 같습니다:

- WebHostingHub Glyphs
    ⤷ 라이선스: SIL Open Font License 1.1
    ⤷ 출처: https://www.webhostinghub.com/glyphs

> 본 프로젝트에서는 해당 아이콘을 SIL Open Font License 1.1에 따라 사용하고 있으며, 아이콘의 저작권은 WebHostingHub에 있습니다.

## 🔐 Firestore Security Rules 테스트 방법

이 프로젝트에서 사용된 보안 규칙 테스트 방법은 다음과 같습니다:

Firestore Emulator
⤷ 용도: 로컬 환경에서 Firestore 보안 규칙을 시뮬레이션 및 검증
⤷ 실행 명령어:

npm run test:rules


⤷ 동작: rules.test.js 또는 firestore.test.json에 정의된 테스트 케이스를 실행하여 규칙이 의도대로 동작하는지 확인

📊 출력 해석

✔ : 테스트가 성공했음을 의미합니다.

PERMISSION_DENIED 로그가 찍히더라도, 해당 요청이 규칙에 의해 거부되는 것을 기대한 경우라면 정상 동작입니다.

마지막에 pass X / fail 0 이면 모든 보안 규칙이 의도대로 작동한 것입니다.