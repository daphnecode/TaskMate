import * as functions from "firebase-functions/v2/https";
import { db } from "../firebase";

// ✅ inventory 조회 API
export const getInventory = functions.onRequest(async (req, res) => {
  try {
    // ✅ Method check
    if (req.method !== "GET") {
      res.status(405).json({
        success: false,
        message: "Only GET method is allowed",
      });
      return;
    }

    // ✅ Firebase ID Token 인증
    const idToken = req.headers.authorization?.split("Bearer ")[1];
    if (!idToken) {
      res.status(401).json({
        success: false,
        message: "Missing Authorization Header",
      });
      return;
    }

    // ✅ Path Params & Query Params
    const userId = req.path.split("/").pop(); // /inventory/read/{userID}
    const itemCategoryParam = req.query.itemCategory as string | undefined;

    if (!userId) {
      res.status(400).json({
        success: false,
        message: "Missing userID in path",
      });
      return;
    }

    // ✅ Firestore에서 inventory 조회
    let itemCategory: number | undefined;
    if (itemCategoryParam) {
      itemCategory = parseInt(itemCategoryParam, 10);
    }

    // 3. Firestore 쿼리
    let query: FirebaseFirestore.Query = db
      .collection("Users")
      .doc(userId)
      .collection("items");

    if (itemCategory !== undefined) {
      query = query.where("itemCategory", "==", itemCategory);
    }

    const snapshot = await query.get();

    const data = snapshot.docs.map((doc) => doc.data());

    res.status(200).json({
      success: true,
      message: "inventory read complete",
      data,
    });
    return;
  } catch (error: any) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
    return;
  }
});
