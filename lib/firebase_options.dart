// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if(kIsWeb) {
      return const FirebaseOptions(
        apiKey: "YOUR_WEB_API_KEY",
        appId: "YOUR_WEB_APP_ID",
        messagingSenderId: "YOUR_SENDER_ID",
        projectId: "YOUR_PROJECT_ID",
        authDomain: "YOUR_PROJECT.firebaseapp.com",
        storageBucket: "YOUR_PROJECT.appspot.com",
        measurementId:  "YOUR_WEB_MEASUREMENT_ID"
      );
    }
     switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // ✅ 안드로이드 설정
        return const FirebaseOptions(
          apiKey: "YOUR_ANDROID_API_KEY",
          appId: "YOUR_ANDROID_APP_ID",
          messagingSenderId: "YOUR_SENDER_ID",
          projectId: "YOUR_PROJECT_ID",
          storageBucket: "YOUR_PROJECT.appspot.com",
        );

      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // 필요하다면 iOS/macOS 값도 넣기
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
