import express from "express";
import {verifyToken, refUser, refStats} from "./refAPI";
import { FieldValue } from "firebase-admin/firestore";

function kstDateKey(d: Date = new Date()): string {
  const kst = new Date(d.getTime() + 9 * 60 * 60 * 1000);
  const y = kst.getUTCFullYear();
  const m = String(kst.getUTCMonth() + 1).padStart(2, "0");
  const day = String(kst.getUTCDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

const router = express.Router();


router.patch("/run/:userId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);

    const uid = decoded.uid;
    const {userId} = req.params;
    const runnedDistance = req.body.runnedDistance;

    if (uid !== userId) {
      return res.status(403).json({success: false, message: "Forbidden"});
    }

    const userRef = refUser(uid);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      return res.status(404).json({success: false, message: "User not found"});
    }

    const nowPet = userSnap.data()?.nowPet;

    if (!nowPet) {
      return res.status(400).json({success: false, message: "nowPet not set"});
    }

    const petRef = userRef.collection("pets").doc(nowPet);
    const petSnap = await petRef.get();

    if (!petSnap.exists) {
      return res.status(404).json({success: false, message: "Pet not found"});
    }

    const petData = petSnap.data() || {};

    const newHappy = Math.min((petData.happy ?? 0) + 10, 100);
    const newHunger = Math.max((petData.hunger ?? 0) - 10, 0);

    await petRef.update({happy: newHappy, hunger: newHunger});

    const statsRef = refStats(uid);
    const statsSnap = await statsRef.get();
    const statsData = statsSnap.data() ?? {};
    const runningDistance = statsData["runningDistance"] ?? 0;
    const moreHappy = statsData["moreHappy"] ?? 0;

    const newR = runningDistance + runnedDistance;
    const newMH = moreHappy + 1;

    await statsRef.update({
      runningDistance: newR,
      moreHappy: newMH,
    });

    return res.json({
      success: true,
      message: "hunger -10, happy +10",
      currentHunger: newHunger,
      currentHappy: newHappy,
    });
  } catch (e: any) {
    return res.status(500).json({
      success: false, message: e?.message || "Server error"});
  }
});


router.patch("/clean/:userId", async (req, res) => {
  try {
    // 1️⃣ 인증 토큰 검증
    const decoded = await verifyToken(req);
    const uid = decoded.uid;
    const { userId } = req.params;

    if (uid !== userId) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    // 2️⃣ user 문서에서 nowPet 필드 확인
    const userRef = refUser(uid);
    const userSnap = await userRef.get();
    if (!userSnap.exists) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    const nowPet = userSnap.data()?.nowPet as string | undefined;

    // ✅ 하루 1회 제한용 문서 경로 설정
    const dateKey = kstDateKey();
    const rewardRef = userRef.collection("rewards_clean").doc(dateKey);

    // 3️⃣ 트랜잭션으로 보상 지급 처리 (이미 지급된 날이면 스킵)
    const db = userRef.firestore;
    const out = await db.runTransaction(async (tx) => {
      // ── (읽기 단계) 오늘 보상 내역 확인 ─────────────────────────
      const rewardSnap = await tx.get(rewardRef);

      if (rewardSnap.exists) {
        // 이미 오늘 보상 완료 → 현재 happy만 반환 (읽기만 수행)
        let currentHappy: number | undefined = undefined;
        if (nowPet) {
          const petRef = userRef.collection("pets").doc(nowPet);
          const petSnap = await tx.get(petRef); // OK: 아직 아무 write도 안했음
          if (petSnap.exists) {
            currentHappy = (petSnap.get("happy") as number) ?? undefined;
          }
        }
        return {
          success: true,
          message: "오늘 보상은 이미 받았습니다.",
          currentHappy,
          happyDelta: 0,
          loggedToday: true,
        };
      }

      // 아직 보상 안 받음 → 계속 진행
      // nowPet이 없어도 "보상 로그"는 남겨서 멱등 기준 확보
      if (!nowPet) {
        // ── (쓰기 단계 시작) ─────────────────────────────────────
        tx.set(rewardRef, {
          type: "clean",
          amount: 10,
          done: true,
          dateKey,
          at: FieldValue.serverTimestamp(),
          note: "nowPetMissing",
        });
        return {
          success: true,
          message: "펫이 선택되어 있지 않아 행복도는 변경되지 않았습니다.",
          currentHappy: undefined,
          happyDelta: 0,
          loggedToday: true,
        };
      }

      // ── (읽기 단계) pet / stats를 모두 먼저 읽는다 ─────────────
      const petRef = userRef.collection("pets").doc(nowPet);
      const petSnap = await tx.get(petRef);

      const statsRef = refStats(uid);
      const statsSnap = await tx.get(statsRef);

      if (!petSnap.exists) {
        // 펫 문서 없음 → 보상 로그만 기록
        // ── (쓰기 단계) ─────────────────────────────────────────
        tx.set(rewardRef, {
          type: "clean",
          amount: 10,
          done: true,
          dateKey,
          at: FieldValue.serverTimestamp(),
          note: "petDocMissing",
        });
        return {
          success: true,
          message: "펫 문서를 찾을 수 없어 보상만 기록되었습니다.",
          currentHappy: undefined,
          happyDelta: 0,
          loggedToday: true,
        };
      }

      // ── (쓰기 단계) 모든 읽기 끝났으니 실제 업데이트 ────────────
      const petData = petSnap.data() || {};
      const nextHappy = Math.min((petData.happy ?? 0) + 10, 100);

      tx.update(petRef, { happy: nextHappy });

      if (statsSnap.exists) {
        const moreHappy = Number(statsSnap.get("moreHappy") ?? 0);
        tx.update(statsRef, { moreHappy: moreHappy + 1 });
      }

      // 지급 로그 생성 (하루 1회 기준)
      tx.set(rewardRef, {
        type: "clean",
        amount: 10,
        done: true,
        dateKey,
        at: FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        message: "행복도 +10",
        currentHappy: nextHappy,
        happyDelta: 10,
        loggedToday: true,
      };
    });

    // ✅ 최종 응답 반환
    return res.json(out);

  } catch (e: any) {
    console.error(e);
    return res.status(500).json({
      success: false,
      message: e?.message || "Server error",
    });
  }
});

// Firebase에 배포
export default router;
