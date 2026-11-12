const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { query } = require('../config/db');
const { env } = require('../config/env');
const { badRequest, unauthorized, conflict } = require('../utils/appError');

function toPublicUser(row) {
  return {
    id: row.id,
    name: row.name,
    email: row.email,
    role: row.role,
    createdAt: row.created_at,
  };
}

function signToken(user) {
  return jwt.sign(
    {
      sub: user.id,
      role: user.role,
      name: user.name,
      email: user.email,
    },
    env.jwtSecret,
    { expiresIn: env.jwtExpiresIn }
  );
}

async function register({ name, email, password, role = 'employee' }) {
  if (role === 'admin') {
    throw badRequest('Administrator accounts cannot be self-registered');
  }

  const existing = await query('SELECT id FROM users WHERE lower(email) = lower($1)', [email]);
  if (existing.rowCount > 0) {
    throw conflict('An account with this email already exists');
  }

  const passwordHash = await bcrypt.hash(password, env.bcryptRounds);
  const inserted = await query(
    `INSERT INTO users (name, email, password_hash, role)
     VALUES ($1, $2, $3, $4)
     RETURNING id, name, email, role, created_at`,
    [name.trim(), email.toLowerCase(), passwordHash, 'employee']
  );
  const user = toPublicUser(inserted.rows[0]);
  return { user, token: signToken(user) };
}

async function login({ email, password }) {
  const result = await query(
    'SELECT id, name, email, role, password_hash, created_at FROM users WHERE lower(email) = lower($1)',
    [email]
  );
  const row = result.rows[0];
  if (!row) {
    throw unauthorized('Invalid email or password');
  }

  const matches = await bcrypt.compare(password, row.password_hash);
  if (!matches) {
    throw unauthorized('Invalid email or password');
  }

  const user = toPublicUser(row);
  return { user, token: signToken(user) };
}

async function getProfile(userId) {
  const result = await query(
    'SELECT id, name, email, role, created_at FROM users WHERE id = $1',
    [userId]
  );
  return toPublicUser(result.rows[0]);
}

module.exports = { register, login, getProfile, toPublicUser, signToken };
