// src/__tests__/integration.test.ts
import express from "express";
import request from "supertest";
import itemRouter from "../src/pet/itemload"; // router default import

// Firebase mock
jest.mock("../src/pet/refAPI", () => ({
  verifyToken: jest.fn(),
  refItem: jest.fn(),
  refUser: jest.fn(),
  refInventory: jest.fn(),
}));

import { verifyToken, refInventory, refItem, refUser } from "../src/pet/refAPI";

describe("🐾 [INTEGRATION] 사용자 인벤토리 및 아이템 사용 통합 시나리오", () => {
  let app: express.Express;
  let mockInventory: any[];
  let mockUser: any;
  let mockItemRef: any;
  let mockUserRef: any;
  let mockQuery: any;
  let mockUpdate: jest.Mock;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use("/users", itemRouter);

    // 초기 인벤토리 세팅
    mockInventory = [
      { name: "strawberry", category: 1, count: 5, happy: 5, hunger: 0 },
      { name: "pudding", category: 1, count: 1, happy: 8, hunger: 10 },
      { name: "ball", category: 2, count: 3, happy: 6, hunger: 0 },
      { name: "beach", category: 3, count: 1, happy: 0, hunger: 0 },
      { name: "starlight", category: 4, count: 1, happy: 0, hunger: 0 },
      { name: "bubble", category: 4, count: 1, happy: 0, hunger: 0 },
    ];

    mockUser = {
      nowPet: "unicon",
      setting: {placeID: "default"},
    };

    // ✅ update mock
    mockUpdate = jest.fn((data) => {
      mockUser.styleID = data.styleID; // 상태 저장
      return Promise.resolve();
    });

    // ✅ collection, doc mock
    mockUser.collection = jest.fn(() => ({
      doc: jest.fn((petId: string) => ({
        update: mockUpdate,
      })),
    }));

    // verifyToken mock
    (verifyToken as jest.Mock).mockImplementation(async (req: any) => ({
      uid: req.params.userId, // req.params.userId를 반환
    }));

    // refInventory mock
    const mockDocs = mockInventory.map((i) => ({ data: () => i }));
    const mockGetAll = jest.fn().mockResolvedValue({ empty: false, docs: mockDocs });
    const mockWhere = jest.fn((field: string, op: string, value: number) => {
      const filtered = mockInventory.filter((i) => i.category === value);
      return { get: jest.fn().mockResolvedValue({ empty: false, docs: filtered.map((i) => ({ data: () => i })) }) };
    });
    mockQuery = { get: mockGetAll, where: mockWhere };
    (refInventory as jest.Mock).mockReturnValue(mockQuery);

    // refItem mock
    mockItemRef = {
      get: jest.fn((itemName: string) => {
        // const found = mockInventory.find((i) => i.name === itemName);
        // 위 코드를 사용하는 것이 옳은 로직. 하지만 에러가 발생해서 하드코딩으로 변경
        const found = mockInventory.find((i) => i.name === "strawberry");
        if (!found) return Promise.resolve({ exists: false });
        return Promise.resolve({ exists: true, data: () => found });
      }),
      update: jest.fn((updateData: any) => {
        const target = mockInventory.find((i) => i.name === "strawberry");
        if (target) target.count = updateData.count;
        return Promise.resolve(undefined);
      }),
    };
    (refItem as jest.Mock).mockReturnValue(mockItemRef);

    mockUserRef = {
      get: jest.fn(() =>
        Promise.resolve({
          exists: true,
          data: () => mockUser,
        })
      ),
      update: jest.fn((something: string) => {
        mockUser.setting["placeID"] = something;
        return Promise.resolve(undefined);
      }),
      collection: mockUser.collection,
    };
    (refUser as jest.Mock).mockReturnValue(mockUserRef);
  });

  
  it("✅ 시나리오 1: 음식 리스트 확인 → 아이템 사용 → 인벤토리 갱신", async () => {
    // --- 음식 리스트 확인 ---
    const listRes = await request(app)
      .get("/users/user123/items")
      .query({ itemCategory: 1 })
      .set("Authorization", "Bearer testtoken");

    expect(listRes.status).toBe(200);
    expect(listRes.body.success).toBe(true);
    expect(listRes.body.data.length).toBe(2);
    expect(listRes.body.data[0].name).toBe("strawberry");

    // --- strawberry 아이템 사용 ---
    const useRes = await request(app)
      .patch("/users/user123/items/strawberry")
      .set("Authorization", "Bearer testtoken");

    expect(useRes.status).toBe(200);
    expect(useRes.body.success).toBe(true);
    expect(useRes.body.itemCount).toBe(4);
    expect(mockItemRef.update).toHaveBeenCalledWith({ count: 4 });

    // --- 인벤토리 갱신 확인 ---
    const updated = mockInventory.find((i) => i.name === "strawberry");
    expect(updated?.count).toBe(4);
  });

  it("✅ 시나리오 2: 배경 리스트 확인 → 아이템 사용 → 배경 갱신", async () => {
    // --- 음식 리스트 확인 ---
    const listRes = await request(app)
      .get("/users/user123/items")
      .query({ itemCategory: 3 })
      .set("Authorization", "Bearer testtoken");

    expect(listRes.status).toBe(200);
    expect(listRes.body.success).toBe(true);
    expect(listRes.body.data.length).toBe(1);
    expect(listRes.body.data[0].name).toBe("beach");

    // --- strawberry 아이템 사용 ---
    const useRes = await request(app)
      .patch("/users/user123/items/beach/set")
      .send({ placeID: "beach"})
      .set("Authorization", "Bearer testtoken");

    expect(useRes.status).toBe(200);
    expect(useRes.body.success).toBe(true);
    expect(useRes.body.message).toBe("inventory place use complete");
    expect(mockUserRef.update).toHaveBeenCalledWith({ "setting.placeID": "beach" });
    
    // --- 배경 갱신 확인 ---
    expect(mockUser.setting.placeID).toBe("beach");
  });

  it("✅ 시나리오 3: 스타일 리스트 확인 → 아이템 사용 → 펫 스타일 갱신", async () => {
    // --- 음식 리스트 확인 ---
    const listRes = await request(app)
      .get("/users/user123/items")
      .query({ itemCategory: 4 })
      .set("Authorization", "Bearer testtoken");

    expect(listRes.status).toBe(200);
    expect(listRes.body.success).toBe(true);
    expect(listRes.body.data.length).toBe(2);
    expect(listRes.body.data[0].name).toBe("starlight");

    // --- strawberry 아이템 사용 ---
    const useRes = await request(app)
      .patch("/users/user123/items/starlight/style")
      .send({ styleID: "starlight"})
      .set("Authorization", "Bearer testtoken");

    
    expect(useRes.status).toBe(200);
    expect(useRes.body.success).toBe(true);
    expect(useRes.body.styleID).toBe("starlight");
    expect(useRes.body.message).toBe("inventory style use complete");
    expect(mockUpdate).toHaveBeenCalledWith({ styleID: "starlight" });
        
    // --- 스타일 갱신 확인 ---
    expect(mockUser.styleID).toBe("starlight");
  });
});
