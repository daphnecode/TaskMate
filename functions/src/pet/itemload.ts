import express from "express";
import {verifyToken, refInventory, refUser, refItem, refStats} from "./refAPI";
import {Item} from "../types/api";

const router = express.Router();

router.get("/:userId/items", async (req, res) => {
  try {
    // 1. Firebase Token 인증
    const decoded = await verifyToken(req);
    const {userId: uid} = req.params;
    const itemCategory = req.query.itemCategory as string | undefined;

    if (decoded.uid !== uid) {
      return res.status(403).json({success: false, message: "Forbidden"});
    }

    const colRef = refInventory(uid); // CollectionReference
    let query: FirebaseFirestore.Query<Item> = colRef;

    if (itemCategory) {
      query = colRef.where("category", "==", Number(itemCategory)); // Query로 변경
    }

    // 2. Firestore 참조 (예시 함수 - 직접 구현 필요)
    const snap = await query.get();
    const filtered = snap.docs.filter((doc) => doc.data().count !== 0);

    if (snap.empty) {
      return res.json({
        success: true,
        message: "inventory read complete",
        data: [],
      });
    }

    // 3. 데이터 정규화
    const inventory = filtered.map((doc) => {
      const d = doc.data() as Item;
      return {
        icon: d.icon,
        category: d.category,
        name: d.name,
        hunger: d.hunger,
        happy: d.happy,
        count: d.count,
        price: d.price,
        itemText: d.itemText,
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
      return res.status(401).json({success: false, message: e.message});
    }
    return res.status(500).json({
      success: false, message: "Internal server error",
    });
  }
});


router.patch("/:userId/items/:itemName", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const {userId: uid, itemName} = req.params;

    if (decoded.uid !== uid) {
      return res.status(403).json({success: false, message: "Forbidden"});
    }

    const itemRef = refItem(uid, itemName); // 이전에 정의한 refItem 사용
    const snap = await itemRef.get();

    if (!snap.exists) {
      return res.status(404).json({success: false, message: "Item not found"});
    }

    const currentCount = snap.data()!.count;

    const newCount = (currentCount > 0) ? currentCount - 1 : 0;
    await itemRef.update({count: newCount});

    // 1️⃣ 유저 문서 참조
    const userRef = refUser(uid);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      return res.status(404).json({success: false, message: "User not found"});
    }

    // 2️⃣ nowPet 가져오기
    const nowPet = userSnap.data()?.nowPet;
    if (!nowPet) {
      return res.status(400).json({success: false, message: "nowPet not set"});
    }

    const petRef = userRef.collection("pets").doc(nowPet);
    const petSnap = await petRef.get();

    const petData = petSnap.data() ?? {};
    const petHunger = petData["hunger"] ?? 0;
    const petHappy = petData["happy"] ?? 0;
    const updatesPet: any = {};

    const itemData = snap.data() ?? {};
    const itemHunger = itemData["hunger"] ?? 0;
    const itemHappy = itemData["happy"] ?? 0;

    // Hunger 감소
    const newHunger = Math.min(petHunger + itemHunger);
    const newHappy = Math.min(petHappy + itemHappy);

    updatesPet.hunger = newHunger;
    updatesPet.happy = newHappy;

    // 3️⃣ pets/{nowPet} 문서 업데이트
    await userRef.collection("pets").doc(nowPet).set(updatesPet, {merge: true});

    const statsRef = refStats(uid);
    const statsSnap = await statsRef.get();
    const statsData = statsSnap.data() ?? {};
    const feeding = statsData["feeding"] ?? 0;
    const moreHappy = statsData["moreHappy"] ?? 0;

    let newF = feeding;
    let newMH = moreHappy;
    if (itemHunger > 0) newF++;
    if (itemHappy > 0) newMH++;

    await statsRef.update({
      feeding: newF,
      moreHappy: newMH,
    });

    const foodRef = statsRef.collection("foodCount").doc(itemName);
    const foodSnap = await foodRef.get();
    const foodData = foodSnap.data() ?? {};
    const count = foodData["count"];

    await foodRef.update({count: count + 1});

    return res.json({
      success: true,
      message: "inventory use complete",
      itemName,
      itemCount: newCount,
    });
  } catch (e: any) {
    console.error(e);
    if (e.message?.includes("token")) {
      return res.status(401).json({success: false, message: e.message});
    }
    console.error(e);
    return res.status(500).json({
      success: false, message: "Internal server error",
    });
  }
});


router.patch("/:userId/items/:itemName/set", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const {userId: uid} = req.params;
    const {placeID} = req.body;

    if (decoded.uid !== uid) {
      return res.status(403).json({success: false, message: "Forbidden"});
    }

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
    if (e.message?.includes("token")) {
      return res.status(401).json({success: false, message: e.message});
    }
    return res.status(500).json({
      success: false, message: "Internal server error",
    });
  }
});


// ✅ style item 사용 API
router.patch("/:userId/items/:itemName/style", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const {userId: uid} = req.params;
    const {styleID} = req.body;

    if (decoded.uid !== uid) {
      return res.status(403).json({success: false, message: "Forbidden"});
    }

    if (!styleID || typeof styleID !== "string") {
      return res.status(400).json({success: false, message: "Invalid styleID"});
    }

    // 1️⃣ 유저 문서 참조
    const userRef = refUser(uid);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      return res.status(404).json({success: false, message: "User not found"});
    }

    // 2️⃣ nowPet 가져오기
    const nowPet = userSnap.data()?.nowPet;
    if (!nowPet) {
      return res.status(400).json({success: false, message: "nowPet not set"});
    }

    // 3️⃣ pets/{nowPet} 문서 업데이트
    await userRef.collection("pets").doc(nowPet).update({styleID});

    return res.json({
      success: true,
      message: "inventory style use complete",
      styleID,
    });
  } catch (e: any) {
    console.error(e);
    if (e.message?.includes("token")) {
      return res.status(401).json({success: false, message: e.message});
    }
    return res.status(500).json({
      success: false, message: "Internal server error",
    });
  }
});


export default router;
