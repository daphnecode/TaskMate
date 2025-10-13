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

  beforeEach(() => {
    jest.clearAllMocks();
    (refUser as jest.Mock).mockReturnValue({ update: mockUpdate });
  });

  it('✅ should update nowPet when authorized and petName is provided', async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: 'user123' });

    const res = await request(app)
      .patch('/users/user123/nowPet')
      .send({ petName: 'Dino' });

    expect(verifyToken).toHaveBeenCalled();
    expect(mockUpdate).toHaveBeenCalledWith({ nowPet: 'Dino' });
    expect(res.status).toBe(200);
    expect(res.body).toEqual({
      success: true,
      message: 'pet choose complete',
      petName: 'Dino',
    });
  });

  it('❌ should return 403 if uid mismatch', async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: 'otherUser' });

    const res = await request(app)
      .patch('/users/user123/nowPet')
      .send({ petName: 'Dino' });

    expect(res.status).toBe(403);
    expect(res.body.message).toBe('Forbidden');
    expect(mockUpdate).not.toHaveBeenCalled();
  });

  it('❌ should return 400 if petName missing', async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: 'user123' });

    const res = await request(app)
      .patch('/users/user123/nowPet')
      .send({});

    expect(res.status).toBe(400);
    expect(res.body.message).toBe('petName is required');
    expect(mockUpdate).not.toHaveBeenCalled();
  });

  it('❌ should return 401 if token invalid', async () => {
    (verifyToken as jest.Mock).mockRejectedValue(new Error('Invalid token'));

    const res = await request(app)
      .patch('/users/user123/nowPet')
      .send({ petName: 'Dino' });

    expect(res.status).toBe(401);
    expect(res.body.message).toBe('Invalid token');
  });
});

describe('GET /users/:userId/pets/:petName', () => {
  const mockDoc = { get: jest.fn() };

  beforeEach(() => {
    jest.clearAllMocks();
    (refPets as jest.Mock).mockReturnValue({
      doc: jest.fn().mockReturnValue(mockDoc),
    });
  });

  it('✅ should return pet data when authorized', async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: 'user123' });
    mockDoc.get.mockResolvedValue({
      exists: true,
      data: () => ({ name: 'Dino', level: 5, happiness: 80 }),
    });

    const res = await request(app).get('/users/user123/pets/Dino');

    expect(verifyToken).toHaveBeenCalled();
    expect(refPets).toHaveBeenCalledWith('user123');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({
      success: true,
      message: 'pet condition read complete',
      data: { name: 'Dino', level: 5, happiness: 80 },
    });
  });

  it('❌ should return 403 if uid mismatch', async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: 'otherUser' });

    const res = await request(app).get('/users/user123/pets/Dino');

    expect(res.status).toBe(403);
    expect(res.body.message).toBe('Forbidden');
  });

  it('❌ should return 404 if pet not found', async () => {
    (verifyToken as jest.Mock).mockResolvedValue({ uid: 'user123' });
    mockDoc.get.mockResolvedValue({ exists: false });

    const res = await request(app).get('/users/user123/pets/Dino');

    expect(res.status).toBe(404);
    expect(res.body.message).toBe('Pet not found');
  });

  it('❌ should return 401 if token invalid', async () => {
    (verifyToken as jest.Mock).mockRejectedValue(new Error('Invalid token'));

    const res = await request(app).get('/users/user123/pets/Dino');

    expect(res.status).toBe(401);
    expect(res.body.message).toBe('Invalid token');
  });
});
