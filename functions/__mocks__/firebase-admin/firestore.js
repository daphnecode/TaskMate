// Jest가 'firebase-admin/firestore' 모듈 import를 이 파일로 치환
// increment 토큰(식별 가능한 형태)
class _Inc {
  constructor(n) {
    this.__inc = Number(n) || 0; // 식별 키: __inc
  }
}

// FieldValue mock
const FieldValue = {
  increment: (n) => new _Inc(n),
  serverTimestamp: () => new Date(),
};

// (선택) Timestamp 간단 mock — 필요 없으면 제거
class Timestamp {
  static now() {
    return new Date();
  }
  static fromDate(d) {
    return d instanceof Date ? d : new Date(d);
  }
  toDate() {
    return this;
  }
}

module.exports = { __esModule: true, FieldValue, Timestamp };
