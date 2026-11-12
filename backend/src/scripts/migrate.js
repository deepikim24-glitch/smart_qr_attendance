const fs = require('fs');
const path = require('path');
const { pool } = require('../config/db');

async function migrate() {
  const schemaPath = path.resolve(__dirname, '../../../database/schema.sql');
  const sql = fs.readFileSync(schemaPath, 'utf8');
  await pool.query(sql);
  console.log('Database schema applied from database/schema.sql');
  await pool.end();
}

migrate().catch(async (error) => {
  console.error(error);
  await pool.end();
  process.exit(1);
});
