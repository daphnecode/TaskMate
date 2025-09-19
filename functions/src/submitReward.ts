import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { db } from "./firebase";

/**
 * 보상 지급 (아시아 리전 고정)
 * - Users/{uid} 가 없을 수 있으므로 먼저 set(merge:true)로 보장
 * - currentPoint, gotPoint 증가
 * - Users/{uid}/log/{dateKey} 에 rewarded 기록
 */
export const submitRewardAN3 = onCall(
  { region: "asia-northeast3" },
  async (req) => {
    const uid = (req.auth?.uid as string) || (req.data.uid as string);
    const earned = Number(req.data.earned);
    const dateKey = String(req.data.dateKey);

    if (!uid || !Number.isFinite(earned) || !dateKey) {
      throw new HttpsError(
        "invalid-argument",
        "uid, earned, dateKey are required",
      );
    }
    if (earned <= 0) return { ok: true, skipped: true };

    const userRef = db.collection("Users").doc(uid);
    const logRef = userRef.collection("log").doc(dateKey);

    await db.runTransaction(async (tx) => {
      const logSnap = await tx.get(logRef);
      const already = logSnap.exists && logSnap.data()?.rewarded === true;
      if (already) return;

      // Users/{uid} 보장
      tx.set(userRef, {}, { merge: true });

      // 포인트 증가
      tx.set(
        userRef,
        {
          currentPoint: admin.firestore.FieldValue.increment(earned),
          gotPoint: admin.firestore.FieldValue.increment(earned),
        },
        { merge: true },
      );

      // 로그 표식
      tx.set(
        logRef,
        {
          rewarded: true,
          earnedPoints: earned,
          rewardedBy: "submitRewardAN3",
          rewardedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    });

    return { ok: true };
  },
);
