// lib/features/notifications/fcm_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notif_service.dart';
import 'package:flutter/foundation.dart';
import '../../DBtest/api_service.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  // 호출 위치: 앱 초기화 시 (예: main.dart의 init)
  Future<void> init({required String uid}) async {
    if (kIsWeb) {
      await _initWeb(uid);
    } else {
      await _initMobile(uid);
    }
  }

  Future<void> _initMobile(String uid) async {
    // Android/iOS: 권한 요청, 토큰 발급, Firestore 저장
    // 1) 권한 요청 (안드로이드 13 이상에서는 필요)
    NotificationSettings settings = await _fm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    

    // 토큰 발급
    try {
      String? token = await _fm.getToken();
      

      if (token != null && uid.isNotEmpty) {
        // Firestore 저장
        await saveToken(token, 'android');

        // 토픽 구독
        await _fm.subscribeToTopic('dailyReminder');
        
      } else {
        
      }
    } catch (e, s) {
      
      
    }

    // 3) 토큰 변경 시 업데이트
    _fm.onTokenRefresh.listen((newToken) async {
      await saveToken(newToken, 'android');
    });

    // 4) 포그라운드 메시지 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      
      // 여기서는 앱 포그라운드일 때 로컬 알림 표시
      LocalNotifService.showFromRemote(message);
    });

    // 5) 백그라운드에서 클릭하여 앱 열림 처리
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      
      handleMessageNavigation(message.data);
    });

    // 6) 앱이 완전히 종료되었다가 알림 통해 시작된 경우 처리
    RemoteMessage? initialMessage = await _fm.getInitialMessage();
    if (initialMessage != null) {
      handleMessageNavigation(initialMessage.data);
    }
  }

  Future<void> _initWeb(String uid) async {
    // Web: 권한 요청, 토큰 발급, Firestore 저장
    final status = await _fm.requestPermission();
    if (status.authorizationStatus != AuthorizationStatus.authorized) return;
    final token = await _fm.getToken(
      vapidKey:
          'YOUR_VAPID_KEY',
    );
    if (token != null) await saveToken(token, 'web');
  }

  void handleMessageNavigation(Map<String, dynamic> data) {
    
  }

  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await LocalNotifService.showFromRemote(message);
  }
}
