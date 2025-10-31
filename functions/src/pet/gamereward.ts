import express from "express";
import {verifyToken, refUser, refStats} from "./refAPI";

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

    // 2️⃣ user 문서에서 nowPet 필드 읽기
    const userRef = refUser(uid);
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

    const statsRef = refStats(uid);
    const statsSnap = await statsRef.get();
    const statsData = statsSnap.data() ?? {};
    const moreHappy = statsData["moreHappy"] ?? 0;

    const newMH = moreHappy + 1;

    await statsRef.update({
      moreHappy: newMH,
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
