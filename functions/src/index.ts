// functions/src/index.ts
// v2 Firestore trigger
import { onDocumentWritten } from "firebase-functions/v2/firestore";
// v2 HTTPS onRequest
import { onRequest } from "firebase-functions/v2/https";

import express from "express";
import cors from "cors";

// 모듈식 Firestore 유틸/타입
import { Timestamp } from "firebase-admin/firestore";
import type { Transaction, UpdateData, DocumentData } from "firebase-admin/firestore";

import { db } from "./firebase.js";
import repeatRouter from "./planner/repeat_function.js";
// import plannerRouter from "./planner/planner_function.js";
import dailyRouter from "./planner/daily_function.js";
import petRouter from "./pet/petload.js";
import itemRouter from "./pet/itemload.js";

// ===== Express 앱 (v2 onRequest) =====
const app = express();

// ✅ CORS는 제일 먼저 + 프리플라이트 허용
app.use(cors({ origin: true, credentials: true }));
app.options(/.*/, cors({ origin: true, credentials: true }));

// 바디 파서
app.use(express.json());

// 라우터 마운트
// - /repeatList/...  (예: /repeatList/read/:userId, /repeatList/save/:userId, /repeatList/add/:userId)
// - /dailyList/...   (노션 스펙 호환: /dailyList/add/:userId)

app.use("/daily", dailyRouter);
// app.use("/planner", plannerRouter);
app.use("/repeatList", repeatRouter);

app.use("/users", petRouter);
app.use("/users", itemRouter);

// Cloud Functions v2 onRequest
export const api = onRequest({ region: "asia-northeast3" }, app);

// ===== Firestore 트리거 =====
function kstDateStr(date = new Date()): string {
  const kst = new Date(date.getTime() + 9 * 60 * 60 * 1000);
  const y = kst.getUTCFullYear();
  const m = String(kst.getUTCMonth() + 1).padStart(2, "0");
  const d = String(kst.getUTCDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

export const onTaskSubmitted = onDocumentWritten("Users/{userId}/log/{logId}", async (event) => {
  const userId = event.params.userId;
  const after = event.data?.after.exists ? event.data?.after.data() : null;
  if (!after) return;

  if (!Boolean(after.submitted)) return;

  const afterCompleted = Number(after.completedCount || 0);
  const afterCredited = Number(after.creditedCompleted || 0);

  const statsRef = db.collection("Users").doc(userId).collection("stats").doc("summary");
  const logRef = db.collection("Users").doc(userId).collection("log").doc(event.params.logId);

  const todayStr = kstDateStr();

  await db.runTransaction(async (tx: Transaction) => {
    const [statsSnap, logSnap] = await Promise.all([tx.get(statsRef), tx.get(logRef)]);

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
      const neverUpdatedStats = !statsSnap.exists || lastUpdatedDateStr === null;
      const neverCreditedInLog = !logSnap.exists || !("creditedCompleted" in (logSnap.data() || {}));
      if (neverUpdatedStats && neverCreditedInLog) {
        delta = afterCompleted;
      }
    }

    let newStreak = streakDays;
    let shouldUpdateStreak = false;

    if (lastUpdatedDateStr === null) {
      newStreak = 1;
      shouldUpdateStreak = true;
    } else if (lastUpdatedDateStr !== todayStr) {
      const last = new Date(lastUpdatedDateStr);
      const today = new Date(todayStr);
      const diffDays = Math.round((today.getTime() - last.getTime()) / (1000 * 60 * 60 * 24));
      newStreak = diffDays === 1 ? streakDays + 1 : 1;
      shouldUpdateStreak = true;
    }

    const newTotalCompleted = totalCompleted + delta;

    const baseStatsUpdate: Record<string, unknown> = {
      totalCompleted: newTotalCompleted,
      lastUpdated: Timestamp.now(),
      lastUpdatedDateStr: lastUpdatedDateStr ?? todayStr,
    };

    const statsUpdate: UpdateData<DocumentData> = {
      ...baseStatsUpdate,
      ...(shouldUpdateStreak ? { streakDays: newStreak, lastUpdatedDateStr: todayStr } : {}),
    };

    tx.set(statsRef, statsUpdate, { merge: true });

    if (delta > 0 || afterCredited === 0) {
      tx.set(logRef, { creditedCompleted: afterCredited + delta }, { merge: true });
    }
  });
});

// 기존 export 유지 (ESM 로컬 모듈은 .js 필수)
export * from "./submitReward.js";
export { updateStatus } from "./pet/updateStatus.js";
export { submitPetExpAN3 } from "./submitPetEXP.js";
