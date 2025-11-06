// v2 Firestore trigger
import { onDocumentWritten } from "firebase-functions/v2/firestore";
// v2 HTTPS onRequest
import { onRequest } from "firebase-functions/v2/https";

import express from "express";
import cors from "cors";

// 라우터
import repeatRouter from "./planner/repeat_function.js";
import dailyRouter from "./planner/daily_function.js";
import petRouter from "./pet/petload.js";
import itemRouter from "./pet/itemload.js";
import shopRouter from "./pet/shopload.js";
import gameRouter from "./pet/gamereward.js";
import tokenRouter from "./tokenSave.js";

// 통계 핸들러
import { handleTaskSubmitted } from "./stats/handleTaskSubmitted.js";

// ===== Express 앱 (v2 onRequest) =====
const app = express();

// ✅ CORS는 제일 먼저 + 프리플라이트 허용
app.use(cors({ origin: true, credentials: true }));
app.options(/.*/, cors({ origin: true, credentials: true }));

// 바디 파서
app.use(express.json());

// 라우터 마운트
// - /repeatList/...  (예: /repeatList/read/:userId, /repeatList/save/:userId, /repeatList/add/:userId)
// - /dailyList/...   (노션 스펙 호환: /dailyList/add/:userId)
app.use("/daily", dailyRouter);
app.use("/repeatList", repeatRouter);
app.use("/users", petRouter);
app.use("/users", itemRouter);
app.use("/users", tokenRouter);
app.use("/shop", shopRouter);
app.use("/game", gameRouter);

// Cloud Functions v2 onRequest
export const api = onRequest({ region: "asia-northeast3" }, app);

// ===== Firestore 트리거 =====
export const onTaskSubmitted = onDocumentWritten("Users/{userId}/log/{logId}", async (event) => {
  const { userId, logId } = event.params as any;
  const after = event.data?.after.exists ? event.data.after.data() : null;
  if (!after) return;
  await handleTaskSubmitted(userId, logId, after);
});

// ===== 인증 레이어 (동시 로그인 차단/세션 관리) =====
export { acquireSession, heartbeatSession } from "./login/singleSession.js";

import { pushNotifications } from "./notification";
// 기존 export 유지 (ESM 로컬 모듈은 .js 필수)
export * from "./submitReward";
export { updateStatus } from "./pet/updateStatus";
export { submitPetExpAN3 } from "./submitPetEXP";
export { pushNotifications };
