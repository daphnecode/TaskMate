// functions/test/stats.integration.test.ts
import express from "express";
import request from "supertest";

// ✅ firebase-admin/auth 목
const authMocks = { verifyIdToken: jest.fn() };
jest.mock("firebase-admin/auth", () => ({ getAuth: () => authMocks }));

// ✅ 실제 라우터
import repeatRouter from "../src/planner/repeat_function";
import dailyRouter from "../src/planner/daily_function";

// ✅ 트리거 본문 로직 (핸들러)
import { handleTaskSubmitted } from "../src/stats/handleTaskSubmitted";

// ✅ 같은 in-memory Firestore mock
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { db } = require("../src/__mocks__/firebase.js");

// Express helper
function makeApp() {
  const app = express();
  app.use(express.json());
  app.use("/repeatList", repeatRouter);
  app.use("/daily", dailyRouter);
  return app;
}

// ✅ 메인 테스트 스위트
describe("📊 Stats Integration: 제출 → 통계 갱신/연속일수/중복방지", () => {
  const uidBase = "U_INTEG_STATS";
  let uid: string;
  let app: express.Express;

  // YYYY-MM-DD 유틸
  const d = (y: number, m: number, day: number) =>
    `${y}-${String(m).padStart(2, "0")}-${String(day).padStart(2, "0")}`;

  beforeAll(() => {
    app = makeApp();
    jest.spyOn(console, "error").mockImplementation(() => {});
    jest.spyOn(console, "log").mockImplementation(() => {});
  });

  afterAll(() => {
    (console.error as jest.Mock).mockRestore();
    (console.log as jest.Mock).mockRestore();
  });

  beforeEach(async () => {
    jest.clearAllMocks();

    // ✅ 테스트마다 새로운 uid 생성 (데이터 충돌 방지)
    uid = `${uidBase}_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`;
    authMocks.verifyIdToken.mockResolvedValue({ uid });

    // ✅ mock Firestore 초기화
    const userRef = db.collection("Users").doc(uid);
    await userRef.set({}, { merge: true });
  });

  const authHeader = { Authorization: "Bearer token" };

  it("✅ Day1 제출 → stats: total=completed, streak=1 / 같은 after로 재호출해도 중복 합산 안 됨", async () => {
    const date1 = d(2025, 10, 21);

    // repeat/daily 시드
    await db.collection("Users").doc(uid).collection("repeatTasks").doc("default").set({
      tasks: [
        { text: "R1", point: 10, isChecked: true },
        { text: "R2", point: 10, isChecked: false },
      ],
      meta: { lastUpdated: date1 },
    });

    await db.collection("Users").doc(uid).collection("dailyTasks").doc(date1).set({
      tasks: [
        { text: "D1", point: 30, isChecked: true },
        { text: "D2", point: 20, isChecked: false },
      ],
      meta: { submitted: false, lastSubmit: "", lastUpdated: date1 },
    });

    // 제출
    const sub = await request(app)
      .post(`/daily/submit/${uid}/${date1}`)
      .set(authHeader);
    expect(sub.status).toBe(200);

    const log1 = (
      await db.collection("Users").doc(uid).collection("log").doc(date1).get()
    ).data()!;
    expect(log1.submitted).toBe(true);
    expect(log1.completedCount).toBe(2);
    expect(log1.totalTasks).toBe(4);

    // 트리거 호출
    await handleTaskSubmitted(uid, date1, log1);

    const stats1 = (
      await db.collection("Users").doc(uid).collection("stats").doc("summary").get()
    ).data()!;
    expect(stats1.totalCompleted).toBe(2);
    expect(stats1.streakDays).toBeGreaterThanOrEqual(1);

    // 중복 호출 → 변화 없음
    await handleTaskSubmitted(uid, date1, log1);
    const stats1b = (
      await db.collection("Users").doc(uid).collection("stats").doc("summary").get()
    ).data()!;
    expect(stats1b.totalCompleted).toBe(2);
  });

  it("✅ Day2 연속 제출 → streak +1, total 누적 / Day3 건너뛰면 Day4 streak 리셋", async () => {
    const date1 = d(2025, 10, 21);
    const date2 = d(2025, 10, 22);
    const date4 = d(2025, 10, 24); // 23일 건너뜀

    // Day1
    await db.collection("Users").doc(uid).collection("repeatTasks").doc("default").set({
      tasks: [{ text: "R1", point: 10, isChecked: true }],
      meta: { lastUpdated: date1 },
    });
    await db.collection("Users").doc(uid).collection("dailyTasks").doc(date1).set({
      tasks: [{ text: "D1", point: 10, isChecked: true }],
      meta: { submitted: false, lastSubmit: "", lastUpdated: date1 },
    });
    await request(app).post(`/daily/submit/${uid}/${date1}`).set(authHeader);
    let log = (
      await db.collection("Users").doc(uid).collection("log").doc(date1).get()
    ).data()!;
    await handleTaskSubmitted(uid, date1, log);

    // Day2 (연속)
    await db.collection("Users").doc(uid).collection("repeatTasks").doc("default").set({
      tasks: [{ text: "R2", point: 10, isChecked: true }],
      meta: { lastUpdated: date2 },
    });
    await db.collection("Users").doc(uid).collection("dailyTasks").doc(date2).set({
      tasks: [{ text: "D2", point: 10, isChecked: true }],
      meta: { submitted: false, lastSubmit: "", lastUpdated: date2 },
    });
    await request(app).post(`/daily/submit/${uid}/${date2}`).set(authHeader);
    log = (
      await db.collection("Users").doc(uid).collection("log").doc(date2).get()
    ).data()!;
    await handleTaskSubmitted(uid, date2, log);

    let stats = (
      await db.collection("Users").doc(uid).collection("stats").doc("summary").get()
    ).data()!;
    expect(stats.totalCompleted).toBe(4);
    expect(stats.streakDays).toBeGreaterThanOrEqual(2);

    // Day4 (리셋)
    await db.collection("Users").doc(uid).collection("repeatTasks").doc("default").set({
      tasks: [{ text: "R4", point: 10, isChecked: true }],
      meta: { lastUpdated: date4 },
    });
    await db.collection("Users").doc(uid).collection("dailyTasks").doc(date4).set({
      tasks: [{ text: "D4", point: 10, isChecked: true }],
      meta: { submitted: false, lastSubmit: "", lastUpdated: date4 },
    });
    await request(app).post(`/daily/submit/${uid}/${date4}`).set(authHeader);
    log = (
      await db.collection("Users").doc(uid).collection("log").doc(date4).get()
    ).data()!;
    await handleTaskSubmitted(uid, date4, log);

    stats = (
      await db.collection("Users").doc(uid).collection("stats").doc("summary").get()
    ).data()!;
    expect(stats.totalCompleted).toBe(6);
    expect(stats.streakDays).toBe(1);
  });

  it("✅ creditedCompleted: 같은 날 동일 after로 재호출해도 total 중복 X", async () => {
    const date1 = d(2025, 10, 21);

    await db.collection("Users").doc(uid).collection("repeatTasks").doc("default").set({
      tasks: [{ text: "R1", point: 10, isChecked: true }],
      meta: { lastUpdated: date1 },
    });
    await db.collection("Users").doc(uid).collection("dailyTasks").doc(date1).set({
      tasks: [{ text: "D1", point: 10, isChecked: true }],
      meta: { submitted: false, lastSubmit: "", lastUpdated: date1 },
    });

    await request(app).post(`/daily/submit/${uid}/${date1}`).set(authHeader);
    const logRef = db.collection("Users").doc(uid).collection("log").doc(date1);

    let log = (await logRef.get()).data()!;
    await handleTaskSubmitted(uid, date1, log);

    // creditedCompleted가 올라갔는지 확인
    log = (await logRef.get()).data()!;
    expect(log.creditedCompleted).toBe(2);

    // 동일 after로 다시 호출 → delta=0 → total 그대로
    await handleTaskSubmitted(uid, date1, log);

    const stats = (
      await db.collection("Users").doc(uid).collection("stats").doc("summary").get()
    ).data()!;
    expect(stats.totalCompleted).toBe(2);
  });
});
