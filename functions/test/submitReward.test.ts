// functions/test/submitReward.test.ts
import 'jest';

// FieldValue mock
jest.mock('firebase-admin/firestore');

import { submitRewardAN3 } from '../src/submitReward';

// 같은 mock 인스턴스를 직접 require해서 사용 (Map 스토어 공유)
const { db } = require('../src/__mocks__/firebase.js');

// v2 onCall 호출 헬퍼
const call = (data: any, uid?: string) =>
  submitRewardAN3.run(
    uid ? ({ data, auth: { uid, token: {} as any } } as any)
        : ({ data } as any)
  );

describe('submitRewardAN3 (unit)', () => {
  it('✅ 정상 지급: currentPoint/gotPoint 증가 & 로그 생성', async () => {
    const uid = 'u_ok_1';
    const dateKey = '2025-10-15';

    const res = await call({ earned: 100, dateKey }, uid);
    expect(res).toEqual({ ok: true });

    const user = (await db.collection('Users').doc(uid).get()).data()!;
    expect(user.currentPoint).toBe(100);
    expect(user.gotPoint).toBe(100);

    const log = (await db.collection('Users').doc(uid).collection('log').doc(dateKey).get()).data()!;
    expect(log.rewarded).toBe(true);
    expect(log.earnedPoints).toBe(100);
    expect(log.rewardedBy).toBe('submitRewardAN3');
    expect(log.rewardedAt).toBeInstanceOf(Date);
  });

  it('🧯 중복 호출: 같은 dateKey 두 번 호출해도 1회만 반영', async () => {
    const uid = 'u_dup_1';
    const dateKey = '2025-10-16';

    await call({ earned: 50, dateKey }, uid);
    await call({ earned: 50, dateKey }, uid);

    const user = (await db.collection('Users').doc(uid).get()).data()!;
    expect(user.currentPoint).toBe(50);
    expect(user.gotPoint).toBe(50);

    const log = (await db.collection('Users').doc(uid).collection('log').doc(dateKey).get()).data()!;
    expect(log.earnedPoints).toBe(50);
  });

  it('↩️ earned <= 0: skipped 반환, DB 변화 없음', async () => {
    const uid = 'u_skip_1';
    const dateKey = '2025-10-17';

    const res = await call({ earned: 0, dateKey }, uid);
    expect(res).toEqual({ ok: true, skipped: true });

    const snap = await db.collection('Users').doc(uid).get();
    expect(snap.exists).toBe(false);
  });

  it('❌ 잘못된 인자: invalid-argument', async () => {
    const badUid = 'u_bad_1';
    const dateKey = '2025-10-18';

    // dateKey 누락(빈 문자열) → invalid-argument
    await expect(call({ earned: 100, dateKey: '' }, badUid))
      .rejects.toMatchObject({ code: 'invalid-argument' });

    // earned 타입 불량
    await expect(call({ earned: 'abc', dateKey }, badUid as any))
      .rejects.toMatchObject({ code: 'invalid-argument' });

    // earned NaN
    await expect(call({ earned: NaN, dateKey }, badUid))
      .rejects.toMatchObject({ code: 'invalid-argument' });

    // auth 없음
    await expect(call({ earned: 10, dateKey }))
      .rejects.toMatchObject({ code: 'invalid-argument' });
  });

  it('✅ data.uid 경로도 동작', async () => {
    const dateKey = '2025-10-19';
    const res = await call({ uid: 'force_uid_1', earned: 20, dateKey });
    expect(res).toEqual({ ok: true });

    const user = (await db.collection('Users').doc('force_uid_1').get()).data()!;
    expect(user.currentPoint).toBe(20);
    expect(user.gotPoint).toBe(20);
  });
});
