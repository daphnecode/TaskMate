// functions/src/submitReward.ts
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "./firebase.js";
import { FieldValue, type Transaction } from "firebase-admin/firestore";

/**
 * 보상 지급 (asia-northeast3)
 * - Users/{uid} 보장(set merge)
 * - currentPoint, gotPoint 증가
 * - Users/{uid}/log/{dateKey}에 rewarded 기록 (중복 방지)
 */
export const submitRewardAN3 = onCall(
  { region: "asia-northeast3" },
  async (req) => {
    const uid = (req.auth?.uid as string) || (req.data.uid as string);
    const earned = Number(req.data.earned);
    const dateKey = String(req.data.dateKey);

    if (!uid || !Number.isFinite(earned) || !dateKey) {
      throw new HttpsError("invalid-argument", "uid, earned, dateKey are required");
    }
    if (earned <= 0) return { ok: true, skipped: true };

    const userRef = db.collection("Users").doc(uid);
    const logRef = userRef.collection("log").doc(dateKey);

    await db.runTransaction(async (tx: Transaction) => {
      const logSnap = await tx.get(logRef);
      const already = logSnap.exists && logSnap.data()?.rewarded === true;
      if (already) return;

      // Users/{uid} 보장
      tx.set(userRef, {}, { merge: true });

      // 포인트 증가
      tx.set(
        userRef,
        {
          currentPoint: FieldValue.increment(earned),
          gotPoint: FieldValue.increment(earned),
        },
        { merge: true }
      );

      // 로그 표식
      tx.set(
        logRef,
        {
          rewarded: true,
          earnedPoints: earned,
          rewardedBy: "submitRewardAN3",
          rewardedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    });

    return { ok: true };
  }
);
