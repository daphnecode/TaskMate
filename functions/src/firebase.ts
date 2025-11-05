import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
// (선택) 세션 선점 시 토큰 revoke 등에 쓰려면 아래도 같이 export 가능
import { getAuth } from "firebase-admin/auth";

if (getApps().length === 0) {
  initializeApp();
}

export const db = getFirestore();
// serverTimestamp, increment 등에 사용
export { FieldValue };
// (선택) 필요 시 사용
export { getAuth };