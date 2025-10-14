// functions/src/__mocks__/firebase.js
const store = new Map();
class Increment { constructor(n) { this._n = Number(n) || 0; } }
const FieldValue = {
  increment: (n) => new Increment(n),
  serverTimestamp: () => new Date(),
};
function applyIncrement(prev, data) {
  const out = { ...(prev || {}) };
  for (const [k, v] of Object.entries(data)) {
    if (v instanceof Increment || (v && typeof v === 'object' && '__inc' in v)) {
      const add = v instanceof Increment ? v._n : Number(v.__inc || 0);
      out[k] = (out[k] || 0) + add;
    }
    else out[k] = v;
  }
  return out;
}
function getDoc(path) {
  const data = store.get(path);
  return { exists: !!data, data: () => (data ? { ...data } : undefined) };
}
function setDoc(path, data, opts) {
  const prev = store.get(path);
  const merged = opts?.merge ? applyIncrement(prev, data) : applyIncrement({}, data);
  store.set(path, { ...(prev || {}), ...merged });
}
function docRef(path) {
  return {
    path,
    get: async () => getDoc(path),
    set: async (data, opts) => setDoc(path, data, opts),
    collection: (name) => collectionRef(`${path}/${name}`),
  };
}
function collectionRef(path) {
  return { doc: (id) => docRef(`${path}/${id}`) };
}
const db = {
  collection: (name) => collectionRef(name),
  runTransaction: async (fn) => {
    const tx = {
      async get(ref) { return getDoc(ref.path); },
      set(ref, data, opts) { setDoc(ref.path, data, opts); },
    };
    return await fn(tx);
  },
};
module.exports = { __esModule: true, db, FieldValue };
