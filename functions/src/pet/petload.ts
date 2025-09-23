import express from "express";
import { getAuth } from "firebase-admin/auth";
import {db} from "../firebase.js";
import { Pet } from "../types/api.js";


const router = express.Router();

async function verifyToken(req: express.Request) {
  const h = req.headers.authorization || "";
  if (!h.startsWith("Bearer ")) throw new Error("No ID token provided");
  const token = h.substring("Bearer ".length);
  return getAuth().verifyIdToken(token);
}
function refPets(uid: string) {
  return db.collection("Users").doc(uid).collection("pets") as FirebaseFirestore.CollectionReference<Pet>;
}
/**
 * ✅ GET /users/:userID/pets
 * 특정 사용자의 펫 목록 조회
 */
/** READ: GET /users/:userId/pets */
router.get("/:userId/pets", async (req, res) => {
  try {
    // 1. Firebase Token 인증
    const decoded = await verifyToken(req);
    const { userId: uid } = req.params;

    if (decoded.uid !== uid) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    // 2. Firestore 참조 (예시 함수 - 직접 구현 필요)
    const snap = await refPets(uid).get();
    if (snap.empty) {
      return res.json({
        success: true,
        message: "no pets found",
        data: [],
      });
    }

    // 3. 데이터 정규화
    const pets = snap.docs.map((doc) => {
      const d = doc.data() as Pet; // 🔑 QueryDocumentSnapshot<DocumentData> → data() OK
      return {
        petName: d.petName ?? "",
        level: Number(d.level ?? 0),
      };
    });

    // 4. 성공 응답
    return res.json({
      success: true,
      message: "pet read complete",
      data: pets,
    });

  } catch (e: any) {
    console.error(e);
    return res.status(401).json({
      success: false,
      message: e?.message || "Unauthorized",
    });
  }
});
// ---------------------------
// POST /users/:userId/pets
// 새로운 펫 생성
router.post("/:userId/pets", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid } = req.params;
    const { petName } = req.body;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });
    if (!petName) return res.status(400).json({ success: false, message: "petName is required" });

    const newPetRef = refPets(uid).doc(petName);
    const initialPetData = {
      image: "assets/images/" + petName + ".png",
      petName: petName, 
      hunger: 100,
      happy: 100,
      level: 1,
      currentExp: 0,
      styleID: "default"
    };

    await newPetRef.set(initialPetData);

    return res.status(201).json({
      success: true,
      message: "pet add complete",
      ...initialPetData
    });

  } catch (e: any) {
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
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
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
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