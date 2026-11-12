const request = require('supertest');
const { app } = require('../src/app');
const { pool } = require('../src/config/db');
const { env } = require('../src/config/env');

jest.setTimeout(30000);

let adminToken;
let employeeToken;
let sessionId;
let qrToken;

describe('Smart QR Attendance API', () => {
  beforeAll(async () => {
    await pool.query('SELECT 1');
    await pool.query(
      `DELETE FROM attendance
       WHERE employee_id IN (SELECT id FROM users WHERE lower(email) = lower($1))`,
      [env.seed.employeeEmail]
    );
  });

  afterAll(async () => {
    await pool.end();
  });

  test('login fails with invalid credentials', async () => {
    const res = await request(app).post('/api/auth/login').send({
      email: env.seed.adminEmail,
      password: 'WrongPassword1',
    });
    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  test('admin login succeeds and returns JWT', async () => {
    const res = await request(app).post('/api/auth/login').send({
      email: env.seed.adminEmail,
      password: env.seed.adminPassword,
    });
    expect(res.status).toBe(200);
    expect(res.body.data.token).toBeTruthy();
    expect(res.body.data.user.role).toBe('admin');
    adminToken = res.body.data.token;
  });

  test('employee login succeeds', async () => {
    const res = await request(app).post('/api/auth/login').send({
      email: env.seed.employeeEmail,
      password: env.seed.employeePassword,
    });
    expect(res.status).toBe(200);
    expect(res.body.data.user.role).toBe('employee');
    employeeToken = res.body.data.token;
  });

  test('profile requires JWT', async () => {
    const res = await request(app).get('/api/auth/profile');
    expect(res.status).toBe(401);
  });

  test('employee cannot access admin dashboard', async () => {
    const res = await request(app)
      .get('/api/admin/dashboard')
      .set('Authorization', `Bearer ${employeeToken}`);
    expect(res.status).toBe(403);
  });

  test('admin can generate QR', async () => {
    const res = await request(app)
      .post('/api/qr/generate')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ expirySeconds: 120 });
    expect(res.status).toBe(201);
    sessionId = res.body.data.payload.sessionId;
    qrToken = res.body.data.payload.token;
    expect(sessionId).toBeTruthy();
    expect(qrToken).toBeTruthy();
    expect(res.body.data.session.tokenHash).toBeUndefined();
  });

  test('invalid QR token is rejected', async () => {
    const res = await request(app)
      .post('/api/attendance/mark')
      .set('Authorization', `Bearer ${employeeToken}`)
      .send({
        sessionId,
        qrToken: 'this-is-not-the-real-token-value',
        latitude: 11.6643,
        longitude: 78.146,
      });
    expect(res.status).toBe(400);
  });

  test('successful check-in', async () => {
    const res = await request(app)
      .post('/api/attendance/mark')
      .set('Authorization', `Bearer ${employeeToken}`)
      .send({
        sessionId,
        qrToken,
        latitude: 11.6643,
        longitude: 78.146,
      });
    expect(res.status).toBe(201);
    expect(res.body.data.action).toBe('check_in');
    expect(res.body.data.attendance.status).toBe('checked_in');
  });

  test('successful check-out', async () => {
    const res = await request(app)
      .post('/api/attendance/mark')
      .set('Authorization', `Bearer ${employeeToken}`)
      .send({
        sessionId,
        qrToken,
        latitude: 11.6644,
        longitude: 78.1461,
      });
    expect(res.status).toBe(201);
    expect(res.body.data.action).toBe('check_out');
    expect(res.body.data.attendance.status).toBe('checked_out');
  });

  test('duplicate attendance is rejected', async () => {
    const res = await request(app)
      .post('/api/attendance/mark')
      .set('Authorization', `Bearer ${employeeToken}`)
      .send({
        sessionId,
        qrToken,
        latitude: 11.6643,
        longitude: 78.146,
      });
    expect(res.status).toBe(409);
  });

  test('employee history returns own records', async () => {
    const res = await request(app)
      .get('/api/attendance/history')
      .set('Authorization', `Bearer ${employeeToken}`);
    expect(res.status).toBe(200);
    expect(res.body.data.items.length).toBeGreaterThan(0);
  });

  test('admin dashboard and attendance list', async () => {
    const dash = await request(app)
      .get('/api/admin/dashboard')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(dash.status).toBe(200);
    expect(dash.body.data.stats.totalEmployees).toBeGreaterThanOrEqual(1);

    const list = await request(app)
      .get('/api/admin/attendance')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(list.status).toBe(200);
    expect(list.body.data.items.length).toBeGreaterThan(0);
  });

  test('expired QR is rejected', async () => {
    const generated = await request(app)
      .post('/api/qr/generate')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ expirySeconds: 30 });
    const expiredSession = generated.body.data.payload.sessionId;
    const expiredToken = generated.body.data.payload.token;

    await pool.query(
      `UPDATE attendance_sessions SET expires_at = NOW() - INTERVAL '1 second' WHERE id = $1`,
      [expiredSession]
    );

    const res = await request(app)
      .post('/api/attendance/mark')
      .set('Authorization', `Bearer ${employeeToken}`)
      .send({
        sessionId: expiredSession,
        qrToken: expiredToken,
        latitude: 11.6643,
        longitude: 78.146,
      });
    expect(res.status).toBe(410);
  });
});
