import express from "express";
import request from "supertest";
import * as router from "./gamereward";

// ✅ verifyToken, refInventory, refUser, refPets를 mock 처리
jest.mock("./refAPI", () => ({
  verifyToken: jest.fn(),
  refUser: jest.fn(),
  refStats: jest.fn(),
}));

import {verifyToken, refUser, refStats} from "./refAPI";

const app = express();
app.use(express.json());
app.use("/game", router.default);

describe("장애물 달리기 경주 보상", () => {
  const mockUserId = "testUser";

  // 콘솔 로그/에러 숨김
  beforeAll(() => {
    jest.spyOn(console, "error").mockImplementation();
    jest.spyOn(console, "log").mockImplementation();
  });

  afterAll(() => {
    (console.error as jest.Mock).mockRestore();
    (console.log as jest.Mock).mockRestore();
  });

  beforeEach(() => {
    jest.clearAllMocks();
    (verifyToken as jest.Mock).mockResolvedValue({uid: mockUserId});
  });

  // ========================
  // ✅ PATCH /game/run/:userId
  // ========================
  describe("PATCH /game/run/:userId", () => {
    it("✅펫 장애물 달리기 완수 보상. 행복도 20 증가 포만도 20 감소", async () => {
      const mockPetSnap = {
        exists: true,
        data: () => ({happy: 50, hunger: 90}),
      };
      const mockPetRef = {
        get: jest.fn().mockResolvedValue(mockPetSnap), update: jest.fn(),
      };
      const mockUserRef = {
        get: jest.fn().mockResolvedValue({
          exists: true, data: () => ({nowPet: "petA"}),
        }),
        collection: jest.fn().mockReturnThis(),
        doc: jest.fn().mockReturnValue(mockPetRef),
      };
      (refUser as jest.Mock).mockReturnValue(mockUserRef);
      const mockStatsSnap = {
        data: () => ({runningDistance: 300, moreHappy: 2}),
      };
      const mockStatsRef = {
        get: jest.fn().mockResolvedValue(mockStatsSnap),
        update: jest.fn(),
      };
      (refStats as jest.Mock).mockReturnValue(mockStatsRef);

      const res = await request(app)
        .patch(`/game/run/${mockUserId}`)
        .send({"runnedDistance": 100})
        .set("Authorization", "Bearer testtoken");

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.currentHappy).toBe(60);
      expect(res.body.currentHunger).toBe(80);
      expect(mockPetRef.update).toHaveBeenCalledWith({happy: 60, hunger: 80});
      expect(mockStatsRef.update).toHaveBeenCalledWith({
        runningDistance: 400, moreHappy: 3,
      });
    });

    it("❌ 사용자 id 불일치로 접근 금지", async () => {
      (verifyToken as jest.Mock).mockResolvedValue({uid: "wrongUser"});
      const res = await request(app)
        .patch(`/game/run/${mockUserId}`)
        .send({"runnedDistance": 200})
        .set("Authorization", "Bearer testtoken");
      expect(res.status).toBe(403);
      expect(res.body.message).toBe("Forbidden");
    });

    it("❌ nowPet이 없을 때", async () => {
      const mockUserRef = {
        get: jest.fn().mockResolvedValue({
          exists: true, data: () => ({nowPet: null})}),
      };
      (refUser as jest.Mock).mockReturnValue(mockUserRef);

      const res = await request(app)
        .patch(`/game/run/${mockUserId}`)
        .send({"runnedDistance": 300})
        .set("Authorization", "Bearer testtoken");
      expect(res.status).toBe(400);
      expect(res.body.message).toBe("nowPet not set");
    });

    it("❌ 펫이 존재하지 않을 때", async () => {
      const mockPetRef = {
        get: jest.fn().mockResolvedValue({exists: false})};
      const mockUserRef = {
        get: jest.fn().mockResolvedValue({
          exists: true, data: () => ({nowPet: "petA"})}),
        collection: jest.fn().mockReturnThis(),
        doc: jest.fn().mockReturnValue(mockPetRef),
      };
      (refUser as jest.Mock).mockReturnValue(mockUserRef);

      const res = await request(app)
        .patch(`/game/run/${mockUserId}`)
        .send({"runnedDistance": 100})
        .set("Authorization", "Bearer testtoken");
      expect(res.status).toBe(404);
      expect(res.body.message).toBe("Pet not found");
    });

    it("❌ 사용자 인증 실패", async () => {
      (verifyToken as jest.Mock).mockRejectedValue(new Error("Invalid token"));
      const res = await request(app)
        .patch(`/game/run/${mockUserId}`)
        .send({"runnedDistance": 100})
        .set("Authorization", "Bearer testtoken");
      expect(res.status).toBe(500);
      expect(res.body.message).toBe("Invalid token");
    });
  });

  // ========================
  // ✅ PATCH /game/clean/:userId
  // ========================
  describe("PATCH /game/clean/:userId", () => {
    it("✅ 펫 청소 완수 보상. 행복도 10 증가", async () => {
      const mockPetSnap = {exists: true, data: () => ({happy: 80})};
      const mockPetRef = {
        get: jest.fn().mockResolvedValue(mockPetSnap), update: jest.fn(),
      };
      const mockUserRef = {
        get: jest.fn().mockResolvedValue({
          exists: true, data: () => ({nowPet: "petA"})}),
        collection: jest.fn().mockReturnThis(),
        doc: jest.fn().mockReturnValue(mockPetRef),
      };
      mockPetRef.get = jest.fn().mockResolvedValue(mockPetSnap);
      (refUser as jest.Mock).mockReturnValue(mockUserRef);

      const res = await request(app)
        .patch(`/game/clean/${mockUserId}`)
        .set("Authorization", "Bearer testtoken");

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.currentHappy).toBe(90);
      expect(mockPetRef.update).toHaveBeenCalledWith({happy: 90});
    });

    it("❌ 사용자가 없을 때", async () => {
      const mockUserRef = {get: jest.fn().mockResolvedValue({exists: false})};
      (refUser as jest.Mock).mockReturnValue(mockUserRef);
      const res = await request(app)
        .patch(`/game/clean/${mockUserId}`)
        .set("Authorization", "Bearer testtoken");
      expect(res.status).toBe(404);
      expect(res.body.message).toBe("User not found");
    });

    it("❌ 사용자 인증 실패", async () => {
      (verifyToken as jest.Mock).mockRejectedValue(new Error("Invalid token"));
      const res = await request(app)
        .patch(`/game/clean/${mockUserId}`)
        .set("Authorization", "Bearer testtoken");
      expect(res.status).toBe(500);
      expect(res.body.message).toBe("Invalid token");
    });
  });
});

