import express from "express";
import request from "supertest";
import * as router from "./shopload";

// ✅ verifyToken, refUser, refItem, refShop, refShopItem를 mock 처리
jest.mock("./refAPI", () => ({
  verifyToken: jest.fn(),
  refUser: jest.fn(),
  refItem: jest.fn(),
  refShop: jest.fn(),
  refShopItem: jest.fn(),
}));

import {verifyToken, refUser, refItem, refShop, refShopItem} from "./refAPI";

const app = express();
app.use(express.json());
app.use("/shop", router.default);

describe("GET /shop/items", () => {
  beforeAll(() => {
    jest.spyOn(console, "error").mockImplementation();
  });

  afterAll(() => {
    (console.error as jest.Mock).mockRestore();
  });

  beforeEach(() => {
    jest.clearAllMocks();
    (verifyToken as jest.Mock).mockResolvedValue({uid: "user123"});
  });

  // ✅ 1️⃣ GET /shop/items
  it("✅ 음식 상점 리스트 불러오기", async () => {
    // refShop mock
    const mockDocs = [
      {data: () => ({
        icon: "assets/icons/icon-chicken.png",
        name: "cookie", category: 1,
        count: 1, happy: 4, hunger: 15,
        price: 40, itemText: "yum",
      })},
      {data: () => ({
        icon: "assets/icons/icon-strawberry.png",
        name: "mushroomStew", category: 1,
        count: 1, happy: 0, hunger: 5,
        price: 10, itemText: "good",
      })},
      {data: () => ({
        icon: "assets/icons/icon-cupcake.png",
        name: "pudding", category: 1,
        count: 1, happy: 8, hunger: 10,
        price: 40, itemText: "something here",
      })},
      {data: () => ({
        icon: "assets/icons/icon-strawberry.png",
        name: "strawberry", category: 1,
        count: 5, happy: 5, hunger: 0,
        price: 10, itemText: "sweet and sour",
      })},
      {data: () => ({
        icon: "assets/icons/icon-chicken.png",
        name: "tuna", category: 1,
        count: 1, happy: 20, hunger: 50,
        price: 150, itemText: "wow",
      })},
      {data: () => ({
        icon: "assets/icons/icon-chicken.png",
        name: "cookie", category: 2,
        count: 1, happy: 4, hunger: 15,
        price: 40, itemText: "yum",
      })},
      {data: () => ({
        icon: "assets/icons/icon-strawberry.png",
        name: "mushroomStew", category: 2,
        count: 1, happy: 0, hunger: 5,
        price: 10, itemText: "good",
      })},
      {data: () => ({
        icon: "assets/icons/icon-cupcake.png",
        name: "pudding", category: 2,
        count: 1, happy: 8, hunger: 10,
        price: 40, itemText: "something here",
      })},
      {data: () => ({
        icon: "assets/icons/icon-strawberry.png",
        name: "strawberry", category: 2,
        count: 5, happy: 5, hunger: 0,
        price: 10, itemText: "sweet and sour",
      })},
      {data: () => ({
        icon: "assets/icons/icon-chicken.png",
        name: "tuna", category: 2,
        count: 1, happy: 20, hunger: 50,
        price: 150, itemText: "wow",
      })},
    ];
    (refShop as jest.Mock).mockImplementation((category: number) => {
      const filtered = mockDocs.filter((d) => d.data().category === category);
      return Promise.resolve({
        empty: filtered.length === 0,
        docs: filtered,
      });
    });

    const res = await request(app)
      .get("/shop/items?category=1")
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.length).toBe(5);
  });

  it("❌ category 쿼리 파라미터가 없는 경우", async () => {
    const res = await request(app)
      .get("/shop/items")
      .set("Authorization", "Bearer testtoken");
    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });
});

describe("POST /shop/items/:userId", () => {
  beforeAll(() => {
    jest.spyOn(console, "error").mockImplementation();
  });

  afterAll(() => {
    (console.error as jest.Mock).mockRestore();
  });

  beforeEach(() => {
    jest.clearAllMocks();
    (verifyToken as jest.Mock).mockResolvedValue({uid: "user123"});
  });


  // ✅ 2️⃣ POST /aLLitems/items/:userId
  it("✅ 아이템 구매하기", async () => {
    (verifyToken as jest.Mock).mockResolvedValue({uid: "user123"});

    // mock Firestore 참조들
    const mockUserRef = {
      get: jest.fn().mockResolvedValue({data: () => ({currentPoint: 100})}),
      update: jest.fn().mockResolvedValue(undefined),
    };
    const mockItemRef = {
      get: jest.fn().mockResolvedValue({exists: false}),
      set: jest.fn().mockResolvedValue(undefined),
      update: jest.fn().mockResolvedValue(undefined),
    };
    const mockShopRef = {
      get: jest.fn().mockResolvedValue({
        data: () => ({price: 40, name: "pudding"}
        )}),
    };

    (refUser as jest.Mock).mockReturnValue(mockUserRef);
    (refItem as jest.Mock).mockReturnValue(mockItemRef);
    (refShopItem as jest.Mock).mockReturnValue(mockShopRef);

    const res = await request(app)
      .post("/shop/items/user123")
      .send({itemName: "pudding"})
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.itemName).toBe("pudding");
    expect(mockUserRef.update).toHaveBeenCalledWith({currentPoint: 60});
  });

  it("❌ 보유 포인트가 부족할 경우", async () => {
    (verifyToken as jest.Mock).mockResolvedValue({uid: "user123"});

    const mockUserRef = {
      get: jest.fn().mockResolvedValue({data: () => ({currentPoint: 10})}),
      update: jest.fn(),
    };
    const mockItemRef = {get: jest.fn(), set: jest.fn(), update: jest.fn()};
    const mockShopRef = {
      get: jest.fn().mockResolvedValue({data: () => ({price: 150})}),
    };

    (refUser as jest.Mock).mockReturnValue(mockUserRef);
    (refItem as jest.Mock).mockReturnValue(mockItemRef);
    (refShopItem as jest.Mock).mockReturnValue(mockShopRef);

    const res = await request(app)
      .post("/shop/items/user123")
      .send({itemName: "tuna"})
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toMatch(/not enough point/);
    expect(mockUserRef.update).not.toHaveBeenCalled();
  });

  it("❌ 아이템 이름이 없는 경우", async () => {
    (verifyToken as jest.Mock).mockResolvedValue({uid: "user123"});

    const res = await request(app)
      .post("/shop/items/user123")
      .send({})
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });

  it("❌ 사용자 인증 실패", async () => {
    (verifyToken as jest.Mock).mockRejectedValue(new Error("Invalid token"));

    const res = await request(app)
      .post("/shop/items/user123")
      .send({itemName: "cookie"})
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(500);
    expect(res.body.success).toBe(false);
  });
});
