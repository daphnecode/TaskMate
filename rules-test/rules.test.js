// rules.test.js
import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import fs from 'node:fs';
import test, { before, after, beforeEach } from 'node:test';

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-proto',
    firestore: {
      // 로컬 규칙 파일을 그대로 로드
      rules: fs.readFileSync('../firestore.rules', 'utf8'),
    },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore(); // 각 테스트 격리
});

after(async () => {
  await testEnv.cleanup();
});

// 편의 함수: 룰 무시하고 초기 데이터 세팅
async function seed(path, data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), path), data);
  });
}

test('비인증 사용자는 Users/abc123 읽기 거부', async () => {
  const unauth = testEnv.unauthenticatedContext();
  const db = unauth.firestore();
  await seed('Users/abc123', { ok: true });
  await assertFails(getDoc(doc(db, 'Users/abc123')));
});

test('본인은 Users/abc123 읽기 허용', async () => {
  const alice = testEnv.authenticatedContext('abc123');
  const db = alice.firestore();
  await seed('Users/abc123', { ok: true });
  await assertSucceeds(getDoc(doc(db, 'Users/abc123')));
});

test('다른 사람 Users/xyz789 읽기 거부', async () => {
  const alice = testEnv.authenticatedContext('abc123');
  const db = alice.firestore();
  await seed('Users/xyz789', { ok: true });
  await assertFails(getDoc(doc(db, 'Users/xyz789')));
});

test('본인은 하위컬렉션 쓰기 허용 (Users/abc123/pets/p1)', async () => {
  const alice = testEnv.authenticatedContext('abc123');
  const db = alice.firestore();
  await assertSucceeds(setDoc(doc(db, 'Users/abc123/pets/p1'), { name: 'doge' }));
});

test('타인 하위컬렉션 쓰기 거부 (Users/xyz789/pets/p1)', async () => {
  const alice = testEnv.authenticatedContext('abc123');
  const db = alice.firestore();
  await assertFails(setDoc(doc(db, 'Users/xyz789/pets/p1'), { name: 'cat' }));
});

test('Items는 누구나 읽기 허용', async () => {
  const unauth = testEnv.unauthenticatedContext();
  const db = unauth.firestore();
  await seed('aLLitems/item123', { type: 'potion' });
  await assertSucceeds(getDoc(doc(db, 'aLLitems/item123')));
});

test('Items 쓰기는 거부', async () => {
  const alice = testEnv.authenticatedContext('abc123');
  const db = alice.firestore();
  await assertFails(setDoc(doc(db, 'Items/itemX'), { bad: true }));
});
