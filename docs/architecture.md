# Architecture

## Overview

The system is split into three independently runnable parts:

- **Flutter client** at the repository root (`lib/`), using feature-first Clean Architecture and BLoC.
- **Express API** in `backend/`, which owns authentication, QR session secrets, and attendance rules.
- **PostgreSQL** schema in `database/schema.sql`.

The Android Studio / Flutter project already lived at the repository root, so the mobile app was implemented there instead of nested under `flutter_app/`. `flutter_app/README.md` records that mapping.

```
Flutter UI  ->  BLoC  ->  Use case  ->  Repository  ->  Dio  ->  Express  ->  PostgreSQL
```

The client never decides whether a scan is valid. It only collects a QR payload, GPS coordinates, and a JWT, then displays the server response.

## Data flow

1. Admin signs in. `AuthBloc` stores the JWT in `flutter_secure_storage`.
2. Admin generates a QR session. The API returns `{ sessionId, token }` once. PostgreSQL stores **only** `sha256(token)`.
3. The Flutter admin screen renders that payload with `qr_flutter` and counts down locally for UX. When auto-refresh is on, `AdminBloc` generates a new session as soon as remaining time hits zero. Expiry is still enforced with `NOW()` on the server.
4. An employee scans with `mobile_scanner`, parses JSON, requests GPS, and POSTs `/api/attendance/mark`.
5. The API opens a transaction, locks the session and the employee's day row (`SELECT … FOR UPDATE`), then inserts check-in or updates check-out.

## BLoC architecture

| BLoC | Responsibility |
| --- | --- |
| `AuthBloc` | Restore session, login, logout, expired JWT |
| `AttendanceBloc` | Employee history and date filters |
| `QRScannerBloc` | Camera permission, parse QR, GPS, single in-flight mark request |
| `AdminBloc` | Dashboard stats, employee list, attendance table, QR generate/deactivate, countdown ticks, QR auto-refresh |

Widgets do not call Dio. UI listens with `BlocBuilder` / `BlocListener` / `BlocConsumer`.

`setState` is used only for local view state (password visibility and admin tab index), not for application data.

## API communication

`ApiClient` wraps Dio with:

- JWT injection from secure storage
- Timeouts
- Mapping of offline, timeout, 400, 401, 403, 404, 409, 410, and 500 responses to `Failure`
- No automatic retry of `POST /api/attendance/mark`

Safe GETs expose a Retry action in the UI.

## Database design

- `users`: unique email, bcrypt hash, role enum
- `attendance_sessions`: token hash, expiry, active flag
- `attendance`: one row per employee per UTC workday (`UNIQUE (employee_id, attendance_date)`)
- `attendance_events`: append-only check-in / check-out trail

Attendance writes run in a transaction so two parallel scans cannot create two check-ins.

## Security decisions

- Passwords hashed with bcryptjs (bcrypt-compatible, no native toolchain required).
- QR secrets hashed with SHA-256; raw tokens are not stored.
- JWT required on private routes; `requireRole('admin')` blocks employees from admin APIs.
- Parameterized SQL only.
- Helmet, CORS, and rate limits on the API.
- Geofencing is optional and **cannot prove presence**. A device can spoof coordinates. The feature exists as a configurable radius comparison only.

## HTTPS-ready deployment

Set `CORS_ORIGIN` to the real web origins, terminate TLS at a reverse proxy (nginx, Caddy, or a cloud load balancer), and point Flutter `API_BASE_URL` at `https://api.example.com`. Do not ship the demo JWT secret or seed passwords.
