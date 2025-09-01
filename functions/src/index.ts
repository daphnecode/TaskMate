// functions/src/index.ts
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { db } from "./firebase";

import { updateStatus } from "./pet/updateStatus";


// KST 기준 YYYY-MM-DD 문자열
function kstDateStr(date = new Date()): string {
  const kst = new Date(date.getTime() + 9 * 60 * 60 * 1000);
  const y = kst.getUTCFullYear();
  const m = String(kst.getUTCMonth() + 1).padStart(2, "0");
  const d = String(kst.getUTCDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}


export const onTaskSubmitted = onDocumentWritten(
  "Users/{userId}/log/{logId}",
  async (event) => {
    const userId = event.params.userId;

    const before = event.data?.before.exists ? event.data?.before.data() : null;
    const after  = event.data?.after.exists  ? event.data?.after.data()  : null;

    if (!after) return;

    const afterSubmitted = !!after.submitted;
    if (!afterSubmitted) return;

    const afterCompleted = Number(after.completedCount || 0);
    const afterCredited  = Number(after.creditedCompleted || 0); // 지금까지 누적 반영한 값(로그 문서에 저장)

    const statsRef = db.collection("Users").doc(userId).collection("stats").doc("summary");
    const logRef   = db.collection("Users").doc(userId).collection("log").doc(event.params.logId);

    const todayStr = kstDateStr();

    await db.runTransaction(async (tx) => {
      const [statsSnap, logSnap] = await Promise.all([tx.get(statsRef), tx.get(logRef)]);

      let totalCompleted = 0;
      let streakDays = 0;
      let lastUpdatedDateStr: string | null = null;

      if (statsSnap.exists) {
        const s = statsSnap.data()!;
        totalCompleted     = Number(s.totalCompleted || 0);
        streakDays         = Number(s.streakDays || 0);
        lastUpdatedDateStr = (s.lastUpdatedDateStr as string) || null;
      }


      let delta = Math.max(0, afterCompleted - afterCredited);
      if (delta === 0 && afterCompleted > 0) {
        const neverUpdatedStats  = !statsSnap.exists || lastUpdatedDateStr === null;
        const neverCreditedInLog = !logSnap.exists || !("creditedCompleted" in (logSnap.data() || {}));
        if (neverUpdatedStats && neverCreditedInLog) {
          delta = afterCompleted;
          console.log(`[bootstrap] user=${userId}, log=${event.params.logId}, force delta=${delta}`);
        }
      }

      // 🔎 디버깅 로깅
      console.log(`onTaskSubmitted(user=${userId}, log=${event.params.logId})`, {
        afterCompleted,
        afterCredited,
        delta,
        totalCompletedBefore: totalCompleted,
      });

      // --- streak 계산 (오늘 첫 제출 시 갱신) ---
      let newStreak = streakDays;
      let shouldUpdateStreak = false;

      if (lastUpdatedDateStr === null) {
        // 첫 제출 집계
        newStreak = 1;
        shouldUpdateStreak = true;
      } else if (lastUpdatedDateStr !== todayStr) {
        // 마지막 집계일이 오늘이 아니면, '오늘' 첫 제출 시 streak 갱신
        const last  = new Date(lastUpdatedDateStr);
        const today = new Date(todayStr);
        const diffDays = Math.round((today.getTime() - last.getTime()) / (1000 * 60 * 60 * 24));
        newStreak = (diffDays === 1) ? (streakDays + 1) : 1;
        shouldUpdateStreak = true;
      }
      // lastUpdatedDateStr === todayStr → 오늘 이미 streak 반영됨

      // --- totalCompleted 누적 ---
      const newTotalCompleted = totalCompleted + delta;

      // --- stats 업데이트 payload ---
      const statsUpdate: FirebaseFirestore.UpdateData<FirebaseFirestore.DocumentData> = {
        totalCompleted: newTotalCompleted,
        lastUpdated: admin.firestore.Timestamp.now(),
        lastUpdatedDateStr: lastUpdatedDateStr ?? todayStr,
      };

      if (shouldUpdateStreak) {
        (statsUpdate as any).streakDays = newStreak;
        (statsUpdate as any).lastUpdatedDateStr = todayStr; // streak 갱신일=오늘
      }

      tx.set(statsRef, statsUpdate, { merge: true });

      // --- log 문서에도 creditedCompleted 업데이트(증가분 반영 완료 표식) ---
      if (delta > 0 || afterCredited === 0) {
        tx.set(logRef, { creditedCompleted: afterCredited + delta }, { merge: true });
      }

      console.log(`stats updated: totalCompleted=${newTotalCompleted}, streak=${shouldUpdateStreak ? newStreak : "(no change)"}`);
    });
  }
);

// 다른 함수들 export
export * from "./submitReward";
exports.updateStatus = updateStatus; 
