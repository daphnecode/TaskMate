// src/index.ts
import { onSchedule } from "firebase-functions/v2/scheduler";
import { db } from "../firebase";

// 매일 새벽 0시 (UTC 기준) 실행
export const updateStatus = onSchedule({schedule: "0 */1 * * *", timeZone: "Asia/Seoul"}, 
  async (event) => {
    console.log("매일 펫 상태 감소 작업 시작");

    try {
      // 1. 모든 Users 불러오기
      const usersSnap = await db.collection("Users").get();

      for (const userDoc of usersSnap.docs) {
        const userId = userDoc.id;
        const nowPetId = userDoc.get("nowPet");

        if (!nowPetId) {
          console.log(`유저 ${userId}는 nowPet이 없음`);
          continue;
        }

        // 2. Users/{uid}/pets/{nowPetId} 문서 가져오기
        const petRef = db.collection("Users").doc(userId).collection("pets").doc(nowPetId);
        const petSnap = await petRef.get();

        if (!petSnap.exists) {
          console.log(`유저 ${userId}의 nowPet(${nowPetId}) 문서 없음`);
          continue;
        }

        const petData = petSnap.data() ?? {};
        const petHunger = petData["hunger"] ?? 0;
        const petHappy = petData["happy"] ?? 0;
        const petExp = petData["currentExp"] ?? 0;

        // 3. 상태 감소 로직 (예: hunger -24, happy -30)
        /* 
        포만도 0 이하일 때, 행복도 감소
        행복도 0 이하일 때, 경험치 감소 추가 필요.
        */
        
        const newHunger = Math.max(0, petHunger - 2);
        const newHappy = Math.max(0, petHappy - 2);
        let updates: any = { hunger: newHunger, happy: newHappy };

        // 4. 상태 업데이트
        if (newHappy === 0) {
          const lostHappy = petHappy - newHappy;
          const newExp = Math.max(0, petExp - (lostHappy ? lostHappy : 2));
          updates.currentExp = newExp;
        }
        
        await petRef.set(updates, { merge: true });
        

        console.log(`유저 ${userId}의 펫 ${nowPetId} 상태 갱신됨:`, updateStatus);
      }

      console.log("모든 유저의 펫 상태 감소 완료 ✅");
    } catch (error) {
      console.error("스케줄 함수 오류:", error);
    }
  }
);
