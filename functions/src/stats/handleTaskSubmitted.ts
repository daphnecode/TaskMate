// src/stats/handleTaskSubmitted.ts
import { Timestamp } from "firebase-admin/firestore";
import type { Transaction } from "firebase-admin/firestore";
import { db } from "../firebase.js";

export async function handleTaskSubmitted(
  userId: string,
  logId: string,
  after: any,
) {
  // 제출이 아닌 변경에는 반응하지 않음
  if (!after?.submitted) return;

  const afterCompleted = Number(after.completedCount || 0);
  const creditedFromAfter = Number(after.creditedCompleted || 0);

  const statsRef = db.collection("Users").doc(userId).collection("stats").doc("summary");
  const logRef   = db.collection("Users").doc(userId).collection("log").doc(logId);

  // 스트릭 기준일 = 실제 제출 날짜(문서 id)
  const todayStr = logId; // "YYYY-MM-DD"

  await db.runTransaction(async (tx: Transaction) => {
    const [statsSnap, logSnap] = await Promise.all([tx.get(statsRef), tx.get(logRef)]);

    // 현재 stats 스냅샷
    let totalCompleted = 0;
    let streakDays = 0;
    let lastUpdatedDateStr: string | null = null;

    if (statsSnap.exists) {
      const s = statsSnap.data()!;
      totalCompleted      = Number(s.totalCompleted || 0);
      streakDays          = Number(s.streakDays || 0);
      lastUpdatedDateStr  = (s.lastUpdatedDateStr as string) || null;
    }

    // creditedCompleted: DB, after 중 최신(최댓값) 사용
    const creditedFromDb = Number((logSnap.data()?.creditedCompleted) ?? 0);
    const logCredited    = Math.max(creditedFromDb, creditedFromAfter);

    // 오늘 반영해야 하는 추가 완료 수
    let delta = Math.max(0, afterCompleted - logCredited);

    // 초기 백필 예외: 통계/로그가 둘 다 신생이면 전체를 한 번에 인정
    if (delta === 0 && afterCompleted > 0) {
      const neverUpdatedStats = !statsSnap.exists || lastUpdatedDateStr === null;
      const neverCreditedInLog = !logSnap.exists || !("creditedCompleted" in (logSnap.data() || {}));
      if (neverUpdatedStats && neverCreditedInLog) {
        delta = afterCompleted;
      }
    }

    // 스트릭 계산(제출 날짜 기준)
    let newStreak = streakDays;
    let shouldUpdateStreak = false;

    if (lastUpdatedDateStr === null) {
      newStreak = 1;
      shouldUpdateStreak = true;
    } else if (lastUpdatedDateStr !== todayStr) {
      const last  = new Date(lastUpdatedDateStr);
      const today = new Date(todayStr);
      const diffDays = Math.round((today.getTime() - last.getTime()) / (1000 * 60 * 60 * 24));
      newStreak = diffDays === 1 ? streakDays + 1 : 1;
      shouldUpdateStreak = true;
    }

    const newTotalCompleted = totalCompleted + delta;

    // stats 갱신
    const baseStatsUpdate: Record<string, unknown> = {
      totalCompleted: newTotalCompleted,
      lastUpdated: Timestamp.now(),
      lastUpdatedDateStr: lastUpdatedDateStr ?? todayStr,
    };
    const statsUpdate = {
      ...baseStatsUpdate,
      ...(shouldUpdateStreak ? { streakDays: newStreak, lastUpdatedDateStr: todayStr } : {}),
    };
    tx.set(statsRef, statsUpdate, { merge: true });

    // log.creditedCompleted 누적
    if (delta > 0 || logCredited === 0) {
      tx.set(logRef, { creditedCompleted: logCredited + delta }, { merge: true });
    }
  });
}