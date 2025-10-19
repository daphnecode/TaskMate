// functions/test/planner.integration.test.ts
import express from "express";
import request from "supertest";

// ✅ firebase-admin/auth 목
const authMocks = { verifyIdToken: jest.fn() };
jest.mock("firebase-admin/auth", () => ({ getAuth: () => authMocks }));

// ✅ 실제 라우터/콜러블
import repeatRouter from "../src/planner/repeat_function";
import dailyRouter from "../src/planner/daily_function";
import { submitRewardAN3 } from "../src/submitReward";
import { submitPetExpAN3 } from "../src/submitPetExp";

// ✅ 같은 in-memory Firestore mock
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { db } = require("../src/__mocks__/firebase.js");

const callReward = (data: any, uid?: string) =>
  submitRewardAN3.run(uid ? ({ data, auth: { uid, token: {} as any } } as any) : ({ data } as any));
const callPetExp = (data: any, uid?: string) =>
  submitPetExpAN3.run(uid ? ({ data, auth: { uid, token: {} as any } } as any) : ({ data } as any));

function makeApp() {
  const app = express();
  app.use(express.json());
  app.use("/repeatList", repeatRouter);
  app.use("/daily", dailyRouter); // 배포에서 /dailyList라면 바꿔도 됨
  return app;
}

describe("🧪 Planner Integration: 진입 → CRUD → 체크 → 제출 → 포인트 → 펫 EXP/레벨업", () => {
  let app: express.Express;
  const uid = "U_INTEG_SCENARIO_1";
  const dateKey = "2025-10-30";

  beforeAll(() => {
    app = makeApp();
    jest.spyOn(console, "error").mockImplementation(() => {});
    jest.spyOn(console, "log").mockImplementation(() => {});
  });

  afterAll(() => {
    (console.error as jest.Mock).mockRestore();
    (console.log as jest.Mock).mockRestore();
  });

  // 공통 초기화
  async function bootstrap() {
    authMocks.verifyIdToken.mockResolvedValue({ uid });

    await db.collection("Users").doc(uid).collection("repeatTasks").doc("default").set({
      tasks: [
        { text: "R-1", point: 50, isChecked: true },
        { text: "R-2", point: 50, isChecked: false },
      ],
      meta: { lastUpdated: "2025-10-29" },
    });

    await db.collection("Users").doc(uid).collection("dailyTasks").doc(dateKey).set({
      tasks: [
        { text: "D-1", point: 30, isChecked: false },
        { text: "D-2", point: 20, isChecked: false },
      ],
      meta: { submitted: false, lastSubmit: "", lastUpdated: "2025-10-29" },
    });

    await db.collection("Users").doc(uid).set({ nowPet: "Unicon", currentPoint: 0, gotPoint: 0 }, { merge: true });
    await db.collection("Users").doc(uid).collection("pets").doc("Unicon").set({ level: 1, currentExp: 0 }, { merge: true });
  }

  beforeEach(async () => {
    jest.clearAllMocks();
    await bootstrap();
  });

  // 헬퍼들
  const readRepeat = () =>
    request(app).get(`/repeatList/read/${uid}`).set("Authorization", "Bearer token");
  const readDaily = () =>
    request(app).get(`/daily/read/${uid}/${dateKey}`).set("Authorization", "Bearer token");
  const addRepeat = () =>
    request(app)
      .post(`/repeatList/add/${uid}`)
      .set("Authorization", "Bearer token")
      .send({ todoText: "R-NEW", todoPoint: 40, todoCheck: false });
  const deleteRepeat = (todoId: string | number) =>
    request(app).delete(`/repeatList/delete/${uid}/${todoId}`).set("Authorization", "Bearer token");
  const checkDaily0 = () =>
    request(app)
      .patch(`/daily/check/${uid}/${dateKey}/0`)
      .set("Authorization", "Bearer token")
      .send({ isChecked: true });
  const submitDaily = () =>
    request(app).post(`/daily/submit/${uid}/${dateKey}`).set("Authorization", "Bearer token");

  describe("A) 플래너 진입", () => {
    it("✅ 리스트 불러오기(Repeat/Daily)", async () => {
      const rr = await readRepeat();
      expect(rr.status).toBe(200);
      expect(rr.body.data.length).toBe(2);

      const rd = await readDaily();
      expect(rd.status).toBe(200);
      expect(rd.body.tasks.length).toBe(2);
      expect(rd.body.submitted).toBe(false);
    });
  });

  describe("B) 반복 리스트 CRUD", () => {
    it("✅ 추가 후 삭제", async () => {
      const add = await addRepeat();
      expect(add.status).toBe(200);
      expect(add.body.message).toBe("repeatList add complete");
      const newId = add.body.todoID as string;

      const del = await deleteRepeat(newId);
      expect(del.status).toBe(200);
      expect(del.body.message).toBe("repeatList delete complete");
    });
  });

  describe("C) 일일 체크", () => {
    it("✅ D-1 체크 true", async () => {
      const res = await checkDaily0();
      expect(res.status).toBe(200);
      expect(res.body.message).toBe("daily check complete");
    });
  });

  describe("D) 제출", () => {
    it("✅ 제출 후 log/{dateKey} 기록(완료 2 / 전체 4)", async () => {
      await checkDaily0(); // 선행 상태
      const sub = await submitDaily();
      expect(sub.status).toBe(200);
      expect(sub.body.message).toBe("daily submit complete");

      const log = (
        await db.collection("Users").doc(uid).collection("log").doc(dateKey).get()
      ).data()!;
      expect(log.submitted).toBe(true);
      expect(log.completedCount).toBe(2);
      expect(log.totalTasks).toBe(4);
      expect(log.creditedCompleted).toBe(0);
    });
  });

  describe("E) 포인트 획득", () => {
    it("✅ 완료 포인트 합(50+30=80) 지급", async () => {
      await checkDaily0();
      await submitDaily();

      const reward = await callReward({ earned: 80, dateKey }, uid);
      expect(reward).toEqual({ ok: true });

      const user = (await db.collection("Users").doc(uid).get()).data()!;
      expect(user.currentPoint).toBe(80);
      expect(user.gotPoint).toBe(80);

      const log = (
        await db.collection("Users").doc(uid).collection("log").doc(dateKey).get()
      ).data()!;
      expect(log.rewarded).toBe(true);
      expect(log.earnedPoints).toBe(80);
    });
  });

  describe("F) 펫 EXP/레벨업", () => {
    it("✅ EXP 지급 로그/펫 상태 반영", async () => {
      await checkDaily0();
      await submitDaily();

      const expEarned = 200; // 커브에 맞춰 조절 가능
      const expRes = await callPetExp({ earned: expEarned, dateKey }, uid);
      expect(expRes.ok).toBe(true);

      const pet = (
        await db.collection("Users").doc(uid).collection("pets").doc("Unicon").get()
      ).data()!;
      expect(pet.level).toBeGreaterThanOrEqual(1);
      expect((pet.currentExp ?? pet.exp) >= 0).toBe(true);

      const log = (
        await db.collection("Users").doc(uid).collection("log").doc(dateKey).get()
      ).data()!;
      expect(log.expRewarded).toBe(true);
      expect(log.earnedExp).toBe(expEarned);
    });
  });
});