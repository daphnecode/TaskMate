import * as admin from "firebase-admin";
import express from "express";

const db = admin.firestore();
const router = express.Router();

/** Authorization: Bearer <idToken> 검증 */
async function verifyToken(req: express.Request) {
  const h = req.headers.authorization || "";
  if (!h.startsWith("Bearer ")) throw new Error("No ID token provided");
  const token = h.substring("Bearer ".length);
  return admin.auth().verifyIdToken(token);
}

/** 반복 리스트 문서 참조: Users/{uid}/repeatTasks/default */
function refRepeat(uid: string) {
  return db
    .collection("Users")
    .doc(uid)
    .collection("repeatTasks")
    .doc("default");
}

/**
 * GET /repeatList/read/:userId
 * - 헤더에 Firebase ID 토큰 필요 (Authorization: Bearer <idToken>)
 * - Firestore 경로: Users/{uid}/repeatTasks/default
 * 응답:
 * {
 *   success: true,
 *   message: "repeatList read complete",
 *   data: [{ text, point, isChecked }, ...]
 * }
 */
router.get("/read/:userId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const uidFromToken = decoded.uid;
    const uidFromParam = req.params.userId;

    // 토큰의 uid와 파라미터 uid가 다르면 거부
    if (uidFromToken !== uidFromParam) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    const snap = await refRepeat(uidFromParam).get();

    if (!snap.exists) {
      // 문서가 아직 없으면 빈 배열 반환
      return res.json({
        success: true,
        message: "repeatList read complete",
        data: [],
      });
    }

    const raw = snap.data() || {};
    const tasks: any[] = Array.isArray(raw.tasks) ? raw.tasks : [];

    // 스키마 호환(text/todoText, point/todoPoint, isChecked/todoCheck)
    const data = tasks.map((t) => ({
      text: t.text ?? t.todoText ?? "",
      point: Number(t.point ?? t.todoPoint ?? 0),
      isChecked: !!(t.isChecked ?? t.todoCheck),
    }));

    return res.json({
      success: true,
      message: "repeatList read complete",
      data,
    });
  } catch (e: any) {
    console.error(e);
    return res
      .status(401)
      .json({ success: false, message: e?.message || "Unauthorized" });
  }
});

export default router;
