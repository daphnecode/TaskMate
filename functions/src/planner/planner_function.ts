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

function refPlanner(uid: string, dateKey: string) {
  return db.collection("Users").doc(uid).collection("planner").doc(dateKey);
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

/** READ: GET /planner/read/:userId/:dateKey */
router.get("/read/:userId/:dateKey", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const uid = req.params.userId;
    const dateKey = req.params.dateKey;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const snap = await refPlanner(uid, dateKey).get();
    if (!snap.exists) {
      return res.json({
        success: true,
        message: "planner read complete",
        submitted: false,
        todayTasks: [],
      });
    }

    const data = snap.data() || {};
    const submitted = !!data.submitted;
    const raw: any[] = Array.isArray(data.todayTasks) ? data.todayTasks : [];
    const todayTasks = raw.map((t) => ({
      text: t.text ?? t.todoText ?? "",
      point: Number(t.point ?? t.todoPoint ?? 0),
      isChecked: !!(t.isChecked ?? t.todoCheck),
    }));

    return res.json({ success: true, message: "planner read complete", submitted, todayTasks });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** SAVE(덮어쓰기): POST /planner/save/:userId/:dateKey */
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

    const docRef = refPlanner(uid, dateKey);
    const snap = await docRef.get();
    const prevSubmitted = snap.exists ? !!(snap.data()?.submitted) : false;

    await docRef.set(
      {
        todayTasks: tasks,
        submitted: prevSubmitted,  // 제출 상태는 보존
        meta: { lastUpdated: kstNowISO() },
      },
      { merge: true }
    );

    return res.json({ success: true, message: "planner save complete" });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** UPDATE: PATCH /planner/update/:userId/:dateKey/:todoId */
router.patch("/update/:userId/:dateKey/:todoId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, dateKey, todoId } = req.params;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const docRef = refPlanner(uid, dateKey);
    const snap = await docRef.get();
    const tasks: any[] = Array.isArray(snap.data()?.todayTasks) ? snap.data()!.todayTasks : [];

    const idx = findIndexByIdOrIndex(tasks, todoId);
    if (idx < 0) return res.status(404).json({ success: false, message: "Todo not found" });

    const body = req.body || {};
    const newText  = body.todoText ?? body.text;
    const newPoint = body.todoPoint ?? body.point;

    if (typeof newText === "string") tasks[idx].text = newText;
    if (typeof newPoint !== "undefined") tasks[idx].point = Number(newPoint);

    await docRef.set({ todayTasks: tasks, meta: { lastUpdated: kstNowISO() } }, { merge: true });

    return res.json({
      success: true,
      message: "planner update complete",
      todoText: tasks[idx].text ?? "",
      todoPoint: Number(tasks[idx].point ?? 0),
    });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** CHECK: PATCH /planner/check/:userId/:dateKey/:todoId  Body: { todoCheck: boolean } */
router.patch("/check/:userId/:dateKey/:todoId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, dateKey, todoId } = req.params;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const docRef = refPlanner(uid, dateKey);
    const snap = await docRef.get();
    const tasks: any[] = Array.isArray(snap.data()?.todayTasks) ? snap.data()!.todayTasks : [];

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

    await docRef.set({ todayTasks: tasks, meta: { lastUpdated: kstNowISO() } }, { merge: true });

    return res.json({ success: true, message: "planner check complete" });
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

    const docRef = refPlanner(uid, dateKey);
    const snap = await docRef.get();
    const tasks: any[] = Array.isArray(snap.data()?.todayTasks) ? snap.data()!.todayTasks : [];

    const idx = findIndexByIdOrIndex(tasks, todoId);
    if (idx < 0) return res.status(404).json({ success: false, message: "Todo not found" });

    tasks.splice(idx, 1);

    await docRef.set({ todayTasks: tasks, meta: { lastUpdated: kstNowISO() } }, { merge: true });

    return res.json({ success: true, message: "planner delete complete" });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

export default router;
