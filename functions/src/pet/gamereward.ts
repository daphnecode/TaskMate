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

const app = express.Router();

app.patch("/run/:userId", async (req, res) => {
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
    const petRef = db.collection("Pets").doc(nowPet);
    const petSnap = await petRef.get();

    if (!petSnap.exists) {
      return res.status(404).json({ success: false, message: "Pet not found" });
    }

    const petData = petSnap.data() || {};

    // 4️⃣ happy +20, hunger -20 업데이트
    const newHappy = Math.min((petData.happy ?? 0) + 20, 100);
    const newHunger = Math.max((petData.hunger ?? 0) - 20, 0); // 음수 방지

    await petRef.update({
      happy: newHappy,
      hunger: newHunger,
    });

    return res.json({
      success: true,
      message: "hunger -20, happy +20",
      currentHunger: newHunger,
      currentHappy: newHappy
    });

  } catch (e: any) {
    console.error(e);
    return res.status(500).json({ success: false, message: e?.message || "Server error" });
  }
});

app.patch("/clean/:userId", async (req, res) => {
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
    const petRef = db.collection("Pets").doc(nowPet);
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