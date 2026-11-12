const { query } = require('../config/db');
const { env } = require('../config/env');
const { generateSecureToken, hashToken } = require('../utils/crypto');
const { notFound, badRequest } = require('../utils/appError');

async function generateSession({ createdBy, expirySeconds }) {
  const seconds = Number(expirySeconds || env.defaultQrExpirySeconds);
  if (!Number.isFinite(seconds) || seconds < 30 || seconds > 3600) {
    throw badRequest('Expiry must be between 30 and 3600 seconds');
  }

  const token = generateSecureToken();
  const tokenHash = hashToken(token);

  const inserted = await query(
    `INSERT INTO attendance_sessions (token_hash, created_by, expires_at, is_active)
     VALUES ($1, $2, NOW() + ($3::int * INTERVAL '1 second'), TRUE)
     RETURNING id, created_by, expires_at, is_active, created_at`,
    [tokenHash, createdBy, seconds]
  );

  const session = inserted.rows[0];
  return {
    session: {
      id: session.id,
      createdBy: session.created_by,
      expiresAt: session.expires_at,
      isActive: session.is_active,
      createdAt: session.created_at,
      expirySeconds: seconds,
    },
    payload: {
      sessionId: session.id,
      token,
    },
  };
}

async function deactivateSession(sessionId, adminId) {
  const result = await query(
    `UPDATE attendance_sessions
     SET is_active = FALSE
     WHERE id = $1
     RETURNING id, created_by, expires_at, is_active, created_at`,
    [sessionId]
  );
  if (result.rowCount === 0) {
    throw notFound('Attendance session not found');
  }
  const session = result.rows[0];
  return {
    id: session.id,
    createdBy: session.created_by || adminId,
    expiresAt: session.expires_at,
    isActive: session.is_active,
    createdAt: session.created_at,
  };
}

async function getActiveSession() {
  const result = await query(
    `SELECT id, created_by, expires_at, is_active, created_at
     FROM attendance_sessions
     WHERE is_active = TRUE AND expires_at > NOW()
     ORDER BY created_at DESC
     LIMIT 1`
  );
  const session = result.rows[0];
  if (!session) {
    return null;
  }
  return {
    id: session.id,
    createdBy: session.created_by,
    expiresAt: session.expires_at,
    isActive: session.is_active,
    createdAt: session.created_at,
  };
}

module.exports = { generateSession, deactivateSession, getActiveSession };
