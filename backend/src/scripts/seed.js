const bcrypt = require('bcryptjs');
const { pool } = require('../config/db');
const { env } = require('../config/env');

async function upsertUser({ name, email, password, role }) {
  const passwordHash = await bcrypt.hash(password, env.bcryptRounds);
  await pool.query(
    `INSERT INTO users (name, email, password_hash, role)
     VALUES ($1, $2, $3, $4)
     ON CONFLICT (email)
     DO UPDATE SET name = EXCLUDED.name, password_hash = EXCLUDED.password_hash, role = EXCLUDED.role`,
    [name, email.toLowerCase(), passwordHash, role]
  );
}

async function seed() {
  await upsertUser({
    name: env.seed.adminName,
    email: env.seed.adminEmail,
    password: env.seed.adminPassword,
    role: 'admin',
  });
  await upsertUser({
    name: env.seed.employeeName,
    email: env.seed.employeeEmail,
    password: env.seed.employeePassword,
    role: 'employee',
  });
  console.log('Seed complete.');
  console.log(`Admin:    ${env.seed.adminEmail}`);
  console.log(`Employee: ${env.seed.employeeEmail}`);
  await pool.end();
}

seed().catch(async (error) => {
  console.error(error);
  await pool.end();
  process.exit(1);
});
