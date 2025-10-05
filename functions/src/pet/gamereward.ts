import express from "express";
import { getAuth } from "firebase-admin/auth";
import {db} from "../firebase.js";

const router = express.Router();

async function verifyToken(req: express.Request) {
  const h = req.headers.authorization || "";
  if (!h.startsWith("Bearer ")) throw new Error("No ID token provided");
  const token = h.substring("Bearer ".length);
  return getAuth().verifyIdToken(token);
}

console.log("▶ /game router loaded");

router.patch("/run/:userId", async (req, res) => {
  console.log("▶ /run/:userId 요청 도착:", req.method, req.path);
  try {
    const decoded = await verifyToken(req);
    console.log("✅ 토큰 검증 성공:", decoded.uid);

    const uid = decoded.uid;
    const { userId } = req.params;

    if (uid !== userId) {
      console.log("❌ uid 불일치:", uid, userId);
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    console.log("📍 1단계: Firestore에서 Users 문서 접근 시작");
    const userRef = db.collection("Users").doc(uid);
    const userSnap = await userRef.get();
    console.log("📍 2단계: userSnap.exists =", userSnap.exists);

    if (!userSnap.exists) {
      console.log("❌ User not found:", uid);
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const nowPet = userSnap.data()?.nowPet;
    console.log("📍 3단계: nowPet =", nowPet);

    if (!nowPet) {
      console.log("❌ nowPet not set");
      return res.status(400).json({ success: false, message: "nowPet not set" });
    }

    console.log("📍 4단계: Pets 문서 접근 시작");
    const petRef = userRef.collection("pets").doc(nowPet);
    const petSnap = await petRef.get();
    console.log("📍 5단계: petSnap.exists =", petSnap.exists);

    if (!petSnap.exists) {
      console.log("❌ Pet not found:", nowPet);
      return res.status(404).json({ success: false, message: "Pet not found" });
    }

    const petData = petSnap.data() || {};
    console.log("📍 6단계: petData =", petData);

    const newHappy = Math.min((petData.happy ?? 0) + 20, 100);
    const newHunger = Math.max((petData.hunger ?? 0) - 20, 0);

    console.log("📍 7단계: 업데이트 시도");
    await petRef.update({ happy: newHappy, hunger: newHunger });
    console.log("✅ 8단계: 업데이트 완료");

    return res.json({
      success: true,
      message: "hunger -20, happy +20",
      currentHunger: newHunger,
      currentHappy: newHappy
    });

  } catch (e: any) {
    console.error("🔥 /run/:userId 처리 중 에러:", e);
    return res.status(500).json({ success: false, message: e?.message || "Server error" });
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

    // 2️⃣ user 문서에서 nowPet 필드 읽기
    const userRef = db.collection("Users").doc(uid);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const nowPet = userSnap.data()?.nowPet;
    if (!nowPet) {
      return res.status(400).json({ success: false, message: "nowPet not set" });
    }

    // 3️⃣ pet 문서 불러오기
    const petRef = userRef.collection("pets").doc(nowPet);   
    const petSnap = await petRef.get();

    if (!petSnap.exists) {
      return res.status(404).json({ success: false, message: "Pet not found" });
    }

    const petData = petSnap.data() || {};

    // 4️⃣ happy +20, hunger -20 업데이트
    const newHappy = Math.min((petData.happy ?? 0) + 10, 100);

    await petRef.update({
      happy: newHappy,
    });

    return res.json({
      success: true,
      message: "happy +10",
      currentHappy: newHappy
    });

  } catch (e: any) {
    console.error(e);
    return res.status(500).json({ success: false, message: e?.message || "Server error" });
  }
});

// Firebase에 배포
export default router; 
