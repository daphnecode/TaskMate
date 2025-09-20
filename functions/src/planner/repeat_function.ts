// functions/src/planner/repeat_function.ts
import express from "express";
import { getAuth } from "firebase-admin/auth";
import { db } from "../firebase.js";

const router = express.Router();

async function verifyToken(req: express.Request) {
  const h = req.headers.authorization || "";
  if (!h.startsWith("Bearer ")) throw new Error("No ID token provided");
  const token = h.substring("Bearer ".length);
  return getAuth().verifyIdToken(token);
}

// 반복 리스트 문서 참조: Users/{uid}/repeatTasks/default
function refRepeat(uid: string) {
  return db.collection("Users").doc(uid).collection("repeatTasks").doc("default");
}

function kstNowISO() {
  return new Date(Date.now() + 9 * 60 * 60 * 1000).toISOString();
}

/** id필드가 있으면 id로, 없으면 문자열/숫자 인덱스로 찾는다 */
function findIndexByIdOrIndex(tasks: any[], todoId: string): number {
  const byId = tasks.findIndex((t) => String(t?.id) === String(todoId));
  if (byId >= 0) return byId;
  const idx = Number.isFinite(Number(todoId)) ? parseInt(todoId, 10) : -1;
  if (idx >= 0 && idx < tasks.length) return idx;
  return -1;
}

/** READ: GET /read/:userId  (mounted at /repeatList and /dailyList) */
router.get("/read/:userId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const uidFromToken = decoded.uid;
    const uidFromParam = req.params.userId;
    if (uidFromToken !== uidFromParam) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    const snap = await refRepeat(uidFromParam).get();
    if (!snap.exists) {
      return res.json({ success: true, message: "repeatList read complete", data: [] });
    }

    const raw = snap.data() || {};
    const tasks: any[] = Array.isArray(raw.tasks) ? raw.tasks : [];
    const data = tasks.map((t) => ({
      text: t.text ?? t.todoText ?? "",
      point: Number(t.point ?? t.todoPoint ?? 0),
      isChecked: !!(t.isChecked ?? t.todoCheck),
    }));

    return res.json({ success: true, message: "repeatList read complete", data });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** SAVE(전체 덮어쓰기): POST /save/:userId  */
router.post("/save/:userId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const uid = req.params.userId;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const list = Array.isArray(req.body?.tasks) ? req.body.tasks : [];
    const tasks = list.map((t: any) => ({
      text: String(t.text ?? t.todoText ?? ""),
      point: Number(t.point ?? t.todoPoint ?? 0),
      isChecked: !!(t.isChecked ?? t.todoCheck),
    }));

    const nowKST = new Date(Date.now() + 9 * 60 * 60 * 1000).toISOString();
    await refRepeat(uid).set({ tasks, meta: { lastUpdated: nowKST } }, { merge: true });

    return res.json({ success: true, message: "repeatList save complete" });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** ADD: POST /add/:userId
 *  - index.ts에서 /dailyList 및 /repeatList에 모두 마운트 →
 *    /dailyList/add/:userId  와  /repeatList/add/:userId 둘 다 동작
 */
router.post("/add/:userId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const uid = req.params.userId;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const todoText  = String(req.body?.todoText ?? "");
    const todoPoint = Number(req.body?.todoPoint ?? 0);
    const todoCheck = !!req.body?.todoCheck;

    const docRef = refRepeat(uid);
    const snap = await docRef.get();
    const tasks: any[] = Array.isArray(snap.data()?.tasks) ? snap.data()!.tasks : [];
    const newTask = { text: todoText, point: todoPoint, isChecked: todoCheck };
    tasks.push(newTask);

    const nowKST = new Date(Date.now() + 9 * 60 * 60 * 1000).toISOString();
    await docRef.set({ tasks, meta: { lastUpdated: nowKST } }, { merge: true });

    return res.json({
      success: true,
      message: "dailyList add complete",
      todoID: String(tasks.length - 1), // 배열 인덱스를 임시 ID로
      todoText,
      todoCheck,
      todoPoint,
    });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

router.patch("/update/:userId/:todoId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const uid = req.params.userId;
    const todoId = req.params.todoId;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const docRef = refRepeat(uid);
    const snap = await docRef.get();
    const tasks: any[] = Array.isArray(snap.data()?.tasks) ? snap.data()!.tasks : [];

    const idx = findIndexByIdOrIndex(tasks, todoId);
    if (idx < 0) return res.status(404).json({ success: false, message: "Todo not found" });

    const body = req.body || {};
    const newText  = body.todoText ?? body.text;
    const newPoint = body.todoPoint ?? body.point;

    if (typeof newText === "string")  tasks[idx].text = newText;
    if (typeof newPoint !== "undefined") tasks[idx].point = Number(newPoint);

    await docRef.set({ tasks, meta: { lastUpdated: kstNowISO() } }, { merge: true });

    return res.json({
      success: true,
      message: "dailyList update complete",
      todoText: tasks[idx].text ?? "",
      todoPoint: Number(tasks[idx].point ?? 0),
    });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/**  CHECK: PATCH /check/:userId/:todoId
 * Body: { todoCheck: boolean }  // 스펙
 *       (호환) { isChecked: boolean }
 * 응답: { success, message }
 */
router.patch("/check/:userId/:todoId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const uid = req.params.userId;
    const todoId = req.params.todoId;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const docRef = refRepeat(uid);
    const snap = await docRef.get();
    const tasks: any[] = Array.isArray(snap.data()?.tasks) ? snap.data()!.tasks : [];

    const idx = findIndexByIdOrIndex(tasks, todoId);
    if (idx < 0) return res.status(404).json({ success: false, message: "Todo not found" });

    const body = req.body || {};
    const val = (typeof body.todoCheck !== "undefined") ? !!body.todoCheck
               : (typeof body.isChecked !== "undefined") ? !!body.isChecked
               : null;

    // 스펙은 명시적 설정이므로 toggle는 안 하고, 값이 없으면 에러 처리
    if (val === null) return res.status(400).json({ success: false, message: "todoCheck required" });

    tasks[idx].isChecked = val;

    await docRef.set({ tasks, meta: { lastUpdated: kstNowISO() } }, { merge: true });

    return res.json({ success: true, message: "dailyList check complete" });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** DELETE: DELETE /delete/:userId/:todoId
 * 응답: { success, message }
 */
router.delete("/delete/:userId/:todoId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const uid = req.params.userId;
    const todoId = req.params.todoId;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const docRef = refRepeat(uid);
    const snap = await docRef.get();
    const tasks: any[] = Array.isArray(snap.data()?.tasks) ? snap.data()!.tasks : [];

    const idx = findIndexByIdOrIndex(tasks, todoId);
    if (idx < 0) return res.status(404).json({ success: false, message: "Todo not found" });

    tasks.splice(idx, 1);

    await docRef.set({ tasks, meta: { lastUpdated: kstNowISO() } }, { merge: true });

    return res.json({ success: true, message: "dailyList delete complete" });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

export default router;
