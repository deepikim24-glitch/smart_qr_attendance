const { Pool } = require('pg');
const { env } = require('./env');

const pool = new Pool({
  connectionString: env.databaseUrl,
  max: 10,
  idleTimeoutMillis: 30000,
});

async function query(text, params = []) {
  return pool.query(text, params);
}

async function withTransaction(work) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await work(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    try {
      await client.query('ROLLBACK');
    } catch (_) {
      // ignore rollback errors
    }
    throw error;
  } finally {
    client.release();
  }
}

async function ping() {
  await pool.query('SELECT 1');
}

module.exports = { pool, query, withTransaction, ping };
