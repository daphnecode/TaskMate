// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
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
}