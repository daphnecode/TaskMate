// src/__tests__/integration.test.ts
import express from "express";
import request from "supertest";

// 실제 라우터 불러오기
import * as shopRouter from "../src/pet/shopload";     // 상점 구매
import * as itemRouter from "../src/pet/itemload";     // 인벤토리 확인

// ✅ Firebase mock
jest.mock("../src/pet/refAPI", () => ({
  verifyToken: jest.fn(),
  refUser: jest.fn(),
  refShop: jest.fn(),
  refInventory: jest.fn(),
}));

import { verifyToken, refUser, refShop, refInventory } from "../src/pet/refAPI";

// Express 앱 초기화
const app = express();
app.use(express.json());
app.use("/shop", shopRouter.default);
app.use("/users", itemRouter.default);

describe("🧪 Integration Test: Login → Buy Item Scenario", () => {
  const mockUserId = "user123";

  // 공통 mock 객체
  const mockUserUpdate = jest.fn();
  const mockInventoryUpdate = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();

    // ✅ 로그인 인증 통과
    (verifyToken as jest.Mock).mockResolvedValue({ uid: mockUserId });

    // ✅ 유저 mock
    (refUser as jest.Mock).mockReturnValue({
      get: jest.fn().mockResolvedValue({ exists: true, data: () => ({ point: 100 }) }),
      update: mockUserUpdate,
    });

    // ✅ 상점 mock
    (refShop as jest.Mock).mockReturnValue({
      doc: jest.fn().mockReturnValue({
        get: jest.fn().mockResolvedValue({
          exists: true,
          data: () => ({ name: "apple", price: 50, category: 1 }),
        }),
      }),
    });

    // ✅ 인벤토리 mock
    (refInventory as jest.Mock).mockReturnValue({
      doc: jest.fn().mockReturnValue({
        get: jest.fn().mockResolvedValue({
          exists: false,
        }),
        set: mockInventoryUpdate,
      }),
    });
  });

  it("✅ 시나리오: 로그인 → 아이템 구매 → 포인트 차감 → 인벤토리 갱신", async () => {
    // 🟢 1. 로그인 성공
    // const loginRes = await request(app)
    //   .post("/users/login")
    //   .send({ email: "test@example.com", password: "1234" });

    // expect(loginRes.status).toBe(200);
    // expect(loginRes.body.success).toBe(true);
    // expect(verifyToken).not.toHaveBeenCalled(); // 로그인은 토큰 없음

    // 🟢 2. 아이템 구매
    const buyRes = await request(app)
      .post(`/shop/${mockUserId}/buy`)
      .send({ itemName: "apple" });

    expect(buyRes.status).toBe(200);
    expect(buyRes.body).toEqual({
      success: true,
      message: "Purchase complete",
      item: { name: "apple", price: 50, category: 1 },
    });

    // 🟢 3. 유저 포인트 차감 확인
    expect(mockUserUpdate).toHaveBeenCalledWith({ point: 50 }); // 100 → 50

    // 🟢 4. 인벤토리 갱신 확인
    expect(mockInventoryUpdate).toHaveBeenCalledWith({
      name: "apple",
      category: 1,
      count: 1,
    });
  });

  it("❌ 시나리오 실패: 포인트 부족 시 구매 불가", async () => {
    (refUser as jest.Mock).mockReturnValue({
      get: jest.fn().mockResolvedValue({ exists: true, data: () => ({ point: 10 }) }),
      update: mockUserUpdate,
    });

    const res = await request(app)
      .post(`/shop/${mockUserId}`)
      .send({ itemName: "cookie" });

    expect(res.status).toBe(400);
    expect(res.body.message).toBe("Not enough points");
    expect(mockUserUpdate).not.toHaveBeenCalled();
  });
});
