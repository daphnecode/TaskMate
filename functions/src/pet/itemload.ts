import express from "express";
import { getAuth } from "firebase-admin/auth";
import {db} from "../firebase.js";
import { Item } from "../types/api.js";

const router = express.Router();

async function verifyToken(req: express.Request) {
  const h = req.headers.authorization || "";
  if (!h.startsWith("Bearer ")) throw new Error("No ID token provided");
  const token = h.substring("Bearer ".length);
  return getAuth().verifyIdToken(token);
}
function refInventory(uid: string) {
  return db.collection("Users").doc(uid).collection("items") as FirebaseFirestore.CollectionReference<Item>;
}
function refItem(uid: string, itemName: string) {
  return db.collection("Users").doc(uid).collection("items").doc(itemName) as FirebaseFirestore.DocumentReference<Item>;
}
function refUser(uid: string) {
  return db.collection("Users").doc(uid);
}

router.get("/:userId/items", async (req, res) => {
  try {
    // 1. Firebase Token 인증
    const decoded = await verifyToken(req);
    const { userId: uid } = req.params;
    const itemCategory = req.query.itemCategory as string | undefined;

    if (decoded.uid !== uid) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }
    
    const colRef = refInventory(uid); // CollectionReference
    let query: FirebaseFirestore.Query<Item> = colRef;

    if (itemCategory) {
      query = colRef.where("category", "==", itemCategory); // Query로 변경
    }

    // 2. Firestore 참조 (예시 함수 - 직접 구현 필요)
    const snap = await query.get();
    if (snap.empty) {
      return res.json({
        success: true,
        message: "inventory read complete",
        data: [],
      });
    }

    // 3. 데이터 정규화
    const inventory = snap.docs.map((doc) => {
      const d = doc.data() as Item; // 🔑 QueryDocumentSnapshot<DocumentData> → data() OK
      return {
        icon: d.icon,
        category: d.category,
        itemName: d.itemName,
        hunger: d.hunger,
        happy: d.happy,
        count: d.count,
        price: d.price,
        itemText: d.itemText
      };
    });

    // 4. 성공 응답
    return res.json({
      success: true,
      message: "inventory read complete",
      data: inventory,
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
// PATCH /users/:userId/items/:itemName
// 특정 아이템 사용 (수량 감소)
router.patch("/:userId/items/:itemName", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, itemName } = req.params;

    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const itemRef = refItem(uid, itemName); // 이전에 정의한 refItem 사용
    const snap = await itemRef.get();

    if (!snap.exists) {
      return res.status(404).json({ success: false, message: "Item not found" });
    }

    const currentCount = snap.data()!.count;

    const newCount = (currentCount > 0) ? currentCount - 1 : 0;
    await itemRef.update({ count: newCount });

    return res.json({
      success: true,
      message: "inventory use complete",
      itemName,
      itemCount: newCount,
    });

  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

router.patch("/:userId/items/:itemName/set", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid } = req.params;
    const { placeID } = req.body;

    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const newPlaceID = placeID || "default";
    

    // placeID 업데이트
    await refUser(uid).update({
      "setting.placeID": newPlaceID,
    });

    return res.json({
      success: true,
      message: "inventory place use complete",
      placeID,
    });

  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

export default router;