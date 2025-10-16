import express from 'express';
import request from 'supertest';
import * as router from './shopload';

// ✅ verifyToken, refUser, refItem, refShop, refShopItem를 mock 처리
jest.mock('./refAPI', () => ({
  verifyToken: jest.fn(),
  refUser: jest.fn(),
  refItem: jest.fn(),
  refShop: jest.fn(),
  refShopItem: jest.fn()
}));

import { verifyToken, refUser, refItem, refShop, refShopItem } from './refAPI';

const app = express();
app.use(express.json());
app.use('/shop', router.default);

describe("Shop API", () => {
  
  beforeAll(() => {
    jest.spyOn(console, "error").mockImplementation(() => {});
  });

  afterAll(() => {
    (console.error as jest.Mock).mockRestore();
  });

  beforeEach(() => {
    jest.clearAllMocks();
    (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });
  });

  // ✅ 1️⃣ GET /shop/items
  it("should return items by category successfully", async () => {
    // refShop mock
    const mockDocs = [
      { data: () => ({ name: "apple", category: 1, price: 10, icon: "🍎", hunger: 3, happy: 1, itemText: "fruit" }) },
    ];
    (refShop as jest.Mock).mockResolvedValue({
      empty: false,
      docs: mockDocs,
    });

    const res = await request(app)
      .get("/shop/items?category=1");

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.length).toBe(1);
    expect(res.body.data[0].name).toBe("apple");
  });

  it("should return 400 if category query missing", async () => {
    const res = await request(app).get("/shop/items");
    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });

  // ✅ 2️⃣ POST /aLLitems/items/:userId
  it("should purchase item successfully when enough points", async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });

    // mock Firestore 참조들
    const mockUserRef = {
      get: jest.fn().mockResolvedValue({ data: () => ({ currentPoint: 100 }) }),
      update: jest.fn().mockResolvedValue(undefined),
    };
    const mockItemRef = {
      get: jest.fn().mockResolvedValue({ exists: false }),
      set: jest.fn().mockResolvedValue(undefined),
      update: jest.fn().mockResolvedValue(undefined),
    };
    const mockShopRef = {
      get: jest.fn().mockResolvedValue({ data: () => ({ price: 30, name: "apple" }) }),
    };

    (refUser as jest.Mock).mockReturnValue(mockUserRef);
    (refItem as jest.Mock).mockReturnValue(mockItemRef);
    (refShopItem as jest.Mock).mockReturnValue(mockShopRef);

    const res = await request(app)
      .post("/shop/items/user123")
      .send({ itemName: "apple" });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.itemName).toBe("apple");
    expect(mockUserRef.update).toHaveBeenCalledWith({ currentPoint: 70 });
  });

  it("should fail to purchase if not enough points", async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });

    const mockUserRef = {
      get: jest.fn().mockResolvedValue({ data: () => ({ currentPoint: 10 }) }),
      update: jest.fn(),
    };
    const mockItemRef = { get: jest.fn(), set: jest.fn(), update: jest.fn() };
    const mockShopRef = {
      get: jest.fn().mockResolvedValue({ data: () => ({ price: 50 }) }),
    };

    (refUser as jest.Mock).mockReturnValue(mockUserRef);
    (refItem as jest.Mock).mockReturnValue(mockItemRef);
    (refShopItem as jest.Mock).mockReturnValue(mockShopRef);

    const res = await request(app)
      .post("/shop/items/user123")
      .send({ itemName: "apple" });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toMatch(/not enough point/);
    expect(mockUserRef.update).not.toHaveBeenCalled();
  });

  it("should return 400 if itemName missing", async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });

    const res = await request(app)
      .post("/shop/items/user123")
      .send({});

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });

  it("should return 500 if token invalid", async () => {
    (verifyToken as jest.Mock).mockRejectedValue(new Error("Invalid token"));

    const res = await request(app)
      .post("/shop/items/user123")
      .send({ itemName: "apple" });

    expect(res.status).toBe(500);
    expect(res.body.success).toBe(false);
  });
});
