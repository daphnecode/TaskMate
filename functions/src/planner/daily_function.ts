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

// 문자열 id가 있으면 id로, 없으면 배열 인덱스로 판단
function findIndexByIdOrIndex(tasks: any[], todoId: string): number {
  const byId = tasks.findIndex((t) => String(t?.id) === String(todoId));
  if (byId >= 0) return byId;
  const idx = Number.isFinite(Number(todoId)) ? parseInt(todoId, 10) : -1;
  if (idx >= 0 && idx < tasks.length) return idx;
  return -1;
}

/** READ: GET /daily/read/:userId/:dateKey
 * 응답에 meta.submitted / meta.lastSubmit도 포함
 */
router.get("/read/:userId/:dateKey", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, dateKey } = req.params;
    if (decoded.uid !== uid) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    const snap = await refDaily(uid, dateKey).get();
    if (!snap.exists) {
      return res.json({
        success: true,
        message: "daily read complete",
        tasks: [],
        submitted: false,
        lastSubmit: "",
      });
    }

    const data = snap.data() || {};
    const raw: any[] = Array.isArray(data.tasks) ? data.tasks : [];
    const tasks = raw.map((t) => ({
      text: t.text ?? t.todoText ?? "",
      point: Number(t.point ?? t.todoPoint ?? 0),
      isChecked: !!(t.isChecked ?? t.todoCheck),
    }));

    const submitted = !!data?.meta?.submitted;
    const lastSubmit = String(data?.meta?.lastSubmit || "");

    return res.json({
      success: true,
      message: "daily read complete",
      tasks,
      submitted,
      lastSubmit,
    });
  } catch (e: any) {
    console.error(e);
    return res
      .status(401)
      .json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** SAVE(덮어쓰기): POST /daily/save/:userId/:dateKey
 * tasks 전체를 덮어쓰되, meta.submitted/lastSubmit은 보존
 */
router.post("/save/:userId/:dateKey", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, dateKey } = req.params;
    if (decoded.uid !== uid) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    const list = Array.isArray(req.body?.tasks) ? req.body.tasks : [];
    const tasks = list.map((t: any) => ({
      text: String(t.text ?? t.todoText ?? ""),
      point: Number(t.point ?? t.todoPoint ?? 0),
      isChecked: !!(t.isChecked ?? t.todoCheck),
    }));

    const docRef = refDaily(uid, dateKey);
    const snap = await docRef.get();

    const prevSubmitted =
      snap.exists && typeof snap.data()?.meta?.submitted === "boolean"
        ? !!snap.data()!.meta.submitted
        : undefined;
    const prevLastSubmit =
      snap.exists && typeof snap.data()?.meta?.lastSubmit === "string"
        ? String(snap.data()!.meta.lastSubmit)
        : undefined;

    const meta: any = { lastUpdated: kstNowISO() };
    if (typeof prevSubmitted !== "undefined") meta.submitted = prevSubmitted;
    if (typeof prevLastSubmit !== "undefined") meta.lastSubmit = prevLastSubmit;

    await docRef.set({ tasks, meta }, { merge: true });

    return res.json({ success: true, message: "daily save complete" });
  } catch (e: any) {
    console.error(e);
    return res
      .status(401)
      .json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** UPDATE: PATCH /daily/update/:userId/:dateKey/:todoId
 * 특정 항목의 text/point 수정
 */
router.patch("/update/:userId/:dateKey/:todoId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, dateKey, todoId } = req.params;
    if (decoded.uid !== uid) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    const docRef = refDaily(uid, dateKey);
    const snap = await docRef.get();
    const tasks: any[] = Array.isArray(snap.data()?.tasks)
      ? snap.data()!.tasks
      : [];

    const idx = findIndexByIdOrIndex(tasks, todoId);
    if (idx < 0)
      return res
        .status(404)
        .json({ success: false, message: "Todo not found" });

    const body = req.body || {};
    const newText = body.todoText ?? body.text;
    const newPoint = body.todoPoint ?? body.point;

    if (typeof newText === "string") tasks[idx].text = newText;
    if (typeof newPoint !== "undefined") tasks[idx].point = Number(newPoint);

    await docRef.set(
      { tasks, meta: { lastUpdated: kstNowISO() } },
      { merge: true }
    );

    return res.json({
      success: true,
      message: "daily update complete",
      todoText: tasks[idx].text ?? "",
      todoPoint: Number(tasks[idx].point ?? 0),
    });
  } catch (e: any) {
    console.error(e);
    return res
      .status(401)
      .json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** CHECK: PATCH /daily/check/:userId/:dateKey/:todoId
 * Body: { todoCheck | isChecked }
 */
router.patch("/check/:userId/:dateKey/:todoId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, dateKey, todoId } = req.params;
    if (decoded.uid !== uid) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    const docRef = refDaily(uid, dateKey);
    const snap = await docRef.get();
    const tasks: any[] = Array.isArray(snap.data()?.tasks)
      ? snap.data()!.tasks
      : [];

    const idx = findIndexByIdOrIndex(tasks, todoId);
    if (idx < 0)
      return res
        .status(404)
        .json({ success: false, message: "Todo not found" });

    const body = req.body || {};
    const val =
      typeof body.todoCheck !== "undefined"
        ? !!body.todoCheck
        : typeof body.isChecked !== "undefined"
        ? !!body.isChecked
        : null;

    if (val === null)
      return res
        .status(400)
        .json({ success: false, message: "todoCheck required" });

    tasks[idx].isChecked = val;

    await docRef.set(
      { tasks, meta: { lastUpdated: kstNowISO() } },
      { merge: true }
    );

    return res.json({ success: true, message: "daily check complete" });
  } catch (e: any) {
    console.error(e);
    return res
      .status(401)
      .json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** DELETE: DELETE /daily/delete/:userId/:dateKey/:todoId */
router.delete("/delete/:userId/:dateKey/:todoId", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, dateKey, todoId } = req.params;
    if (decoded.uid !== uid) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    const docRef = refDaily(uid, dateKey);
    const snap = await docRef.get();
    const tasks: any[] = Array.isArray(snap.data()?.tasks)
      ? snap.data()!.tasks
      : [];

    const idx = findIndexByIdOrIndex(tasks, todoId);
    if (idx < 0)
      return res
        .status(404)
        .json({ success: false, message: "Todo not found" });

    tasks.splice(idx, 1);

    await docRef.set(
      { tasks, meta: { lastUpdated: kstNowISO() } },
      { merge: true }
    );

    return res.json({ success: true, message: "daily delete complete" });
  } catch (e: any) {
    console.error(e);
    return res
      .status(401)
      .json({ success: false, message: e?.message || "Unauthorized" });
  }
});

/** SUBMIT: POST /daily/submit/:userId/:dateKey
 * 제출 플래그/제출일 기록
 */
router.post("/submit/:userId/:dateKey", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { userId: uid, dateKey } = req.params;
    if (decoded.uid !== uid) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    const docRef = refDaily(uid, dateKey);
    await docRef.set(
      { meta: { submitted: true, lastSubmit: dateKey, lastUpdated: kstNowISO() } },
      { merge: true }
    );

    return res.json({ success: true, message: "daily submit complete" });
  } catch (e: any) {
    console.error(e);
    return res
      .status(401)
      .json({ success: false, message: e?.message || "Unauthorized" });
  }
});

export default router;
