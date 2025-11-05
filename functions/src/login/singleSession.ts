// functions/src/auth/singleSession.ts
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db, FieldValue } from "../firebase";
import { getAuth } from "firebase-admin/auth";

/**
 * 세션 점유(획득).
 * - force=false: 기존 세션 alive면 거부 {ok:false, reason:'already-active'}
 * - force=true: 기존 세션 선점(덮어씀) + refresh 토큰 revoke(선택)
 */
export const acquireSession = onCall({ region: "asia-northeast3" }, async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Login first");

  const deviceId = String(req.data?.deviceId ?? "");
  const deviceName = String(req.data?.deviceName ?? "unknown");
  const force = !!req.data?.force;
  const ttlSec = Math.max(15, Math.min(300, Number(req.data?.ttlSec ?? 45)));

  if (!deviceId) throw new HttpsError("invalid-argument", "deviceId required");

  const sessRef = db.collection("Users").doc(uid).collection("auth").doc("session");
  const now = Date.now();

  const result = await db.runTransaction(async (tx) => {
    const snap = await tx.get(sessRef);
    const cur = snap.exists ? snap.data()! : null;

    const updatedMs =
      cur?.updatedAt?.toMillis ? cur.updatedAt.toMillis() : 0;
    const alive = updatedMs > 0 && now - updatedMs <= ttlSec * 1000;

    if (alive && !force) {
      return { ok: false, reason: "already-active" as const };
    }

    const sessionId = cryptoId();
    tx.set(
      sessRef,
      {
        sessionId,
        deviceId,
        deviceName,
        ttlSec,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return { ok: true as const, sessionId };
  });

  // 강제 선점이면 refresh 토큰 무효화(기존 기기는 다음 토큰 갱신 때 끊김)
  if (result.ok && force) {
    try { await getAuth().revokeRefreshTokens(uid); } catch (_) {}
  }

  return result;
});

/**
 * 세션 하트비트: 내 sessionId가 여전히 유효하면 updatedAt 갱신.
 * - sessionId가 바뀌었으면 {ok:false, reason:'taken'} → 클라에서 즉시 로그아웃
 */
export const heartbeatSession = onCall({ region: "asia-northeast3" }, async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Login first");

  const sessionId = String(req.data?.sessionId ?? "");
  if (!sessionId) throw new HttpsError("invalid-argument", "sessionId required");

  const sessRef = db.collection("Users").doc(uid).collection("auth").doc("session");
  const snap = await sessRef.get();

  if (!snap.exists || snap.data()?.sessionId !== sessionId) {
    return { ok: false, reason: "taken" as const };
  }
  await sessRef.update({ updatedAt: FieldValue.serverTimestamp() });
  return { ok: true as const };
});

// 간단 랜덤 id
function cryptoId(len = 20) {
  const cs = "abcdefghijklmnopqrstuvwxyz0123456789";
  let s = "";
  for (let i = 0; i < len; i++) s += cs[(Math.random() * cs.length) | 0];
  return s;
}
