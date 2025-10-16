import 'jest';
import { submitPetExpAN3 } from '../src/submitPetEXP';
import { getLevelExp } from '../src/pet/levelExp';
const { db } = require('../src/__mocks__/firebase.js');

// ---------------------------------------------------------------------
// onCall 호출 헬퍼
const call = (data: any, uid?: string) =>
  submitPetExpAN3.run(
    uid ? ({ data, auth: { uid, token: {} as any } } as any)
        : ({ data } as any)
  );

// ---------------------------------------------------------------------
// 레벨업 시뮬레이터 (실제 커브 기반)
function simulateLeveling(startLevel: number, startExp: number, earned: number) {
  let lvl = startLevel;
  let exp = startExp + earned;
  const MAX_LEVEL = 100;
  while (lvl < MAX_LEVEL) {
    const cap = getLevelExp(lvl);
    if (exp < cap) break;
    exp -= cap;
    lvl++;
  }
  return { lvl, exp };
}

// ---------------------------------------------------------------------
describe('submitPetExpAN3 (unit)', () => {
  it('✅ 정상 지급: nowPet의 EXP/레벨 갱신 + 로그 기록', async () => {
    const uid = 'u_ok_1';
    const dateKey = '2025-10-15';

    // 초기 nowPet 세팅
    await db.collection('Users').doc(uid).set({ nowPet: 'Dino' });
    await db.collection('Users').doc(uid).collection('pets').doc('Dino').set({ level: 1, currentExp: 0 });

    const res = await call({ earned: 25, dateKey }, uid);
    expect(res.ok).toBe(true);

    // pet 상태 확인
    const pet = (await db.collection('Users').doc(uid).collection('pets').doc('Dino').get()).data()!;
    const expected = simulateLeveling(1, 0, 25);
    expect(pet.level).toBe(expected.lvl);
    expect(pet.currentExp).toBe(expected.exp);

    // log 기록 확인
    const log = (await db.collection('Users').doc(uid).collection('log').doc(dateKey).get()).data()!;
    expect(log.expRewarded).toBe(true);
    expect(log.earnedExp).toBe(25);
    expect(log.rewardedBy).toBe('submitPetExpAN3');
    expect(log.rewardedAt).toBeInstanceOf(Date);
  });

  it('🧯 중복 호출 방지: 같은 dateKey 재호출시 skipped (alreadyExpRewarded)', async () => {
    const uid = 'u_dup_1';
    const dateKey = '2025-10-16';
    await db.collection('Users').doc(uid).set({ nowPet: 'Cat' });
    await db.collection('Users').doc(uid).collection('pets').doc('Cat').set({ level: 1, currentExp: 0 });

    await call({ earned: 25, dateKey }, uid); // 첫 호출
    const res2 = await call({ earned: 25, dateKey }, uid); // 두 번째 호출
    expect(res2.skipped).toBe(true);
    expect(res2.reason).toBe('alreadyExpRewarded');

    // 펫은 첫 호출 상태 그대로
    const pet = (await db.collection('Users').doc(uid).collection('pets').doc('Cat').get()).data()!;
    const expected = simulateLeveling(1, 0, 25);
    expect(pet.level).toBe(expected.lvl);
    expect(pet.currentExp).toBe(expected.exp);
  });

  it('🔁 force=true면 중복이어도 강제 지급', async () => {
    const uid = 'u_force_1';
    const dateKey = '2025-10-17';
    await db.collection('Users').doc(uid).set({ nowPet: 'Fox' });
    await db.collection('Users').doc(uid).collection('pets').doc('Fox').set({ level: 1, currentExp: 0 });

    // 첫 호출
    await call({ earned: 25, dateKey }, uid);
    // 강제 재지급
    const res2 = await call({ earned: 25, dateKey, force: true }, uid);
    expect(res2.ok).toBe(true);

    const pet = (await db.collection('Users').doc(uid).collection('pets').doc('Fox').get()).data()!;
    const expected = simulateLeveling(1, 0, 50);
    expect(pet.level).toBe(expected.lvl);
    expect(pet.currentExp).toBe(expected.exp);
  });

  it('↩️ earned <= 0 → skipped(reason=earned<=0), DB 변화 없음', async () => {
    const uid = 'u_zero_1';
    const dateKey = '2025-10-18';
    const res = await call({ earned: 0, dateKey }, uid);
    expect(res.skipped).toBe(true);
    expect(res.reason).toBe('earned<=0');

    const user = await db.collection('Users').doc(uid).get();
    expect(user.exists).toBe(false);
  });

  it('❌ nowPet 없음 → skipped(reason=nowPetMissing)', async () => {
    const uid = 'u_nopet_1';
    const dateKey = '2025-10-19';
    await db.collection('Users').doc(uid).set({}); // nowPet 없음

    const res = await call({ earned: 20, dateKey }, uid);
    expect(res.skipped).toBe(true);
    expect(res.reason).toBe('nowPetMissing');
  });

  it('❌ 잘못된 인자 → invalid-argument', async () => {
    const uid = 'u_bad_1';
    const dateKey = '2025-10-20';
    await expect(call({ earned: NaN, dateKey }, uid)).rejects.toMatchObject({ code: 'invalid-argument' });
    await expect(call({ earned: 10, dateKey })).rejects.toMatchObject({ code: 'invalid-argument' });
    await expect(call({ uid, earned: 10, dateKey: '' }, undefined)).rejects.toMatchObject({ code: 'invalid-argument' });
  });
});
