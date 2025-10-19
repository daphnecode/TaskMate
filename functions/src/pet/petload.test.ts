import express from 'express';
import request from 'supertest';
import * as router from './petload';

// ✅ verifyToken, refUser, refPets를 mock 처리
jest.mock('./refAPI', () => ({
  verifyToken: jest.fn(),
  refUser: jest.fn(),
  refPets: jest.fn(),
}));

import { verifyToken, refUser, refPets } from './refAPI';

const app = express();
app.use(express.json());
app.use('/users', router.default);

describe('PATCH /users/:userId/nowPet', () => {
  const mockUpdate = jest.fn();

  beforeAll(() => {
    jest.spyOn(console, "error").mockImplementation(() => {});
  });

  afterAll(() => {
    (console.error as jest.Mock).mockRestore();
  });

  beforeEach(() => {
    jest.clearAllMocks();
    (refUser as jest.Mock).mockReturnValue({ update: mockUpdate });
  });

  it('✅ 현재 키울 펫 선택하기', async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: 'user123' });

    const res = await request(app)
      .patch('/users/user123/nowPet')
      .send({ petName: 'Dino' })
      .set("Authorization", "Bearer testtoken");

    expect(verifyToken).toHaveBeenCalled();
    expect(mockUpdate).toHaveBeenCalledWith({ nowPet: 'Dino' });
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.petName).toBe('Dino')
  });

  it('❌ 사용자 id 불일치', async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: 'otherUser' });

    const res = await request(app)
      .patch('/users/user123/nowPet')
      .send({ petName: 'Dino' })
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(403);
    expect(res.body.message).toBe('Forbidden');
    expect(mockUpdate).not.toHaveBeenCalled();
  });

  it('❌ 펫 이름이 없을 경우', async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: 'user123' });

    const res = await request(app)
      .patch('/users/user123/nowPet')
      .send({})
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(400);
    expect(res.body.message).toBe('petName is required');
    expect(mockUpdate).not.toHaveBeenCalled();
  });

  it('❌ 사용자 인증 실패', async () => {
    (verifyToken as jest.Mock).mockRejectedValue(new Error('Invalid token'));

    const res = await request(app)
      .patch('/users/user123/nowPet')
      .send({ petName: 'Dino' })
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(401);
    expect(res.body.message).toBe('Invalid token');
  });

  it("❌ 서버 응답 오류", async () => {
      (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });
  
      // refPets().doc().get() 호출 시 에러 던지기
      const mockGet = jest.fn().mockRejectedValue(new Error('Firestore failure'));
      const mockDoc = jest.fn().mockReturnValue({ get: mockGet });
      (refUser as jest.Mock).mockReturnValue({ doc: mockDoc });

      const res = await request(app)
        .patch('/users/user123/nowPet')
        .send({ petName: 'Dino' })
        .set("Authorization", "Bearer testtoken");

      expect(res.status).toBe(500);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toBe("Internal server error");
  });

});

describe('GET /users/:userId/pets/:petName', () => {
  const mockDoc = { get: jest.fn() };

  beforeAll(() => {
    jest.spyOn(console, "error").mockImplementation(() => {});
  });

  afterAll(() => {
    (console.error as jest.Mock).mockRestore();
  });


  beforeEach(() => {
    jest.clearAllMocks();
    (refPets as jest.Mock).mockReturnValue({
      doc: jest.fn().mockReturnValue(mockDoc),
    });
  });

  it('✅ 펫의 상태 정보 조회하기', async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: 'user123' });
    mockDoc.get.mockResolvedValue({
      exists: true,
      data: () => ({ name: 'Dino', level: 5, happiness: 80 }),
    });

    const res = await request(app)
      .get('/users/user123/pets/Dino')
      .set("Authorization", "Bearer testtoken");

    expect(verifyToken).toHaveBeenCalled();
    expect(refPets).toHaveBeenCalledWith('user123');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({
      success: true,
      message: 'pet condition read complete',
      data: { name: 'Dino', level: 5, happiness: 80 },
    });
  });

  it('❌ 사용자 id 불일치', async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: 'otherUser' });

    const res = await request(app)
      .get('/users/user123/pets/Dino')
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(403);
    expect(res.body.message).toBe('Forbidden');
  });

  it('❌ 펫 정보가 없을 경우', async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: 'user123' });
    mockDoc.get.mockResolvedValue({ exists: false });

    const res = await request(app)
      .get('/users/user123/pets/Dino')
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(404);
    expect(res.body.message).toBe('Pet not found');
  });

  it('❌ 사용자 인증 실패', async () => {
    (verifyToken as jest.Mock).mockRejectedValue(new Error('Invalid token'));

    const res = await request(app)
      .get('/users/user123/pets/Dino')
      .set("Authorization", "Bearer testtoken");

    expect(res.status).toBe(401);
    expect(res.body.message).toBe('Invalid token');
  });

  it("❌ 서버 응답 오류", async () => {
      (verifyToken as jest.Mock).mockResolvedValue({ uid: "user123" });
  
      // refPets().doc().get() 호출 시 에러 던지기
      const mockGet = jest.fn().mockRejectedValue(new Error('Firestore failure'));
      const mockDoc = jest.fn().mockReturnValue({ get: mockGet });
      (refPets as jest.Mock).mockReturnValue({ doc: mockDoc });

      const res = await request(app)
        .get('/users/user123/pets/Dino')
        .set("Authorization", "Bearer testtoken");
  
      expect(res.status).toBe(500);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toBe("Internal server error");
  });

});
