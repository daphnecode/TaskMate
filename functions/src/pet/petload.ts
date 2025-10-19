import express from "express";
import { verifyToken, refUser, refPets } from "./refAPI";
import { Pet } from "../types/api.js";


const router = express.Router();

// ---------------------------
// PATCH /users/:userId/nowPet
// 새로운 펫 선택
router.patch("/:userId/nowPet", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid } = req.params;
    const { petName } = req.body;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });
    if (!petName) return res.status(400).json({ success: false, message: "petName is required" });

    const userRef = refUser(uid);
    userRef.update({
      nowPet: petName
    })

    return res.status(200).json({
      success: true,
      message: "pet choose complete",
      petName: petName
    });

  } catch (e: any) {
    console.error(e);
    if (e.message?.includes("token")) {
    return res.status(401).json({ success: false, message: e.message });
    }
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
});

// ---------------------------
// GET /users/:userId/pets/:petName
// 특정 펫 상태 조회
router.get("/:userId/pets/:petName", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, petName } = req.params;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const snap = await refPets(uid).doc(petName).get();
    if (!snap.exists) return res.status(404).json({ success: false, message: "Pet not found" });

    const pet = snap.data() as Pet;
    return res.json({ success: true, message: "pet condition read complete", data: pet });

  } catch (e: any) {
    console.error(e);
    if (e.message?.includes("token")) {
    return res.status(401).json({ success: false, message: e.message });
    }
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
});

// ---------------------------
// GET /users/:userId/pets/statistics
// 펫 통계 조회
/*
router.get("/:userId/pets/statistics", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid } = req.params;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const snap = await refPets(uid).get();
    if (snap.empty) return res.json({ success: true, message: "no pets found", data: {} });

    // 예시: 총 레벨 합, 평균 레벨 계산
    const pets = snap.docs.map(doc => doc.data() as Pet);
    const totalLevel = pets.reduce((sum, p) => sum + p.level, 0);
    const avgLevel = totalLevel / pets.length;

    return res.json({
      success: true,
      message: "pet statistics read complete",
      data: { totalLevel, avgLevel, count: pets.length }
    });

  } catch (e: any) {
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});
*/
export default router;