import express from 'express';
import request from 'supertest';
import * as router from './itemload';

// ✅ verifyToken, refInventory, refUser, refPets를 mock 처리
jest.mock('./refAPI', () => ({
  verifyToken: jest.fn(),
  refInventory: jest.fn(),
  refUser: jest.fn(),
  refItem: jest.fn(),
}));

import { verifyToken, refInventory, refUser, refItem } from './refAPI';

const app = express();
app.use(express.json());
app.use('/users', router.default);

describe("사용자 인벤토리 불러오기", () => {

  beforeEach(() => {
    jest.clearAllMocks();
  });

  // ✅ [GET] /users/:userId/items
  it("사용자 음식 아이템 인벤토리 리스트 불러오기", async () => {
    // mock verifyToken
    (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });

    // mock refInventory().get()
    const mockDocs = [
      { data: () => ({ icon: "assets/icons/icon-strawberry.png", name: "strawberry", category: 1, count: 5, happy: 5, hunger: 0, price: 10, itemText: "sweet and sour" }) },
      { data: () => ({ icon: "assets/icons/icon-cupcake.png", name: "pudding", category: 1, count: 1, happy: 8, hunger: 10, price: 40, itemText: "something here" }) },
      { data: () => ({ icon: "assets/icons/icon-tennisball_f.png", name: "ball", category: 2, count: 3, happy: 6, hunger: 0, price: 10, itemText: "just ball" }) },
    ];
    // 전체 데이터를 반환하는 get()
    const mockGetAll = jest.fn().mockResolvedValue({ empty: false, docs: mockDocs });

    // where("category", "==", value) 호출 시 필터링된 mockDocs만 반환
    const mockWhere = jest.fn((field: string, op: string, value: number) => {
      const filteredDocs = mockDocs.filter((d) => d.data().category === value);
      return { get: jest.fn().mockResolvedValue({ empty: false, docs: filteredDocs }) };
    });

    const mockQuery = { get: mockGetAll, where: mockWhere };
    (refInventory as jest.Mock).mockReturnValue(mockQuery);

    const res = await request(app)
      .get("/users/user123/items")
      .query({ itemCategory: 1 })
      .set("Authorization", "Bearer testtoken"); 

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.length).toBe(2);
    expect(res.body.data[0].name).toBe("strawberry");
  });

  it("사용자 id 불일치로 접근 금지", async () => {
    // mock verifyToken
    (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });

    const res = await request(app)
      .get("/users/user321/items")
      .query({ itemCategory: 2 })
      .set("Authorization", "Bearer testtoken"); 

    expect(res.status).toBe(403);
    expect(res.body.success).toBe(false);
  });

  it("사용자 인증 실패", async () => {
    // mock verifyToken
    (verifyToken as jest.Mock).mockRejectedValue(new Error("Invalid token"));

    const res = await request(app)
      .get("/users/user123/items")
      .query({ itemCategory: 2 })
      .set("Authorization", "Bearer testtoken"); 

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toBe("Invalid token");
  });  

  it("서버 응답 오류", async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });

    // Firestore get() 호출 시 오류 발생
    const mockQuery = { get: jest.fn().mockRejectedValue(new Error("Firestore error")) };
    (refInventory as jest.Mock).mockReturnValue(mockQuery);

    const res = await request(app)
      .get("/users/user123/items")
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(500);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toBe("Internal server error");
  });

});

describe("사용자 아이템 사용하기", () => {
  // ✅ [PATCH] /users/:userId/items/:itemName
  it("should decrease item count when using item", async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });

    const mockSnap = { exists: true, data: () => ({ count: 3 }) };
    const mockItemRef = {
      get: jest.fn().mockResolvedValue(mockSnap),
      update: jest.fn().mockResolvedValue(undefined),
    };
    (refItem as jest.Mock).mockReturnValue(mockItemRef);

    const res = await request(app)
      .patch("/users/user123/items/apple")
      .send({})
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.itemCount).toBe(2);
    expect(mockItemRef.update).toHaveBeenCalledWith({ count: 2 });
  });

  // ✅ [PATCH] /users/:userId/items/:itemName/set
  it("should update user placeID", async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });
    const mockUserRef = { update: jest.fn().mockResolvedValue(undefined) };
    (refUser as jest.Mock).mockReturnValue(mockUserRef);

    const res = await request(app)
      .patch("/users/user123/items/sofa/set")
      .send({ placeID: "livingroom" });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(mockUserRef.update).toHaveBeenCalledWith({ "setting.placeID": "livingroom" });
  });

  // ✅ [PATCH] /users/:userId/items/:itemName/style
  it("should update pet styleID", async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });

    const mockUserSnap = { exists: true, data: () => ({ nowPet: "pet01" }) };
    const mockPetsCollection = { doc: jest.fn().mockReturnValue({ update: jest.fn() }) };
    const mockUserRef = {
      get: jest.fn().mockResolvedValue(mockUserSnap),
      collection: jest.fn().mockReturnValue(mockPetsCollection),
    };
    (refUser as jest.Mock).mockReturnValue(mockUserRef);

    const res = await request(app)
      .patch("/users/user123/items/hat/style")
      .send({ styleID: "coolHat" });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(mockUserRef.collection).toHaveBeenCalledWith("pets");
    expect(mockPetsCollection.doc).toHaveBeenCalledWith("pet01");
  });
});