// functions/src/planner/daily_function.ts
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

function refDaily(uid: string, dateKey: string) {
  return db.collection("Users").doc(uid).collection("dailyTasks").doc(dateKey);
}

function kstNowISO() {
  return new Date(Date.now() + 9 * 60 * 60 * 1000).toISOString();
}

function findIndexByIdOrIndex(tasks: any[], todoId: string): number {
  const byId = tasks.findIndex((t) => String(t?.id) === String(todoId));
  if (byId >= 0) return byId;
  const idx = Number.isFinite(Number(todoId)) ? parseInt(todoId, 10) : -1;
  if (idx >= 0 && idx < tasks.length) return idx;
  return -1;
}

/** READ: GET /daily/read/:userId/:dateKey */
router.get("/read/:userId/:dateKey", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, dateKey } = req.params;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const snap = await refDaily(uid, dateKey).get();
    if (!snap.exists) {
      return res.json({ success: true, message: "daily read complete", tasks: [] });
    }

    const raw: any[] = Array.isArray(snap.data()?.tasks) ? snap.data()!.tasks : [];
    const tasks = raw.map((t) => ({
      text: t.text ?? t.todoText ?? "",
      point: Number(t.point ?? t.todoPoint ?? 0),
      isChecked: !!(t.isChecked ?? t.todoCheck),
    }));

    return res.json({ success: true, message: "daily read complete", tasks });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** SAVE(덮어쓰기): POST /daily/save/:userId/:dateKey */
router.post("/save/:userId/:dateKey", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, dateKey } = req.params;
    if (decoded.uid !== uid) return res.status(403).json({ success: false, message: "Forbidden" });

    const list = Array.isArray(req.body?.tasks) ? req.body.tasks : [];
    const tasks = list.map((t: any) => ({
      text: String(t.text ?? t.todoText ?? ""),
      point: Number(t.point ?? t.todoPoint ?? 0),
      isChecked: !!(t.isChecked ?? t.todoCheck),
    }));

    await refDaily(uid, dateKey).set(
      { tasks, meta: { lastUpdated: kstNowISO() } },
      { merge: true }
    );

    return res.json({ success: true, message: "daily save complete" });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** UPDATE: PATCH /daily/update/:userId/:dateKey/:todoId */
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
    const newText  = body.todoText ?? body.text;
    const newPoint = body.todoPoint ?? body.point;

    if (typeof newText === "string") tasks[idx].text = newText;
    if (typeof newPoint !== "undefined") tasks[idx].point = Number(newPoint);

    await docRef.set({ tasks, meta: { lastUpdated: kstNowISO() } }, { merge: true });

    return res.json({
      success: true,
      message: "daily update complete",
      todoText: tasks[idx].text ?? "",
      todoPoint: Number(tasks[idx].point ?? 0),
    });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** CHECK: PATCH /daily/check/:userId/:dateKey/:todoId  Body:{ todoCheck | isChecked } */
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

    return res.json({ success: true, message: "daily check complete" });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** DELETE: DELETE /daily/delete/:userId/:dateKey/:todoId */
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

    return res.json({ success: true, message: "daily delete complete" });
  } catch (e: any) {
    console.error(e);
    return res.status(401).json({ success: false, message: e?.message || "Unauthorized" });
  }
});

export default router;
