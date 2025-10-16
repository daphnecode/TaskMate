import express from 'express';
import request from 'supertest';
import * as router from './gamereward';

// ✅ verifyToken, refInventory, refUser, refPets를 mock 처리
jest.mock('./refAPI', () => ({
  verifyToken: jest.fn(),
  refUser: jest.fn(),
}));

import { verifyToken, refUser } from './refAPI';

const app = express();
app.use(express.json());
app.use("/game", router.default);

describe("🐾 Pet Action API", () => {
  const mockUserId = "testUser";

  // 콘솔 로그/에러 숨김
  beforeAll(() => {
    jest.spyOn(console, "error").mockImplementation(() => {});
    jest.spyOn(console, "log").mockImplementation(() => {});
  });

  afterAll(() => {
    (console.error as jest.Mock).mockRestore();
    (console.log as jest.Mock).mockRestore();
  });

  beforeEach(() => {
    jest.clearAllMocks();
    (verifyToken as jest.Mock).mockResolvedValue({ uid: mockUserId });
  });

  // ========================
  // ✅ PATCH /run/:userId
  // ========================
  describe("PATCH /run/:userId", () => {
    it("✅ should update pet happy+20 and hunger-20", async () => {
      const mockPetSnap = { exists: true, data: () => ({ happy: 50, hunger: 70 }) };
      const mockPetRef = { get: jest.fn().mockResolvedValue(mockPetSnap), update: jest.fn() };
      const mockUserRef = {
        get: jest.fn().mockResolvedValue({ exists: true, data: () => ({ nowPet: "petA" }) }),
        collection: jest.fn().mockReturnThis(),
        doc: jest.fn().mockReturnValue(mockPetRef),
      };
      mockPetRef.get = jest.fn().mockResolvedValue(mockPetSnap);
      (refUser as jest.Mock).mockReturnValue(mockUserRef);

      const res = await request(app).patch(`/action/run/${mockUserId}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.currentHappy).toBe(70);
      expect(res.body.currentHunger).toBe(50);
      expect(mockPetRef.update).toHaveBeenCalledWith({ happy: 70, hunger: 50 });
    });

    it("❌ should return 403 if uid mismatch", async () => {
      (verifyToken as jest.Mock).mockResolvedValue({ uid: "wrongUser" });
      const res = await request(app).patch(`/action/run/${mockUserId}`);
      expect(res.status).toBe(403);
      expect(res.body.message).toBe("Forbidden");
    });

    it("❌ should return 400 if nowPet not set", async () => {
      const mockUserRef = { get: jest.fn().mockResolvedValue({ exists: true, data: () => ({ nowPet: null }) }) };
      (refUser as jest.Mock).mockReturnValue(mockUserRef);

      const res = await request(app).patch(`/action/run/${mockUserId}`);
      expect(res.status).toBe(400);
      expect(res.body.message).toBe("nowPet not set");
    });

    it("❌ should return 404 if pet not found", async () => {
      const mockPetRef = { get: jest.fn().mockResolvedValue({ exists: false }) };
      const mockUserRef = {
        get: jest.fn().mockResolvedValue({ exists: true, data: () => ({ nowPet: "petA" }) }),
        collection: jest.fn().mockReturnThis(),
        doc: jest.fn().mockReturnValue(mockPetRef),
      };
      (refUser as jest.Mock).mockReturnValue(mockUserRef);

      const res = await request(app).patch(`/action/run/${mockUserId}`);
      expect(res.status).toBe(404);
      expect(res.body.message).toBe("Pet not found");
    });

    it("❌ should return 500 if token invalid", async () => {
      (verifyToken as jest.Mock).mockRejectedValue(new Error("Invalid token"));
      const res = await request(app).patch(`/action/run/${mockUserId}`);
      expect(res.status).toBe(500);
      expect(res.body.message).toBe("Invalid token");
    });
  });

  // ========================
  // ✅ PATCH /clean/:userId
  // ========================
  describe("PATCH /clean/:userId", () => {
    it("✅ should update pet happy+10", async () => {
      const mockPetSnap = { exists: true, data: () => ({ happy: 80 }) };
      const mockPetRef = { get: jest.fn().mockResolvedValue(mockPetSnap), update: jest.fn() };
      const mockUserRef = {
        get: jest.fn().mockResolvedValue({ exists: true, data: () => ({ nowPet: "petA" }) }),
        collection: jest.fn().mockReturnThis(),
        doc: jest.fn().mockReturnValue(mockPetRef),
      };
      mockPetRef.get = jest.fn().mockResolvedValue(mockPetSnap);
      (refUser as jest.Mock).mockReturnValue(mockUserRef);

      const res = await request(app).patch(`/action/clean/${mockUserId}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.currentHappy).toBe(90);
      expect(mockPetRef.update).toHaveBeenCalledWith({ happy: 90 });
    });

    it("❌ should return 404 if user not found", async () => {
      const mockUserRef = { get: jest.fn().mockResolvedValue({ exists: false }) };
      (refUser as jest.Mock).mockReturnValue(mockUserRef);
      const res = await request(app).patch(`/action/clean/${mockUserId}`);
      expect(res.status).toBe(404);
      expect(res.body.message).toBe("User not found");
    });

    it("❌ should return 500 if token invalid", async () => {
      (verifyToken as jest.Mock).mockRejectedValue(new Error("Invalid token"));
      const res = await request(app).patch(`/action/clean/${mockUserId}`);
      expect(res.status).toBe(500);
      expect(res.body.message).toBe("Invalid token");
    });
  });
});

