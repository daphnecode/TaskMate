// v2 Firestore trigger
import { onDocumentWritten } from "firebase-functions/v2/firestore";
// v2 HTTPS onRequest
import { onRequest } from "firebase-functions/v2/https";

import admin from "firebase-admin";
import express from "express";
import cors from "cors";

import { db } from "./firebase";
import repeatRouter from "./planner/repeat_function";

// Admin init (중복 방지)
if (!admin.apps.length) {
  admin.initializeApp();
}

// KST YYYY-MM-DD
function kstDateStr(date = new Date()): string {
  const kst = new Date(date.getTime() + 9 * 60 * 60 * 1000);
  const y = kst.getUTCFullYear();
  const m = String(kst.getUTCMonth() + 1).padStart(2, "0");
  const d = String(kst.getUTCDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

// ===== Firestore 트리거 =====
export const onTaskSubmitted = onDocumentWritten(
  "Users/{userId}/log/{logId}",
  async (event) => {
    const userId = event.params.userId;
    const after = event.data?.after.exists ? event.data?.after.data() : null;
    if (!after) return;

    const afterSubmitted = Boolean(after.submitted);
    if (!afterSubmitted) return;

    const afterCompleted = Number(after.completedCount || 0);
    const afterCredited = Number(after.creditedCompleted || 0);

    const statsRef = db
      .collection("Users")
      .doc(userId)
      .collection("stats")
      .doc("summary");
    const logRef = db
      .collection("Users")
      .doc(userId)
      .collection("log")
      .doc(event.params.logId);

    const todayStr = kstDateStr();

    await db.runTransaction(async (tx) => {
      const [statsSnap, logSnap] = await Promise.all([
        tx.get(statsRef),
        tx.get(logRef),
      ]);

      let totalCompleted = 0;
      let streakDays = 0;
      let lastUpdatedDateStr: string | null = null;

      if (statsSnap.exists) {
        const s = statsSnap.data()!;
        totalCompleted = Number(s.totalCompleted || 0);
        streakDays = Number(s.streakDays || 0);
        lastUpdatedDateStr = (s.lastUpdatedDateStr as string) || null;
      }

      let delta = Math.max(0, afterCompleted - afterCredited);

      if (delta === 0 && afterCompleted > 0) {
        const neverUpdatedStats =
          !statsSnap.exists || lastUpdatedDateStr === null;
        const neverCreditedInLog =
          !logSnap.exists || !("creditedCompleted" in (logSnap.data() || {}));
        if (neverUpdatedStats && neverCreditedInLog) {
          delta = afterCompleted;
          console.log(
            `[bootstrap] user=${userId}, log=${event.params.logId}, force delta=${delta}`,
          );
        }
      }

      // streak 계산
      let newStreak = streakDays;
      let shouldUpdateStreak = false;

      if (lastUpdatedDateStr === null) {
        newStreak = 1;
        shouldUpdateStreak = true;
      } else if (lastUpdatedDateStr !== todayStr) {
        const last = new Date(lastUpdatedDateStr);
        const today = new Date(todayStr);
        const diffDays = Math.round(
          (today.getTime() - last.getTime()) / (1000 * 60 * 60 * 24),
        );
        newStreak = diffDays === 1 ? streakDays + 1 : 1;
        shouldUpdateStreak = true;
      }

      const newTotalCompleted = totalCompleted + delta;

      const baseStatsUpdate: Record<string, unknown> = {
        totalCompleted: newTotalCompleted,
        lastUpdated: admin.firestore.Timestamp.now(),
        lastUpdatedDateStr: lastUpdatedDateStr ?? todayStr,
      };

      const statsUpdate: FirebaseFirestore.UpdateData<FirebaseFirestore.DocumentData> =
        {
          ...baseStatsUpdate,
          ...(shouldUpdateStreak
            ? { streakDays: newStreak, lastUpdatedDateStr: todayStr }
            : {}),
        };

      tx.set(statsRef, statsUpdate, { merge: true });

      if (delta > 0 || afterCredited === 0) {
        tx.set(
          logRef,
          { creditedCompleted: afterCredited + delta },
          { merge: true },
        );
      }
    });
  },
);

// ===== Express 앱 (v2 onRequest) =====
const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// 라우터 마운트
app.use("/repeatList", repeatRouter);

// 필요 시 다른 라우터도 추가 가능
// app.use("/dailyList", dailyRouter);

export const api = onRequest({ region: "asia-northeast3" }, app);

// 기존 export 유지
export * from "./submitReward";
export { updateStatus } from "./pet/updateStatus";
export { submitPetExpAN3 } from "./submitPetEXP";
