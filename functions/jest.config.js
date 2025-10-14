export default {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/test/**/*.test.ts', '**/src/**/*.test.ts'],
  transform: { '^.+\\.ts$': ['ts-jest', { useESM: false }] },
  moduleFileExtensions: ['ts', 'js'],
  verbose: true,
  moduleNameMapper: {
    // src/submitReward.ts 가 "./firebase" 또는 "./firebase.js"를 import해도 mock으로 보냄
    '^\\.\\/firebase(?:\\.js)?$': '<rootDir>/src/__mocks__/firebase.js',
    // 테스트에서 '../src/firebase' import 도 같은 mock으로 보냄
    '^\\.\\.\\/src\\/firebase$': '<rootDir>/src/__mocks__/firebase.js',
  },
};