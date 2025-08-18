// functions/src/index.ts
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { db } from "./firebase";


// KST 기준 YYYY-MM-DD 문자열
function kstDateStr(date = new Date()): string {
  const kst = new Date(date.getTime() + 9 * 60 * 60 * 1000);
  const y = kst.getUTCFullYear();
  const m = String(kst.getUTCMonth() + 1).padStart(2, "0");
  const d = String(kst.getUTCDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

/**
 * 동작 요약
 * - log 문서(Users/{userId}/log/{logId})가 쓰일 때 실행
 * - after.submitted === true 인 경우만 집계
 * - totalCompleted: 'creditedCompleted'를 기준으로 delta(증가분)만 누적
 * - streakDays: KST 기준 날짜가 새로 제출된 첫 날에만 증가 (하루 건너면 1로 리셋)
 * - log 문서에 'creditedCompleted'를 기록해 중복누적 방지 & 이후 수정시 증가분만 반영
 */
export const onTaskSubmitted = onDocumentWritten(
  "Users/{userId}/log/{logId}",
  async (event) => {
    const userId = event.params.userId;

    const before = event.data?.before.exists ? event.data?.before.data() : null;
    const after = event.data?.after.exists ? event.data?.after.data() : null;

    // 삭제 이벤트나 after 없음 → 종료
    if (!after) return;

    // 제출(false→true) 또는 이미 true 상태에서의 수정만 집계 대상
    const afterSubmitted = !!after.submitted;
    if (!afterSubmitted) return;

    // 집계용 값
    const afterCompleted = Number(after.completedCount || 0);
    const afterCredited = Number(after.creditedCompleted || 0); // 지금까지 누적 반영한 값(로그 문서에 저장)
    const delta = Math.max(0, afterCompleted - afterCredited);  // 이번에 추가로 반영할 증가분

    // 증가분이 0이면 totalCompleted 누적 불필요 (단, streak는 '오늘 첫 제출'이면 처리)
    // streak 계산은 stats에서 lastUpdatedDateStr 기준으로 한다.
    const statsRef = db.collection("Users").doc(userId).collection("stats").doc("summary");
    const logRef = db.collection("Users").doc(userId).collection("log").doc(event.params.logId);

    const todayStr = kstDateStr();

    await db.runTransaction(async (tx) => {
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

      // --- streak 계산 (오늘 첫 제출 시 갱신) ---
      // 기준: stats.lastUpdatedDateStr(마지막 제출 집계일) vs todayStr
      let newStreak = streakDays;
      let shouldUpdateStreak = false;

      if (lastUpdatedDateStr === null) {
        // 첫 제출 집계
        newStreak = 1;
        shouldUpdateStreak = true;
      } else if (lastUpdatedDateStr !== todayStr) {
        // 마지막 집계일이 오늘이 아니면, '오늘' 첫 제출 시 streak 갱신
        // 어제면 +1, 그 외엔 1로 리셋
        const last = new Date(lastUpdatedDateStr);
        const today = new Date(todayStr);
        const diffDays = Math.round((today.getTime() - last.getTime()) / (1000 * 60 * 60 * 24));
        newStreak = (diffDays === 1) ? (streakDays + 1) : 1;
        shouldUpdateStreak = true;
      }
      // lastUpdatedDateStr === todayStr 인 경우: 오늘 이미 streak 반영됨 → 그대로 유지

      // --- totalCompleted 누적 ---
      // 증가분(delta)만 반영
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
        tx.set(
          logRef,
          { creditedCompleted: afterCredited + delta },
          { merge: true }
        );
      }
    });

    console.log(
      `onTaskSubmitted: user=${userId}, deltaCompleted=${delta}, today=${todayStr}`
    );
  }
);

export * from "./submitReward";
export * from "./pet/updateStatus";