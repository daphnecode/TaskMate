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
    

    // 토큰 발급
    try {
      String? token = await _fm.getToken();
      

      if (token != null && uid.isNotEmpty) {
        // Firestore 저장
        await saveTokenToFirestore(uid, token);

        // 토픽 구독
        await _fm.subscribeToTopic('dailyReminder');
        
      } else {
        
      }
    } catch (e, s) {
      
      
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
      
      handleMessageNavigation(message.data);
    });

    // 6) 앱이 완전히 종료되었다가 알림 통해 시작된 경우 처리
    RemoteMessage? initialMessage = await _fm.getInitialMessage();
    if (initialMessage != null) {
      handleMessageNavigation(initialMessage.data);
    }
  }

  Future<void> saveTokenToFirestore(String uid, String token) async {
    final userDoc = _fs.collection('Users').doc(uid);
    await userDoc.set({
      'fcmToken': token,
      'platform': Platform.isAndroid ? 'android' : 'other',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('Saved latest token for $uid: $token');
  }

  void handleMessageNavigation(Map<String, dynamic> data) {
    
  }

  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await LocalNotifService.showFromRemote(message);
  }
}
