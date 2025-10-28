// web/firebase-messaging-sw.js

// ------------------------------------------------------------
// 1️⃣ Firebase SDK 로드 (Firebase 9 compat 버전 사용)
// ------------------------------------------------------------
importScripts('https://www.gstatic.com/firebasejs/9.22.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.2/firebase-messaging-compat.js');

// ------------------------------------------------------------
// 2️⃣ Firebase 프로젝트 구성
//    ⚠️ 아래 값들은 반드시 본인 Firebase 콘솔의 설정으로 교체하세요.
//    Firebase Console → 프로젝트 설정 → 일반 → "내 앱" → 웹 앱에서 확인 가능
// ------------------------------------------------------------
firebase.initializeApp({
  apiKey: "YOUR_WEB_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_WEB_APP_ID",
});

// ------------------------------------------------------------
// 3️⃣ Messaging 인스턴스 생성
// ------------------------------------------------------------
const messaging = firebase.messaging();

// ------------------------------------------------------------
// 4️⃣ 백그라운드 메시지 수신 처리
// ------------------------------------------------------------
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);

  // notification 필드가 있을 경우 제목/본문 사용
  const notificationTitle = payload.notification?.title || '알림';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png', // Flutter Web build 시 자동 포함됨
    data: payload.data || {}, // 클릭 시 사용할 데이터
  };

  // 알림 표시
  self.registration.showNotification(notificationTitle, notificationOptions);
});

// ------------------------------------------------------------
// 5️⃣ 알림 클릭 시 동작 처리 (예: 특정 페이지로 이동)
// ------------------------------------------------------------
self.addEventListener('notificationclick', function (event) {
  console.log('[firebase-messaging-sw.js] Notification click received.');

  event.notification.close();
  const urlToOpen = event.notification?.data?.url || '/';

  // 이미 열린 탭이 있다면 포커스, 없다면 새 탭 열기
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if (client.url.includes(urlToOpen) && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(urlToOpen);
      }
    })
  );
});
