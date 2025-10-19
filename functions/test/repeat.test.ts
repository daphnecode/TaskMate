// functions/test/repeat.test.ts
import express from 'express';
import request from 'supertest';

// firebase-admin/auth 목: verifyIdToken 컨트롤
const authMocks = { verifyIdToken: jest.fn() };
jest.mock('firebase-admin/auth', () => ({
  getAuth: () => authMocks,
}));

// 라우터 import (프로젝트 구조에 맞게)
import repeatRouter from '../src/planner/repeat_function';

// 같은 in-memory Firestore mock 인스턴스를 검증용으로 사용
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { db } = require('../src/__mocks__/firebase.js');

const app = express();
app.use(express.json());
// 실제 index.ts에선 /repeatList, /dailyList 둘 다에 mount된다고 주석에 쓰여있지만,
// 테스트에선 심플하게 /repeat 로만 붙여서 검증한다.
app.use('/repeat', repeatRouter);

// YYYY-MM-DD 패턴 체크용
const isDateKey = (s: string) => /^\d{4}-\d{2}-\d{2}$/.test(s);

describe('Repeat Router', () => {
  beforeAll(() => {
    jest.spyOn(console, "error").mockImplementation(() => {});
    jest.spyOn(console, "log").mockImplementation(() => {});
  });

  afterAll(() => {
    (console.error as jest.Mock).mockRestore();
    (console.log as jest.Mock).mockRestore();
  });
  
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('GET /repeat/read/:userId', () => {
    it('✅ 문서가 없으면 data:[], meta:{} 반환', async () => {
      authMocks.verifyIdToken.mockResolvedValue({ uid: 'r1' });

      const res = await request(app)
        .get('/repeat/read/r1')
        .set('Authorization', 'Bearer token');

      expect(authMocks.verifyIdToken).toHaveBeenCalled();
      expect(res.status).toBe(200);
      expect(res.body).toEqual({
        success: true,
        message: 'repeatList read complete',
        data: [],
        meta: {},
      });
    });

    it('✅ 문서가 있으면 tasks 표준화 및 meta.lastUpdated 정규화', async () => {
      const uid = 'r2';
      // 사전 데이터 주입 (구키/신키 섞어서)
      await db.collection('Users').doc(uid).collection('repeatTasks').doc('default').set({
        tasks: [
          { text: 'A', point: 3, isChecked: true },
          { todoText: 'B', todoPoint: 7, todoCheck: false },
        ],
        meta: { lastUpdated: '2025-11-03T12:00:00Z' }, // 문자열 → KST YYYY-MM-DD로 정규화됨
      });

      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .get(`/repeat/read/${uid}`)
        .set('Authorization', 'Bearer token');

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toEqual([
        { text: 'A', point: 3, isChecked: true },
        { text: 'B', point: 7, isChecked: false },
      ]);
      // meta.lastUpdated가 존재하면 YYYY-MM-DD여야 함
      if (res.body.meta.lastUpdated) {
        expect(isDateKey(res.body.meta.lastUpdated)).toBe(true);
      }
    });

    it('❌ uid 불일치 → 403', async () => {
      authMocks.verifyIdToken.mockResolvedValue({ uid: 'other' });

      const res = await request(app)
        .get('/repeat/read/r3')
        .set('Authorization', 'Bearer token');

      expect(res.status).toBe(403);
      expect(res.body.message).toBe('Forbidden');
    });

    it('❌ 토큰 오류 → 401', async () => {
      authMocks.verifyIdToken.mockRejectedValue(new Error('Invalid token'));

      const res = await request(app)
        .get('/repeat/read/r4')
        .set('Authorization', 'Bearer token');

      expect(res.status).toBe(401);
      expect(res.body.message).toBe('Invalid token');
    });
  });

  describe('POST /repeat/save/:userId', () => {
    it('✅ 전체 덮어쓰기 + meta.lastUpdated 지정값(YYYY-MM-DD) 보존', async () => {
      const uid = 'r5';
      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .post(`/repeat/save/${uid}`)
        .set('Authorization', 'Bearer token')
        .send({
          tasks: [
            { text: 'N1', point: 1, isChecked: false },
            { todoText: 'N2', todoPoint: 5, todoCheck: true },
          ],
          // 문자열/epoch/날짜 다 허용인데, 테스트는 YYYY-MM-DD로 명시 → 그대로 저장 기대
          meta: { lastUpdated: '2025-11-05' },
        });

      expect(res.status).toBe(200);
      expect(res.body.message).toBe('repeatList save complete');

      const saved = (
        await db.collection('Users').doc(uid).collection('repeatTasks').doc('default').get()
      ).data();

      expect(saved.tasks).toEqual([
        { text: 'N1', point: 1, isChecked: false },
        { text: 'N2', point: 5, isChecked: true },
      ]);
      expect(saved.meta.lastUpdated).toBe('2025-11-05');
    });

    it('✅ meta.lastUpdated 미제공 → 오늘 KST dateKey 저장', async () => {
      const uid = 'r6';
      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .post(`/repeat/save/${uid}`)
        .set('Authorization', 'Bearer token')
        .send({ tasks: [] });

      expect(res.status).toBe(200);

      const saved = (
        await db.collection('Users').doc(uid).collection('repeatTasks').doc('default').get()
      ).data();

      expect(isDateKey(saved.meta.lastUpdated)).toBe(true);
    });

    it('❌ uid 불일치 → 403', async () => {
      authMocks.verifyIdToken.mockResolvedValue({ uid: 'wrong' });

      const res = await request(app)
        .post('/repeat/save/r7')
        .set('Authorization', 'Bearer token')
        .send({ tasks: [] });

      expect(res.status).toBe(403);
      expect(res.body.message).toBe('Forbidden');
    });
  });

  describe('POST /repeat/add/:userId', () => {
    it('✅ 항목 추가 & 응답 확인(todoID, text, point, check)', async () => {
      const uid = 'r8';
      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .post(`/repeat/add/${uid}`)
        .set('Authorization', 'Bearer token')
        .send({ todoText: 'X', todoPoint: 9, todoCheck: true });

      expect(res.status).toBe(200);
      expect(res.body.message).toBe('dailyList add complete');
      expect(res.body.todoText).toBe('X');
      expect(res.body.todoPoint).toBe(9);
      expect(res.body.todoCheck).toBe(true);
      expect(typeof res.body.todoID).toBe('string');

      const saved = (
        await db.collection('Users').doc(uid).collection('repeatTasks').doc('default').get()
      ).data();
      expect(saved.tasks).toEqual([{ text: 'X', point: 9, isChecked: true }]);
      expect(isDateKey(saved.meta.lastUpdated)).toBe(true);
    });
  });

  describe('PATCH /repeat/update/:userId/:todoId', () => {
    it('✅ 특정 항목 text/point 수정', async () => {
      const uid = 'r9';
      await db.collection('Users').doc(uid).collection('repeatTasks').doc('default').set({
        tasks: [{ text: 'A', point: 1, isChecked: false }, { text: 'B', point: 2, isChecked: true }],
      });

      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .patch(`/repeat/update/${uid}/1`) // index=1 수정
        .set('Authorization', 'Bearer token')
        .send({ text: 'B2', point: 7 });

      expect(res.status).toBe(200);
      expect(res.body.message).toBe('dailyList update complete');
      expect(res.body.todoText).toBe('B2');
      expect(res.body.todoPoint).toBe(7);

      const saved = (
        await db.collection('Users').doc(uid).collection('repeatTasks').doc('default').get()
      ).data();
      expect(saved.tasks[1]).toMatchObject({ text: 'B2', point: 7 });
      expect(isDateKey(saved.meta.lastUpdated)).toBe(true);
    });

    it('❌ 없는 todoId → 404', async () => {
      const uid = 'r10';
      await db.collection('Users').doc(uid).collection('repeatTasks').doc('default').set({
        tasks: [{ text: 'Only', point: 1, isChecked: false }],
      });

      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .patch(`/repeat/update/${uid}/5`)
        .set('Authorization', 'Bearer token')
        .send({ text: 'X' });

      expect(res.status).toBe(404);
      expect(res.body.message).toBe('Todo not found');
    });
  });

  describe('PATCH /repeat/check/:userId/:todoId', () => {
    it('✅ 체크 값을 true로 설정', async () => {
      const uid = 'r11';
      await db.collection('Users').doc(uid).collection('repeatTasks').doc('default').set({
        tasks: [{ text: 'T', point: 1, isChecked: false }],
      });

      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .patch(`/repeat/check/${uid}/0`)
        .set('Authorization', 'Bearer token')
        .send({ isChecked: true });

      expect(res.status).toBe(200);
      expect(res.body.message).toBe('dailyList check complete');

      const saved = (
        await db.collection('Users').doc(uid).collection('repeatTasks').doc('default').get()
      ).data();
      expect(saved.tasks[0].isChecked).toBe(true);
      expect(isDateKey(saved.meta.lastUpdated)).toBe(true);
    });

    it('❌ body에 todoCheck/isChecked 없음 → 400', async () => {
      const uid = 'r12';
      await db.collection('Users').doc(uid).collection('repeatTasks').doc('default').set({
        tasks: [{ text: 'T', point: 1, isChecked: false }],
      });

      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .patch(`/repeat/check/${uid}/0`)
        .set('Authorization', 'Bearer token')
        .send({});

      expect(res.status).toBe(400);
      expect(res.body.message).toBe('todoCheck required');
    });
  });

  describe('DELETE /repeat/delete/:userId/:todoId', () => {
    it('✅ 항목 삭제', async () => {
      const uid = 'r13';
      await db.collection('Users').doc(uid).collection('repeatTasks').doc('default').set({
        tasks: [
          { text: 'A', point: 1, isChecked: false },
          { text: 'B', point: 2, isChecked: true },
        ],
      });

      authMocks.verifyIdToken.mockResolvedValue({ uid });

      const res = await request(app)
        .delete(`/repeat/delete/${uid}/0`)
        .set('Authorization', 'Bearer token');

      expect(res.status).toBe(200);
      expect(res.body.message).toBe('dailyList delete complete');

      const saved = (
        await db.collection('Users').doc(uid).collection('repeatTasks').doc('default').get()
      ).data();
      expect(saved.tasks.length).toBe(1);
      expect(saved.tasks[0].text).toBe('B');
      expect(isDateKey(saved.meta.lastUpdated)).toBe(true);
    });
  });
});
