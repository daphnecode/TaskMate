// lib/features/notifications/fcm_service.dart
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_notif_service.dart';
import 'package:flutter/material.dart';

class FcmService {
  final FirebaseMessaging _fm = FirebaseMessaging.instance;
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  // 호출 위치: 앱 초기화 시 (예: main.dart의 init)
  Future<void> init({required String uid}) async {
    // 1) 권한 요청 (안드로이드 13 이상에서는 필요)
    NotificationSettings settings = await _fm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    

    // 2) 토큰 발급 및 저장
    String? token = await _fm.getToken();
    if (token != null) {
      await saveTokenToFirestore(uid, token);
    }

    // 3) 토큰 변경 시 업데이트
    _fm.onTokenRefresh.listen((newToken) async {
      await saveTokenToFirestore(uid, newToken);
    });

    // 4) 포그라운드 메시지 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      
      // 여기서는 앱 포그라운드일 때 로컬 알림 표시
      LocalNotifService.showFromRemote(message);
    });

    // 5) 백그라운드에서 클릭하여 앱 열림 처리
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      
      // 딥링크/네비게이션 처리 (앱의 navigatorKey 등으로 처리)
      handleMessageNavigation(message.data);
    });

    // 6) 앱이 완전히 종료되었다가 알림 통해 시작된 경우 처리
    RemoteMessage? initialMessage = await _fm.getInitialMessage();
    if (initialMessage != null) {
      handleMessageNavigation(initialMessage.data);
    }
  }

  Future<void> saveTokenToFirestore(String uid, String token) async {
    final tokenDoc = _fs
        .collection('Users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token);
    await tokenDoc.set({
      'token': token,
      'platform': Platform.isAndroid ? 'android' : 'other',
      'createdAt': FieldValue.serverTimestamp(),
    });
    debugPrint('Saved token for $uid: $token');
  }

  void handleMessageNavigation(Map<String, dynamic> data) {
    // 예: data['screen'] == 'task_detail' && data['taskId'] 존재하면 네비게이션
    // 앱 네비게이션 코드에 맞게 구현하세요.
    
  }

  // Background handler must be a top-level function — 아래와 같이 외부에 함수로 정의 가능
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    // 백그라운드에서 도착한 메시지 처리 (필요시 로컬 노티로 표시)
    await LocalNotifService.showFromRemote(message);
  }
}
