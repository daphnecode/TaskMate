import { pubsub as pubsubV2 } from "firebase-functions/v2";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
//TS가 schedule 속성을 못 찾아서, 함수에 any로 타입 캐스팅
const pubsub: any = pubsubV2;

/**
 * 매일 새벽 3시(서울 시간)에 펫 상태 감소
 * - 배고픔 +10 (최대 100)
 * - 체력 -5 (최소 0)
 */
export const updateStatus = pubsub.schedule("0 3 * * *", {
  timeZone: "Asia/Seoul",      // 서울 시간
  region: "asia-northeast3",   // 서울 리전
})
.onRun(async () => {
  console.log("펫 상태 감소 작업 시작 (v2 API)");

  const petsRef = db.collection("pets");
  const snapshot = await petsRef.get();

  const batch = db.batch();
  snapshot.forEach((doc) => {
    const pet = doc.data();
    const hunger = Math.min((pet.hunger || 0) - 10, 100);
    const health = Math.max((pet.health || 100) - 5, 0);

    batch.update(doc.ref, {
      hunger,
      health,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
  console.log(`총 ${snapshot.size}마리 펫 상태 업데이트 완료`);

  return null;
});
