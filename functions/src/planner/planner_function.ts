// functions/src/planner/planner_function.ts
// 🔔 Deprecated Compatibility Layer
// - 실제 데이터 소스는 dailyTasks로 통일
// - planner 라우트는 기존 클라이언트 호환을 위해 유지하되 내부적으로 dailyTasks에 읽기/쓰기
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

// ✅ 앞으로는 dailyTasks만 사용
function refDaily(uid: string, dateKey: string) {
  return db.collection("Users").doc(uid).collection("dailyTasks").doc(dateKey);
}

function kstNowISO() {
  return new Date(Date.now() + 9 * 60 * 60 * 1000).toISOString();
}

// id(문자열)가 있으면 id로, 없으면 배열 인덱스(todoId)로 찾음
function findIndexByIdOrIndex(tasks: any[], todoId: string): number {
  const byId = tasks.findIndex((t) => String(t?.id) === String(todoId));
  if (byId >= 0) return byId;
  const idx = Number.isFinite(Number(todoId)) ? parseInt(todoId, 10) : -1;
  if (idx >= 0 && idx < tasks.length) return idx;
  return -1;
}

/** READ: GET /planner/read/:userId/:dateKey
 * - 실제는 dailyTasks에서 읽고
 * - 응답은 과거 호환성을 위해 { todayTasks, submitted } 형태로 반환
 */
router.get("/read/:userId/:dateKey", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const uid = req.params.userId;
    const dateKey = req.params.dateKey;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const snap = await refDaily(uid, dateKey).get();
    if (!snap.exists) {
      return res.json({
        success: true,
        message: "planner read (redirected from daily) complete",
        submitted: false,
        todayTasks: [],
      });
    }

    const data = snap.data() || {};
    const raw: any[] = Array.isArray(data.tasks) ? data.tasks : [];
    const todayTasks = raw.map((t) => ({
      text: t.text ?? t.todoText ?? "",
      point: Number(t.point ?? t.todoPoint ?? 0),
      isChecked: !!(t.isChecked ?? t.todoCheck),
    }));

    const submitted =
      typeof data?.meta?.submitted === "boolean" ? !!data.meta.submitted : false;

    return res.json({
      success: true,
      message: "planner read (redirected from daily) complete",
      submitted,
      todayTasks,
    });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** SAVE(덮어쓰기): POST /planner/save/:userId/:dateKey
 * - body.tasks를 dailyTasks.tasks로 저장
 * - meta.submitted는 보존(있으면 유지, 없으면 생성하지 않음)
 */
router.post("/save/:userId/:dateKey", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const uid = req.params.userId;
    const dateKey = req.params.dateKey;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const list = Array.isArray(req.body?.tasks) ? req.body.tasks : [];
    const tasks = list.map((t: any) => ({
      text: String(t.text ?? t.todoText ?? ""),
      point: Number(t.point ?? t.todoPoint ?? 0),
      isChecked: !!(t.isChecked ?? t.todoCheck),
    }));

    const docRef = refDaily(uid, dateKey);
    const snap = await docRef.get();

    // 기존 submitted 보존
    const prevSubmitted =
      snap.exists && typeof snap.data()?.meta?.submitted === "boolean"
        ? !!snap.data()!.meta.submitted
        : undefined;

    const meta: any = { lastUpdated: kstNowISO() };
    if (typeof prevSubmitted !== "undefined") meta.submitted = prevSubmitted;

    await docRef.set({ tasks, meta }, { merge: true });

    return res.json({ success: true, message: "planner save → dailyTasks saved" });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** UPDATE: PATCH /planner/update/:userId/:dateKey/:todoId
 * - dailyTasks.tasks[index]의 text/point 수정
 */
router.patch("/update/:userId/:dateKey/:todoId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, dateKey, todoId } = req.params;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const docRef = refDaily(uid, dateKey);
    const snap = await docRef.get();
    const tasks: any[] = Array.isArray(snap.data()?.tasks) ? snap.data()!.tasks : [];

    const idx = findIndexByIdOrIndex(tasks, todoId);
    if (idx < 0) return res.status(404).json({ success: false, message: "Todo not found" });

    const body = req.body || {};
    const newText = body.todoText ?? body.text;
    const newPoint = body.todoPoint ?? body.point;

    if (typeof newText === "string") tasks[idx].text = newText;
    if (typeof newPoint !== "undefined") tasks[idx].point = Number(newPoint);

    await docRef.set({ tasks, meta: { lastUpdated: kstNowISO() } }, { merge: true });

    return res.json({
      success: true,
      message: "planner update → dailyTasks updated",
      todoText: tasks[idx].text ?? "",
      todoPoint: Number(tasks[idx].point ?? 0),
    });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** CHECK: PATCH /planner/check/:userId/:dateKey/:todoId
 * Body: { todoCheck | isChecked }
 */
router.patch("/check/:userId/:dateKey/:todoId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, dateKey, todoId } = req.params;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const docRef = refDaily(uid, dateKey);
    const snap = await docRef.get();
    const tasks: any[] = Array.isArray(snap.data()?.tasks) ? snap.data()!.tasks : [];

    const idx = findIndexByIdOrIndex(tasks, todoId);
    if (idx < 0) return res.status(404).json({ success: false, message: "Todo not found" });

    const body = req.body || {};
    const val =
      typeof body.todoCheck !== "undefined"
        ? !!body.todoCheck
        : typeof body.isChecked !== "undefined"
        ? !!body.isChecked
        : null;

    if (val === null) return res.status(400).json({ success: false, message: "todoCheck required" });

    tasks[idx].isChecked = val;

    await docRef.set({ tasks, meta: { lastUpdated: kstNowISO() } }, { merge: true });

    return res.json({ success: true, message: "planner check → dailyTasks updated" });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** DELETE: DELETE /planner/delete/:userId/:dateKey/:todoId */
router.delete("/delete/:userId/:dateKey/:todoId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, dateKey, todoId } = req.params;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const docRef = refDaily(uid, dateKey);
    const snap = await docRef.get();
    const tasks: any[] = Array.isArray(snap.data()?.tasks) ? snap.data()!.tasks : [];

    const idx = findIndexByIdOrIndex(tasks, todoId);
    if (idx < 0) return res.status(404).json({ success: false, message: "Todo not found" });

    tasks.splice(idx, 1);

    await docRef.set({ tasks, meta: { lastUpdated: kstNowISO() } }, { merge: true });

    return res.json({ success: true, message: "planner delete → dailyTasks updated" });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

export default router;
