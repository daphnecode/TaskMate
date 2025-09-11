import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {db} from "./firebase";
import {getLevelExp} from "./pet/levelExp";

/**
 * 펫 EXP/레벨업 전용 (포인트는 변경하지 않음)
 * - nowPet 값을 Users/{uid}/pets/{nowPet} 문서 id로 사용 ("dragon", "unicon")
 */
export const submitPetExpAN3 = onCall({
  region: "asia-northeast3"}, async (req) => {
  const uid = (req.auth?.uid as string) ??
(req.data.uid as string);
  const earned = Number(req.data.earned);
  const dateKey = String(req.data.dateKey);
  const force = !!req.data.force;

  const out: any = {ok: true, steps: [] as string[]};

  try {
    if (!uid || !Number.isFinite(earned) || !dateKey) {
      throw new HttpsError("invalid-argument",
        "uid, earned, dateKey are required");
    }
    if (earned <= 0) {
      out.skipped = true;
      out.reason = "earned<=0";
      return out;
    }

    const userRef = db.collection("Users").doc(uid);
    const logRef = userRef.collection("logV2").doc(dateKey); // 기존 log와 분리

    await db.runTransaction(async (tx) => {
      // 1) 중복 방지
      const logSnap = await tx.get(logRef);
      const already = logSnap.exists &&
      logSnap.data()?.expRewarded === true;
      out.steps.push(`logV2.exists=${logSnap.exists} 
expRewarded=${already}`);
      if (already && !force) {
        out.skipped = true;
        out.reason = "alreadyExpRewarded";
        return;
      }

      // 2) nowPet 확인
      const userSnap = await tx.get(userRef);
      const userData = userSnap.exists ? userSnap.data()! : {};
      const nowPet: string | undefined = userData.nowPet; // "dragon" | "unicon"
      out.steps.push(`user.exists=${userSnap.exists} 
nowPet=${nowPet ?? "null"}`);

      if (!nowPet) {
        out.skipped = true;
        out.reason = "nowPetMissing";
        return;
      }

      // 3) 펫 EXP/레벨 갱신
      const petRef = userRef.collection("pets").doc(nowPet);
      const petSnap = await tx.get(petRef);

      let lvl = Number(petSnap.data()?.level ?? 1);
      let exp = Number(petSnap.data()?.currentExp ?? 0);
      const before = {lvl, exp};

      exp += earned;

      const MAX_LEVEL = 100;
      let ups = 0;
      while (lvl < MAX_LEVEL) {
        const cap = getLevelExp(lvl); // 현재 레벨 → 다음 레벨까지 필요 EXP
        if (exp < cap) break;
        exp -= cap;
        lvl += 1;
        ups += 1;
      }

      // 문서가 없어도 merge:true로 생성/갱신
      tx.set(petRef, {level: lvl, currentExp: exp}, {merge: true});
      out.steps.push(`pet updated: before=${JSON.stringify(before)} 
after={"lvl":${lvl},"exp":${exp},"ups":${ups}}`);

      // 4) 로그 표식
      tx.set(
        logRef,
        {
          expRewarded: true,
          earnedExp: earned,
          rewardedBy: "submitPetExpAN3",
          rewardedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
      out.steps.push("logV2 marked expRewarded");
    });

    logger.info("[submitPetExpAN3] done", out);
    return out;
  } catch (err) {
    logger.error("[submitPetExpAN3] error", err as any);
    throw err;
  }
});
