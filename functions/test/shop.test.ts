// src/__tests__/integration-shop.test.ts
import express from "express";
import request from "supertest";
import shopRouter from "../src/pet/shopload";

jest.mock("../src/pet/refAPI", () => ({
  verifyToken: jest.fn(),
  refUser: jest.fn(),
  refShop: jest.fn(),
  refShopItem: jest.fn(),
  refItem: jest.fn(),
}));

import { verifyToken, refUser, refShop, refShopItem, refItem } from "../src/pet/refAPI";

describe("🐾 [INTEGRATION] 상점 아이템 로딩 & 구매", () => {
  let app: express.Express;
  let mockUserRef: any;
  let mockItemRef: any;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use("/shop", shopRouter);

    // ✅ 상점 아이템 mock
    const shopItem = [
      { data: () => ({ icon: "assets/icons/icon-chicken.png", name: "cookie", category: 1, count: 0, happy: 4, hunger: 15, price: 40, itemText: "yum" }) },
      { data: () => ({ icon: "assets/icons/icon-strawberry.png", name: "mushroomStew", category: 1, count: 0, happy: 0, hunger: 5, price: 10, itemText: "good" }) },
      { data: () => ({ icon: "assets/icons/icon-cupcake.png", name: "pudding", category: 1, count: 0, happy: 8, hunger: 10, price: 40, itemText: "something here" }) },
      { data: () => ({ icon: "assets/icons/icon-strawberry.png", name: "strawberry", category: 1, count: 5, happy: 5, hunger: 0, price: 10, itemText: "sweet and sour" }) },
      { data: () => ({ icon: "assets/icons/icon-chicken.png", name: "tuna", category: 1, count: 0, happy: 20, hunger: 50, price: 150, itemText: "wow" }) },
      { data: () => ({ icon: "assets/icons/icon-teddybear.png", name: "ball", category: 2, count: 0, happy: 4, hunger: 15, price: 40, itemText: "yum" }) },
      { data: () => ({ icon: "assets/icons/icon-teddybear.png", name: "fishingrod", category: 2, count: 0, happy: 0, hunger: 5, price: 10, itemText: "good" }) },
      { data: () => ({ icon: "assets/icons/icon-teddybear.png", name: "flyingdisk", category: 2, count: 0, happy: 8, hunger: 10, price: 40, itemText: "something here" }) },
      { data: () => ({ icon: "assets/icons/icon-teddybear.png", name: "skull", category: 2, count: 5, happy: 5, hunger: 0, price: 10, itemText: "sweet and sour" }) },
      { data: () => ({ icon: "assets/icons/icon-teddybear.png", name: "teddybear", category: 2, count: 0, happy: 20, hunger: 50, price: 150, itemText: "wow" }) }
    ];
    
    (refShop as jest.Mock).mockImplementation((category: number) => {
        const filteredDocs = shopItem.filter((item) => item.data().category === category);
        return Promise.resolve({ empty: filteredDocs.length === 0, docs: filteredDocs });
    });

    // ✅ verifyToken mock
    (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });

    // ✅ userRef mock
    const userData = { currentPoint: 100 };
    mockUserRef = {
      get: jest.fn().mockResolvedValue({ exists: true, data: () => userData }),
      update: jest.fn().mockResolvedValue(undefined),
    };
    (refUser as jest.Mock).mockReturnValue(mockUserRef);

    // ✅ shopItemRef mock
    (refShopItem as jest.Mock).mockImplementation((itemName: string) => {
        const found = shopItem.find(i => i.data().name === itemName);
        return {
            get: jest.fn().mockResolvedValue({
            exists: !!found,
            data: () => found ? found.data() : undefined,
            }),
        };
    });

    // ✅ userItemRef mock
    mockItemRef = {
      get: jest.fn().mockResolvedValue({ exists: false }),
      set: jest.fn().mockResolvedValue(undefined),
      update: jest.fn().mockResolvedValue(undefined),
    };
    (refItem as jest.Mock).mockReturnValue(mockItemRef);
  });

  it("상점 아이템 로딩 → 아이템 구매 정상 동작", async () => {
    // --- 상점 아이템 GET ---
    const listRes = await request(app)
      .get("/shop/items")
      .query({ category: 1 })
      .set("Authorization", "Bearer testtoken");

    expect(listRes.status).toBe(200);
    expect(listRes.body.success).toBe(true);
    expect(listRes.body.data[0].name).toBe("cookie");

    // --- 아이템 구매 POST ---
    const buyRes = await request(app)
      .post("/shop/items/user123")
      .send({ itemName: "strawberry" })
      .set("Authorization", "Bearer testtoken");

    expect(buyRes.status).toBe(200);
    expect(buyRes.body.success).toBe(true);
    expect(buyRes.body.itemName).toBe("strawberry");

    // ✅ 유저 포인트 차감 확인
    expect(mockUserRef.update).toHaveBeenCalledWith({ currentPoint: 90 });

    // ✅ 아이템 생성 확인
    expect(mockItemRef.set).toHaveBeenCalledWith(expect.objectContaining({
      name: "strawberry",
      count: 2,
    }));
  });

  it("포인트 부족 시 구매 실패", async () => {
    // userPoint를 낮춰서 부족하게 설정
    mockUserRef.get.mockResolvedValueOnce({ exists: true, data: () => ({ currentPoint: 5 }) });

    const res = await request(app)
      .post("/shop/items/user123")
      .send({ itemName: "strawberry" })
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toMatch(/not enough point/i);
  });
});
