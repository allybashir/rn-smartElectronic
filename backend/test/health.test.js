const { test } = require('node:test');
const assert = require('node:assert');
const app = require('../src/app');

test('GET /health returns ok', async () => {
  const server = app.listen(0);
  try {
    const { port } = server.address();
    const res = await fetch(`http://127.0.0.1:${port}/health`);
    assert.strictEqual(res.status, 200);
    assert.strictEqual((await res.json()).status, 'ok');
  } finally {
    server.close();
  }
});
