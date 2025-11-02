// src/__tests__/integration.test.ts
import express from "express";
import request from "supertest";
import itemRouter from "../src/pet/itemload"; // router default import

// Firebase mock
jest.mock("../src/pet/refAPI", () => ({
  verifyToken: jest.fn(),
  refItem: jest.fn(),
  refUser: jest.fn(),
  refPets: jest.fn(),
  refStats: jest.fn(),
  refInventory: jest.fn(),
}));

import { verifyToken, refInventory, refItem, refUser, refPets, refStats } from "../src/pet/refAPI";

describe("🐾 [INTEGRATION] 사용자 인벤토리 및 아이템 사용 통합 시나리오", () => {
  let app: express.Express;
  let mockInventory: any[];
  let mockUserRef: any;
  let mockItemRef: any;
  let mockPetRef: any;
  

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use("/users", itemRouter);

    (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });
    mockInventory = [
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
        name: "starlight", category: 4,
        count: 1, happy: 5, hunger: 0,
        price: 10, itemText: "sweet and sour",
      })},
      {data: () => ({
        icon: "assets/icons/icon-chicken.png",
        name: "beach", category: 3,
        count: 1, happy: 20, hunger: 50,
        price: 150, itemText: "wow",
      })}, 
    ];
    // 전체 데이터를 반환하는 get()
    const mockGetAll = jest.fn().mockResolvedValue({ empty: false, docs: mockInventory });

    // where("category", "==", value) 호출 시 필터링된 mockDocs만 반환
    const mockWhere = jest.fn((field: string, op: string, value: number) => {
      const filteredInventory = mockInventory.filter((d) => d.data().category === value);
      return { get: jest.fn().mockResolvedValue({ empty: false, docs: filteredInventory }) };
    });

    const mockQuery = { get: mockGetAll, where: mockWhere };
    (refInventory as jest.Mock).mockReturnValue(mockQuery);

    const mockPetSnap = {
      exists: true,
      data: () => ({styleID: "default",happy: 30, hunger: 50}),
    };
    
    mockPetRef = {
      get: jest.fn().mockResolvedValue(mockPetSnap),
      update: jest.fn(),
      set: jest.fn(),
    };
    (refPets as jest.Mock).mockReturnValue(mockPetRef);

    const mockUserSnap = {
      exists: true, data: () => ({nowPet: "petA", setting: {placeID: "default"}}),
    };

    mockUserRef = {
      get: jest.fn().mockResolvedValue(mockUserSnap),
      collection: jest.fn().mockImplementation((collectionName: string) => {
        if (collectionName === "pets") {
          return {
            doc: jest.fn().mockImplementation((petId: string) => mockPetRef),
          };
        }
        // 다른 컬렉션 대비 안전장치
        return {
          doc: jest.fn().mockReturnValue({ get: jest.fn(), update: jest.fn() }),
        };
      }),
      update: jest.fn().mockResolvedValue(undefined),
      doc: jest.fn().mockReturnValue(mockPetRef),
    };
    (refUser as jest.Mock).mockReturnValue(mockUserRef);
 
    
    const mockSnap = { exists: true,
      data: () => ({ icon: "assets/icons/icon-strawberry.png", name: "strawberry", category: 1, count: 5, happy: 5, hunger: 0, price: 10, itemText: "sweet and sour" })
    };
    mockItemRef = {
      get: jest.fn().mockResolvedValue(mockSnap),
      update: jest.fn().mockResolvedValue(undefined), 
    };
    (refItem as jest.Mock).mockReturnValue(mockItemRef);

    const mockFoodDocRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({ count: 1 }),
      }),
      update: jest.fn(),
    };

    const mockStatsSnap = {
      exists: true,
      data: () => ({ feeding: 5, moreHappy: 10 }),
    };

    const mockStatsRef = {
      get: jest.fn().mockResolvedValue(mockStatsSnap),
      update: jest.fn(),
      collection: jest.fn().mockImplementation((collectionName: string) => {
        if (collectionName === "foodCount") {
          return {
            doc: jest.fn().mockImplementation(
              (itemName: string) => mockFoodDocRef),
          };
        }
        // 다른 컬렉션 대비 안전장치
        return {
          doc: jest.fn().mockReturnValue({ get: jest.fn(), update: jest.fn() }),
        };
      }),
    };
    (refStats as jest.Mock).mockReturnValue(mockStatsRef);

  });

  
  it("✅ 시나리오 1: 음식 리스트 확인 → 아이템 사용 → 인벤토리 갱신", async () => {
    // --- 음식 리스트 확인 ---
    const listRes = await request(app)
      .get("/users/user123/items")
      .query({ itemCategory: 1 })
      .set("Authorization", "Bearer testtoken");

    expect(listRes.status).toBe(200);
    expect(listRes.body.success).toBe(true);
    expect(listRes.body.data.length).toBe(5);
    expect(listRes.body.data[0].name).toBe("cookie");

    // --- strawberry 아이템 사용 ---
    const useRes = await request(app)
      .patch("/users/user123/items/strawberry")
      .set("Authorization", "Bearer testtoken");

    expect(useRes.status).toBe(200);
    expect(useRes.body.success).toBe(true);
    expect(useRes.body.itemCount).toBe(4);
    expect(mockItemRef.update).toHaveBeenCalledWith({ count: 4 });

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
    
  });

  it("✅ 시나리오 3: 스타일 리스트 확인 → 아이템 사용 → 펫 스타일 갱신", async () => {
    // --- 음식 리스트 확인 ---
    const listRes = await request(app)
      .get("/users/user123/items")
      .query({ itemCategory: 4 })
      .set("Authorization", "Bearer testtoken");

    expect(listRes.status).toBe(200);
    expect(listRes.body.success).toBe(true);
    expect(listRes.body.data.length).toBe(1);
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
    expect(mockPetRef.update).toHaveBeenCalledWith({ styleID: "starlight" });
        
  });
});
