const { withTransaction, query } = require('../config/db');
const { env } = require('../config/env');
const { tokensMatch } = require('../utils/crypto');
const { isValidCoordinate, haversineMeters } = require('../utils/geo');
const { badRequest, notFound, conflict, gone, forbidden } = require('../utils/appError');

function mapAttendance(row) {
  return {
    id: row.id,
    employeeId: row.employee_id,
    employeeName: row.employee_name || undefined,
    employeeEmail: row.employee_email || undefined,
    sessionId: row.session_id,
    attendanceDate: row.attendance_date,
    checkIn: row.check_in,
    checkOut: row.check_out,
    checkInLatitude: row.check_in_latitude,
    checkInLongitude: row.check_in_longitude,
    checkOutLatitude: row.check_out_latitude,
    checkOutLongitude: row.check_out_longitude,
    status: row.status,
    createdAt: row.created_at,
  };
}

function assertGeofence(latitude, longitude) {
  if (!env.geofenceEnabled || env.geofenceRadiusMeters <= 0) {
    return;
  }
  const distance = haversineMeters(
    latitude,
    longitude,
    env.officeLatitude,
    env.officeLongitude
  );
  if (distance > env.geofenceRadiusMeters) {
    throw forbidden(
      `Location is outside the allowed radius (${Math.round(distance)}m away; max ${env.geofenceRadiusMeters}m)`
    );
  }
}

async function markAttendance({ employeeId, sessionId, qrToken, latitude, longitude }) {
  if (!isValidCoordinate(latitude, longitude)) {
    throw badRequest('Valid latitude and longitude are required');
  }
  assertGeofence(latitude, longitude);

  return withTransaction(async (client) => {
    const sessionResult = await client.query(
      `SELECT id, token_hash, expires_at, is_active
       FROM attendance_sessions
       WHERE id = $1
       FOR UPDATE`,
      [sessionId]
    );
    const session = sessionResult.rows[0];
    if (!session) {
      throw notFound('Attendance QR session was not found');
    }
    if (!session.is_active) {
      throw gone('This attendance QR session has been deactivated');
    }
    if (new Date(session.expires_at).getTime() <= Date.now()) {
      throw gone('This attendance QR code has expired');
    }
    if (!tokensMatch(qrToken, session.token_hash)) {
      throw badRequest('Invalid QR token');
    }

    const existing = await client.query(
      `SELECT *
       FROM attendance
       WHERE employee_id = $1
         AND attendance_date = (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::date
       FOR UPDATE`,
      [employeeId]
    );

    const nowResult = await client.query(`SELECT NOW() AS now, (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::date AS today`);
    const now = nowResult.rows[0].now;
    const today = nowResult.rows[0].today;

    if (existing.rowCount === 0) {
      const inserted = await client.query(
        `INSERT INTO attendance (
           employee_id, session_id, attendance_date,
           check_in, check_in_latitude, check_in_longitude, status
         ) VALUES ($1, $2, $3, $4, $5, $6, 'checked_in')
         RETURNING *`,
        [employeeId, sessionId, today, now, latitude, longitude]
      );
      const attendance = inserted.rows[0];
      await client.query(
        `INSERT INTO attendance_events (attendance_id, event_type, latitude, longitude, timestamp)
         VALUES ($1, 'check_in', $2, $3, $4)`,
        [attendance.id, latitude, longitude, now]
      );
      return { action: 'check_in', attendance: mapAttendance(attendance) };
    }

    const current = existing.rows[0];
    if (current.check_out) {
      throw conflict('Attendance already completed for today');
    }

    const updated = await client.query(
      `UPDATE attendance
       SET check_out = $1,
           check_out_latitude = $2,
           check_out_longitude = $3,
           status = 'checked_out',
           session_id = COALESCE(session_id, $4)
       WHERE id = $5
       RETURNING *`,
      [now, latitude, longitude, sessionId, current.id]
    );
    const attendance = updated.rows[0];
    await client.query(
      `INSERT INTO attendance_events (attendance_id, event_type, latitude, longitude, timestamp)
       VALUES ($1, 'check_out', $2, $3, $4)`,
      [attendance.id, latitude, longitude, now]
    );
    return { action: 'check_out', attendance: mapAttendance(attendance) };
  });
}

async function getHistory({ employeeId, date, page = 1, pageSize = 20 }) {
  const filters = ['a.employee_id = $1'];
  const params = [employeeId];
  if (date) {
    params.push(date);
    filters.push(`a.attendance_date = $${params.length}`);
  }
  const offset = (Math.max(page, 1) - 1) * pageSize;
  params.push(pageSize, offset);

  const result = await query(
    `SELECT a.*
     FROM attendance a
     WHERE ${filters.join(' AND ')}
     ORDER BY a.attendance_date DESC, a.created_at DESC
     LIMIT $${params.length - 1} OFFSET $${params.length}`,
    params
  );

  const countParams = date ? [employeeId, date] : [employeeId];
  const count = await query(
    `SELECT COUNT(*)::int AS total
     FROM attendance a
     WHERE ${filters.join(' AND ')}`,
    countParams
  );

  return {
    items: result.rows.map(mapAttendance),
    pagination: {
      page: Math.max(page, 1),
      pageSize,
      total: count.rows[0].total,
    },
  };
}

async function getDashboard(date) {
  const targetDate = date || null;
  const dateExpr = targetDate ? '$1::date' : `(CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::date`;
  const params = targetDate ? [targetDate] : [];

  const totals = await query(`SELECT COUNT(*)::int AS total FROM users WHERE role = 'employee'`);
  const present = await query(
    `SELECT COUNT(*)::int AS total
     FROM attendance
     WHERE attendance_date = ${dateExpr}
       AND check_in IS NOT NULL`,
    params
  );
  const checkedIn = await query(
    `SELECT COUNT(*)::int AS total
     FROM attendance
     WHERE attendance_date = ${dateExpr}
       AND check_in IS NOT NULL
       AND check_out IS NULL`,
    params
  );

  const totalEmployees = totals.rows[0].total;
  const presentEmployees = present.rows[0].total;
  return {
    date: targetDate,
    totalEmployees,
    presentEmployees,
    absentEmployees: Math.max(totalEmployees - presentEmployees, 0),
    currentlyCheckedIn: checkedIn.rows[0].total,
  };
}

async function listEmployees() {
  const result = await query(
    `SELECT id, name, email, role, created_at
     FROM users
     WHERE role = 'employee'
     ORDER BY name ASC`
  );
  return result.rows.map((row) => ({
    id: row.id,
    name: row.name,
    email: row.email,
    role: row.role,
    createdAt: row.created_at,
  }));
}

async function listAttendance({ date, page = 1, pageSize = 50 }) {
  const filters = [];
  const params = [];
  if (date) {
    params.push(date);
    filters.push(`a.attendance_date = $${params.length}`);
  }
  const where = filters.length ? `WHERE ${filters.join(' AND ')}` : '';
  const offset = (Math.max(page, 1) - 1) * pageSize;
  params.push(pageSize, offset);

  const result = await query(
    `SELECT a.*, u.name AS employee_name, u.email AS employee_email
     FROM attendance a
     INNER JOIN users u ON u.id = a.employee_id
     ${where}
     ORDER BY a.attendance_date DESC, u.name ASC
     LIMIT $${params.length - 1} OFFSET $${params.length}`,
    params
  );

  const countParams = date ? [date] : [];
  const countWhere = date ? 'WHERE a.attendance_date = $1' : '';
  const count = await query(
    `SELECT COUNT(*)::int AS total FROM attendance a ${countWhere}`,
    countParams
  );

  return {
    items: result.rows.map(mapAttendance),
    pagination: {
      page: Math.max(page, 1),
      pageSize,
      total: count.rows[0].total,
    },
  };
}

module.exports = {
  markAttendance,
  getHistory,
  getDashboard,
  listEmployees,
  listAttendance,
};
