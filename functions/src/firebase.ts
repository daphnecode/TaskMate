import * as admin from "firebase-admin";

// 이미 초기화되어 있는지 체크
if (!admin.apps.length) {
  admin.initializeApp();
}

export const db = admin.firestore();
