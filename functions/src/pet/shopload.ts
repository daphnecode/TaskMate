import express from "express";
import { getAuth } from "firebase-admin/auth";
import {db} from "../firebase.js";
import { Item } from "../types/api.js";
import { user } from "firebase-functions/v1/auth";

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
router.post("/items/:userId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { itemName } = req.body;
    const uid = decoded.uid;

    if (decoded.uid !== uid) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    if (!itemName) {
      return res.status(400).json({ success: false, message: "itemName is required" });
    }

    const userRef = db.collection("Users").doc(uid); 
    const shopRef = db.collection("aLLitems").doc(itemName);
    const snap2 = await userRef.get();
    const snap3 = await shopRef.get();

    const userPoint = snap2.data()?.currentPoint;
    const itemPrice = snap3.data()?.price;

    if (userPoint >= itemPrice) {
      await userRef.update({ currentPoint: userPoint - itemPrice });

      const itemRef = db.collection("Users").doc(uid).collection("items").doc(itemName);
      const snap1 = await itemRef.get();
      if (snap1.exists) {
        // 이미 존재하면 count 1 증가
        const currentCount = snap1.data()?.count ?? 0;
        await itemRef.update({ count: currentCount + 1 });
      } else {
        // 존재하지 않으면 새로 생성
        const itemData = snap3.data();
        await itemRef.set({
          ...itemData,
          count: 1,
        });
      }
    } else {
      return res.json({
        success: false,
        message: "item purchase fail: not enough point",
      });
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
