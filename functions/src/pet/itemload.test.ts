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

describe("Inventory API", () => {

  beforeEach(() => {
    jest.clearAllMocks();
  });

  // ✅ [GET] /users/:userId/items
  it("should return inventory list successfully", async () => {
    // mock verifyToken
    (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });

    // mock refInventory().get()
    const mockDocs = [
      { data: () => ({ icon: "🍎", name: "apple", category: 1, count: 5, price: 10, itemText: "fruit" }) },
    ];
    const mockQuery = { get: jest.fn().mockResolvedValue({ empty: false, docs: mockDocs }) };
    (refInventory as jest.Mock).mockReturnValue(mockQuery);

    const res = await request(app)
      .get("/users/user123/items")
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.length).toBe(1);
    expect(res.body.data[0].name).toBe("apple");
  });

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

