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



// ✅ 상점 아이템 불러오기
router.get("/items", async (req, res) => {
  try {
    // 인증 확인
    const { category } = req.query;
    if (!category) {
      return res.status(400).json({
        success: false,
        message: "category is required",
      });
    }

    // Firestore에서 카테고리별 아이템 불러오기
    const snap = await db
      .collection("aLLitems")
      .where("category", "==", Number(category))
      .get();

    if (snap.empty) {
      return res.json({
        success: true,
        message: "No items found",
        data: [],
      });
    }

    // 필드 변환: name → itemName
    const items: Item[] = snap.docs.map((doc) => {
      const d = doc.data();
      return {
        icon: d.icon,
        category: d.category,
        name: d.name, // 🔑 DB 필드 name을 itemName으로 매핑
        price: d.price,
        hunger: d.hunger,
        happy: d.happy,
        itemText: d.itemText,
        count: 0, // 상점에서는 기본 보유 개수 없음
      };
    });

    return res.json({
      success: true,
      message: "shop read complete",
      data: items,
    });
  } catch (e: any) {
    console.error("Error loading items:", e);
    return res.status(401).json({
      success: false,
      message: e?.message || "Unauthorized",
    });
  }
});

// POST /aLLitems/items
router.post("/items", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { itemName } = req.body;
    const uid = decoded.uid;

    if (!itemName) {
      return res.status(400).json({ success: false, message: "itemName is required" });
    }

    const itemRef = db.collection("Users").doc(uid).collection("items").doc(itemName);
    const snap = await itemRef.get();

    if (snap.exists) {
      // 이미 존재하면 count 1 증가
      const currentCount = snap.data()?.count ?? 0;
      await itemRef.update({ count: currentCount + 1 });
    } else {
      // 존재하지 않으면 새로 생성
      const newItem = {
        name: itemName,
        count: 1,
        // 필요하면 나머지 필드 초기값 설정
        price: 0,
        icon: "",
        category: 0,
        hunger: 0,
        happy: 0,
        itemText: "",
      };
      await itemRef.set(newItem);
    }

    return res.json({
      success: true,
      message: "item purchase complete",
      itemName,
    });

  } catch (e: any) {
    console.error(e);
    return res.status(500).json({ success: false, message: e?.message || "Server error" });
  }
});

export default router;
