-- Smart QR Attendance — PostgreSQL schema
-- Apply with: npm run migrate (from backend/) or psql -f database/schema.sql

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('admin', 'employee');
  END IF;
END$$;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  email VARCHAR(255) NOT NULL,
  password_hash TEXT NOT NULL,
  role user_role NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT users_email_unique UNIQUE (email),
  CONSTRAINT users_email_format CHECK (position('@' IN email) > 1)
);

CREATE TABLE IF NOT EXISTS attendance_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  token_hash TEXT NOT NULL,
  created_by UUID NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
  expires_at TIMESTAMPTZ NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT sessions_expiry_after_create CHECK (expires_at > created_at)
);

CREATE TABLE IF NOT EXISTS attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
  session_id UUID NOT NULL REFERENCES attendance_sessions (id) ON DELETE RESTRICT,
  attendance_date DATE NOT NULL,
  check_in TIMESTAMPTZ,
  check_out TIMESTAMPTZ,
  check_in_latitude DOUBLE PRECISION,
  check_in_longitude DOUBLE PRECISION,
  check_out_latitude DOUBLE PRECISION,
  check_out_longitude DOUBLE PRECISION,
  status VARCHAR(32) NOT NULL DEFAULT 'checked_in',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT attendance_employee_date_unique UNIQUE (employee_id, attendance_date),
  CONSTRAINT attendance_status_check CHECK (
    status IN ('checked_in', 'checked_out', 'present')
  ),
  CONSTRAINT attendance_checkout_after_checkin CHECK (
    check_out IS NULL OR check_in IS NULL OR check_out >= check_in
  )
);

CREATE TABLE IF NOT EXISTS attendance_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attendance_id UUID NOT NULL REFERENCES attendance (id) ON DELETE CASCADE,
  event_type VARCHAR(32) NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT attendance_events_type_check CHECK (
    event_type IN ('check_in', 'check_out')
  )
);

CREATE INDEX IF NOT EXISTS idx_users_role ON users (role);
CREATE INDEX IF NOT EXISTS idx_sessions_active_expiry
  ON attendance_sessions (is_active, expires_at);
CREATE INDEX IF NOT EXISTS idx_sessions_created_by
  ON attendance_sessions (created_by);
CREATE INDEX IF NOT EXISTS idx_attendance_date_status
  ON attendance (attendance_date, status);
CREATE INDEX IF NOT EXISTS idx_attendance_employee
  ON attendance (employee_id, attendance_date DESC);
CREATE INDEX IF NOT EXISTS idx_attendance_events_attendance
  ON attendance_events (attendance_id, timestamp);
