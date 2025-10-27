import express from "express";
import { verifyToken, refUser, refPets, refStats } from "./refAPI";
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

router.get("/:userId/statistics", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid } = req.params;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const statsRef = refStats(uid);
    const statsSnap = await statsRef.get();
    const statsData = statsSnap.data() ?? {};
    const update : any = {};

    const distance = statsData["runningDistance"] ?? 0;
    const feedCount = statsData["feeding"] ?? 0;
    const happyAction = statsData["moreHappy"] ?? 0;
    update.distance = distance;
    update.feedCount = feedCount;
    update.happyAction = happyAction;

    const foodRef = statsRef.collection("foodCount");
    const foodSnap = await foodRef.orderBy("count", "desc").limit(1).get();

    const favorite = foodSnap.docs[0];
    update.favorite = favorite.id;

    return res.json({
      success: true,
      message: "pet statistics read complete",
      ...update,
    });
  } catch (e: any) {
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

export default router;