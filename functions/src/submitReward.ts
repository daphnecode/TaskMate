import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { db } from "./firebase";


export const submitReward = onCall(async (req) => {
  const uid = (req.auth?.uid as string) || (req.data.uid as string);
  const earned = Number(req.data.earned);
  const dateKey = String(req.data.dateKey);

  if (!uid || !Number.isFinite(earned) || !dateKey) {
    throw new HttpsError("invalid-argument", "uid, earned, dateKey are required");
  }
  if (earned <= 0) return { ok: true, skipped: true };

  const userRef = db.collection("Users").doc(uid);
  const logRef = userRef.collection("log").doc(dateKey);

  await db.runTransaction(async (tx) => {
    const logSnap = await tx.get(logRef);
    const already = logSnap.exists && logSnap.data()?.rewarded === true;
    if (already) return;

    tx.update(userRef, {
      currentPoint: admin.firestore.FieldValue.increment(earned),
      gotPoint: admin.firestore.FieldValue.increment(earned),
    });
    tx.set(
      logRef,
      {
        rewarded: true,
        earnedPoints: earned,
        rewardedBy: "function",
        rewardedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  });

  return { ok: true };
});
