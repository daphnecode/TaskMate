import express from 'express';
import request from 'supertest';

const authMocks = { verifyIdToken: jest.fn() };
jest.mock('firebase-admin/auth', () => ({ getAuth: () => authMocks }));

import dailyRouter from '../src/planner/daily_function';

// 동일 mock 인스턴스의 db를 검증용으로 사용
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { db } = require('../src/__mocks__/firebase.js');
const app = express();
app.use(express.json());
app.use('/daily', dailyRouter);

describe('Daily Router', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('GET /daily/read/:userId/:dateKey', () => {
    it('✅ 문서가 없으면 빈 목록 + submitted:false, lastSubmit:""', async () => {
      authMocks.verifyIdToken.mockResolvedValue({ uid: 'u1' });

      const res = await request(app)
        .get('/daily/read/u1/2025-10-20')
        .set('Authorization', 'Bearer token');

      expect(authMocks.verifyIdToken).toHaveBeenCalled();
      expect(res.status).toBe(200);
      expect(res.body).toEqual({
        success: true,
        message: 'daily read complete',
        tasks: [],
        submitted: false,
        lastSubmit: '',
      });
    });

    it('✅ 문서가 있으면 tasks 매핑 + submitted/lastSubmit 포함', async () => {
      const uid = 'u2';
      const dateKey = '2025-10-21';
      // 사전 데이터 주입
      await db
        .collection('Users')
        .doc(uid)
        .collection('dailyTasks')
        .doc(dateKey)
        .set({
          tasks: [
            { text: 'A', point: 10, isChecked: true },
            // 옛 필드명도 매핑 확인(t.todoText, t.todoPoint, t.todoCheck)
            { todoText: 'B', todoPoint: 5, todoCheck: false },
          ],
          meta: { submitted: true, lastSubmit: '2025-10-20' },
        });

      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .get(`/daily/read/${uid}/${dateKey}`)
        .set('Authorization', 'Bearer token');

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.tasks).toEqual([
        { text: 'A', point: 10, isChecked: true },
        { text: 'B', point: 5, isChecked: false },
      ]);
      expect(res.body.submitted).toBe(true);
      expect(res.body.lastSubmit).toBe('2025-10-20');
    });

    it('❌ uid 불일치 → 403', async () => {
      authMocks.verifyIdToken.mockResolvedValue({ uid: 'other' });

      const res = await request(app)
        .get('/daily/read/u3/2025-10-22')
        .set('Authorization', 'Bearer token');

      expect(res.status).toBe(403);
      expect(res.body.message).toBe('Forbidden');
    });

    it('❌ 토큰 오류 → 401', async () => {
      authMocks.verifyIdToken.mockRejectedValue(new Error('Invalid token'));

      const res = await request(app)
        .get('/daily/read/u4/2025-10-23')
        .set('Authorization', 'Bearer token');

      expect(res.status).toBe(401);
      expect(res.body.message).toBe('Invalid token');
    });
  });

  describe('POST /daily/save/:userId/:dateKey', () => {
    it('✅ tasks 덮어쓰기 + meta.submitted/lastSubmit 보존', async () => {
      const uid = 'u5';
      const dateKey = '2025-10-24';
      // 이전 제출 이력 존재
      await db
        .collection('Users')
        .doc(uid)
        .collection('dailyTasks')
        .doc(dateKey)
        .set({ meta: { submitted: true, lastSubmit: '2025-10-23' } });

      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .post(`/daily/save/${uid}/${dateKey}`)
        .set('Authorization', 'Bearer token')
        .send({
          tasks: [
            { text: 'New1', point: 3, isChecked: false },
            { todoText: 'OldName', todoPoint: 7, todoCheck: true },
          ],
        });

      expect(res.status).toBe(200);
      expect(res.body.message).toBe('daily save complete');

      const saved = (
        await db.collection('Users').doc(uid).collection('dailyTasks').doc(dateKey).get()
      ).data();
      expect(saved.tasks).toEqual([
        { text: 'New1', point: 3, isChecked: false },
        { text: 'OldName', point: 7, isChecked: true },
      ]);
      expect(saved.meta.submitted).toBe(true);
      expect(saved.meta.lastSubmit).toBe('2025-10-23');
      expect(typeof saved.meta.lastUpdated).toBe('string');
    });

    it('❌ uid 불일치 → 403', async () => {
      authMocks.verifyIdToken.mockResolvedValue({ uid: 'someone' });
      const res = await request(app)
        .post('/daily/save/u6/2025-10-24')
        .set('Authorization', 'Bearer token')
        .send({ tasks: [] });
      expect(res.status).toBe(403);
    });

    it('❌ 토큰 오류 → 401', async () => {
      authMocks.verifyIdToken.mockRejectedValue(new Error('Invalid token'));
      const res = await request(app)
        .post('/daily/save/u7/2025-10-24')
        .set('Authorization', 'Bearer token')
        .send({ tasks: [] });
      expect(res.status).toBe(401);
      expect(res.body.message).toBe('Invalid token');
    });
  });

  describe('PATCH /daily/update/:userId/:dateKey/:todoId', () => {
    it('✅ 특정 항목 text/point 수정', async () => {
      const uid = 'u8';
      const dateKey = '2025-10-25';
      await db.collection('Users').doc(uid).collection('dailyTasks').doc(dateKey).set({
        tasks: [{ text: 'A', point: 1, isChecked: false }, { text: 'B', point: 2, isChecked: true }],
      });

      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .patch(`/daily/update/${uid}/${dateKey}/1`) // index=1 항목 수정
        .set('Authorization', 'Bearer token')
        .send({ text: 'B2', point: 5 });

      expect(res.status).toBe(200);
      expect(res.body.message).toBe('daily update complete');
      expect(res.body.todoText).toBe('B2');
      expect(res.body.todoPoint).toBe(5);

      const saved = (
        await db.collection('Users').doc(uid).collection('dailyTasks').doc(dateKey).get()
      ).data();
      expect(saved.tasks[1]).toMatchObject({ text: 'B2', point: 5 });
    });

    it('❌ 없는 todoId → 404', async () => {
      const uid = 'u9';
      const dateKey = '2025-10-26';
      await db.collection('Users').doc(uid).collection('dailyTasks').doc(dateKey).set({
        tasks: [{ text: 'Only', point: 1, isChecked: false }],
      });

      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .patch(`/daily/update/${uid}/${dateKey}/5`) // out of range
        .set('Authorization', 'Bearer token')
        .send({ text: 'X' });

      expect(res.status).toBe(404);
      expect(res.body.message).toBe('Todo not found');
    });
  });

  describe('PATCH /daily/check/:userId/:dateKey/:todoId', () => {
    it('✅ 체크 토글 (isChecked: true)', async () => {
      const uid = 'u10';
      const dateKey = '2025-10-27';
      await db.collection('Users').doc(uid).collection('dailyTasks').doc(dateKey).set({
        tasks: [{ text: 'T', point: 1, isChecked: false }],
      });
      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .patch(`/daily/check/${uid}/${dateKey}/0`)
        .set('Authorization', 'Bearer token')
        .send({ isChecked: true });

      expect(res.status).toBe(200);
      expect(res.body.message).toBe('daily check complete');

      const saved = (
        await db.collection('Users').doc(uid).collection('dailyTasks').doc(dateKey).get()
      ).data();
      expect(saved.tasks[0].isChecked).toBe(true);
    });

    it('❌ body에 todoCheck/isChecked 없음 → 400', async () => {
      const uid = 'u11';
      const dateKey = '2025-10-28';
      await db.collection('Users').doc(uid).collection('dailyTasks').doc(dateKey).set({
        tasks: [{ text: 'T', point: 1, isChecked: false }],
      });
      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .patch(`/daily/check/${uid}/${dateKey}/0`)
        .set('Authorization', 'Bearer token')
        .send({});

      expect(res.status).toBe(400);
      expect(res.body.message).toBe('todoCheck required');
    });
  });

  describe('DELETE /daily/delete/:userId/:dateKey/:todoId', () => {
    it('✅ 항목 삭제', async () => {
      const uid = 'u12';
      const dateKey = '2025-10-29';
      await db.collection('Users').doc(uid).collection('dailyTasks').doc(dateKey).set({
        tasks: [
          { text: 'A', point: 1, isChecked: false },
          { text: 'B', point: 2, isChecked: false },
        ],
      });
      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .delete(`/daily/delete/${uid}/${dateKey}/0`) // index=0 삭제
        .set('Authorization', 'Bearer token');

      expect(res.status).toBe(200);
      expect(res.body.message).toBe('daily delete complete');

      const saved = (
        await db.collection('Users').doc(uid).collection('dailyTasks').doc(dateKey).get()
      ).data();
      expect(saved.tasks.length).toBe(1);
      expect(saved.tasks[0].text).toBe('B');
    });
  });

  describe('POST /daily/submit/:userId/:dateKey', () => {
    it('✅ 제출 플래그/제출일 기록', async () => {
      const uid = 'u13';
      const dateKey = '2025-10-30';
      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .post(`/daily/submit/${uid}/${dateKey}`)
        .set('Authorization', 'Bearer token');

      expect(res.status).toBe(200);
      expect(res.body.message).toBe('daily submit complete');

      const saved = (
        await db.collection('Users').doc(uid).collection('dailyTasks').doc(dateKey).get()
      ).data();
      expect(saved.meta.submitted).toBe(true);
      expect(saved.meta.lastSubmit).toBe(dateKey);
      expect(typeof saved.meta.lastUpdated).toBe('string');
    });
  });
});
