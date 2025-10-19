import express from "express";
import { verifyToken, refInventory, refUser, refItem } from "./refAPI";
import { Item } from "../types/api";

const router = express.Router();

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
      query = colRef.where("category", "==", Number(itemCategory)); // Query로 변경
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
        name: d.name,
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
    if (e.message?.includes("token")) {
    return res.status(401).json({ success: false, message: e.message });
    }
    return res.status(500).json({ success: false, message: "Internal server error" }); 
  }
});


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


// ✅ style item 사용 API
router.patch("/:userId/items/:itemName/style", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid } = req.params;
    const { styleID } = req.body;

    if (decoded.uid !== uid) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    if (!styleID || typeof styleID !== "string") {
      return res.status(400).json({ success: false, message: "Invalid styleID" });
    }

    // 1️⃣ 유저 문서 참조
    const userRef = refUser(uid); 
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // 2️⃣ nowPet 가져오기
    const nowPet = userSnap.data()?.nowPet;
    if (!nowPet) {
      return res.status(400).json({ success: false, message: "nowPet not set" });
    }

    // 3️⃣ pets/{nowPet} 문서 업데이트
    // const petRef = await refPets(uid);
    // await petRef.doc(nowPet).update({ styleID });
    await userRef.collection("pets").doc(nowPet).update({ styleID });

    return res.json({
      success: true,
      message: "inventory style use complete",
      styleID,
    });

  } catch (e: any) {
    console.error(e);
    return res.status(500).json({ success: false, message: e.message || "Server error" });
  }
});


export default router;
