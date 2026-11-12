const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

function required(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

const isTest = process.env.NODE_ENV === 'test';

const env = {
  nodeEnv: process.env.NODE_ENV || 'development',
  isTest,
  port: Number(process.env.PORT || 3000),
  databaseUrl:
    process.env.DATABASE_URL ||
    (isTest
      ? 'postgres://attendance:attendance_dev_only@localhost:5432/smart_qr_attendance_test'
      : required('DATABASE_URL')),
  jwtSecret: process.env.JWT_SECRET || (isTest ? 'test_jwt_secret_not_for_production' : required('JWT_SECRET')),
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '8h',
  corsOrigin: process.env.CORS_ORIGIN || '*',
  bcryptRounds: Number(process.env.BCRYPT_ROUNDS || 12),
  defaultQrExpirySeconds: Number(process.env.DEFAULT_QR_EXPIRY_SECONDS || 120),
  geofenceEnabled: String(process.env.GEOFENCE_ENABLED || 'false') === 'true',
  geofenceRadiusMeters: Number(process.env.GEOFENCE_RADIUS_METERS || 0),
  officeLatitude: Number(process.env.OFFICE_LATITUDE || 0),
  officeLongitude: Number(process.env.OFFICE_LONGITUDE || 0),
  seed: {
    adminName: process.env.SEED_ADMIN_NAME || 'Admin User',
    adminEmail: process.env.SEED_ADMIN_EMAIL || 'admin@company.com',
    adminPassword: process.env.SEED_ADMIN_PASSWORD || 'Admin@12345',
    employeeName: process.env.SEED_EMPLOYEE_NAME || 'Jane Employee',
    employeeEmail: process.env.SEED_EMPLOYEE_EMAIL || 'employee@company.com',
    employeePassword: process.env.SEED_EMPLOYEE_PASSWORD || 'Employee@12345',
  },
};

module.exports = { env };
