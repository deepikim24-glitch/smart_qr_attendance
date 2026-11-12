# Smart QR-Based Attendance Management System

End-to-end employee attendance system: administrators generate short-lived QR sessions, employees scan them with GPS, and the Node.js API validates every rule in PostgreSQL.

The Flutter client lives at the repository root because this workspace was created as a Flutter project. Backend, schema, and docs sit beside it.

```
smart_qr_attendance/
├── lib/                 # Flutter Clean Architecture + BLoC
├── backend/             # Express + JWT + PostgreSQL
├── database/            # schema.sql
├── docs/                # architecture, API, Postman
├── flutter_app/         # pointer to the root Flutter app
├── docker-compose.yml
└── README.md
```

## Features

- Email/password login with JWT stored in secure storage
- Role-based admin and employee experiences
- Cryptographically random QR tokens (hash-only at rest)
- Configurable QR expiry (default 2 minutes) and session deactivation
- Transaction-safe check-in / check-out with one row per employee per UTC day
- Attendance history, admin dashboard, employee list, date filters
- Camera, GPS, offline, timeout, and HTTP error handling

## Technology stack

- Flutter, dart, flutter_bloc, equatable, Dio, mobile_scanner, qr_flutter, geolocator, flutter_secure_storage, permission_handler, intl
- Node.js, Express, PostgreSQL, JWT, bcryptjs, express-validator, Helmet, cors, express-rate-limit
- Jest + Supertest for API tests; bloc_test + mocktail for Flutter BLoCs

## Prerequisites

- Flutter 3.35+ / Dart 3.9+
- Node.js 18+
- Docker Desktop (recommended) **or** a local PostgreSQL 16 instance
- An Android emulator, iOS simulator, or Windows desktop target

## Installation

```bash
cd backend
copy .env.example .env     # Windows
# cp .env.example .env     # macOS/Linux
npm install

cd ..
flutter pub get
```

## Database configuration

Default local Docker credentials (development only):

- Database: `smart_qr_attendance`
- User: `attendance`
- Password: `attendance_dev_only`
- URL: `postgres://attendance:attendance_dev_only@localhost:5432/smart_qr_attendance`

Change these in `backend/.env` before any shared or production use. JWT secret and seed passwords also live in `.env` — never commit real secrets.

Optional geofence (off by default):

```
GEOFENCE_ENABLED=true
GEOFENCE_RADIUS_METERS=200
OFFICE_LATITUDE=11.6643
OFFICE_LONGITUDE=78.1460
```

Device GPS **cannot independently prove physical presence**. Geofencing only compares coordinates the phone reports.

## Backend setup

```bash
docker compose up -d
cd backend
npm run migrate
npm run seed
npm start
```

API: `http://localhost:3000`  
Health: `http://localhost:3000/health`

## Flutter setup

Android emulator (maps host loopback):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Windows / iOS simulator / web:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

Physical phone: use your computer's LAN IP, e.g. `http://192.168.1.20:3000`, and allow that origin if you tighten CORS.

Without `--dart-define`, the app uses `http://10.0.2.2:3000` on Android and `http://127.0.0.1:3000` elsewhere.

## Test credentials (seed / local only)

| Role | Email | Password |
| --- | --- | --- |
| Admin | admin@company.com | Admin@12345 |
| Employee | employee@company.com | Employee@12345 |

Override via `SEED_*` variables in `backend/.env` before `npm run seed`.

## API testing

```bash
cd backend
npm test
```

Or import `docs/Smart_QR_Attendance.postman_collection.json` into Postman.

Typical flow: Admin login → Generate QR → Employee login → Mark attendance (twice) → History / Admin dashboard.

## Screenshots

Capture the login screen, admin QR page with countdown, employee scanner, success screen, and admin attendance table for the demonstration video. Place images here if you add them later.

## Tests

```bash
cd backend && npm test
flutter test
```

## License

Private assessment project. Not for production deployment with the bundled demo secrets.
