# Submission package

Smart QR-Based Attendance Management System — source, setup, architecture, and demo-video script.

## 1. Complete source code

The Git repository root **is** the complete source. Do not nest a second Flutter app under `flutter_app/` (see `flutter_app/README.md`).

| Path | Contents |
| --- | --- |
| `lib/` | Flutter Clean Architecture + BLoC (UI, domain, data) |
| `test/` | Flutter BLoC tests |
| `backend/` | Express API, JWT, QR and attendance rules |
| `backend/tests/` | Jest + Supertest API tests |
| `database/schema.sql` | PostgreSQL schema |
| `docker-compose.yml` | Local PostgreSQL 16 |
| `docs/` | Architecture, API, Postman collection |
| `pubspec.yaml` | Flutter dependencies |

**Zip for evaluators** (from the project folder, after builds):

```powershell
cd C:\Users\deepika\StudioProjects\smart_qr_attendance
Compress-Archive -Path lib,backend,database,docs,android,ios,web,windows,test,docker-compose.yml,pubspec.yaml,pubspec.lock,analysis_options.yaml,README.md,SUBMISSION.md,flutter_app -DestinationPath smart_qr_attendance_source.zip
```

Exclude `backend/node_modules`, `build/`, `.dart_tool/`, and `.env` if you replaced demo secrets. Keep `backend/.env.example`.

## 2. Setup instructions

### Prerequisites

- Flutter 3.35+ / Dart 3.9+
- Node.js 18+
- Docker Desktop
- Chrome (admin QR display) and/or an Android phone on the **same Wi-Fi** as the PC

### First-time install

```powershell
cd C:\Users\deepika\StudioProjects\smart_qr_attendance
docker compose up -d

cd backend
copy .env.example .env
npm install
npm run migrate
npm run seed

cd ..
flutter pub get
```

### Start the API (every session)

```powershell
cd C:\Users\deepika\StudioProjects\smart_qr_attendance
docker compose up -d
cd backend
npm start
```

Wait for: `Smart QR Attendance API listening on 0.0.0.0:3000`  
Health: `http://127.0.0.1:3000/health`

### Point the app at this PC

Edit `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://YOUR_PC_LAN_IP:3000';
```

Do **not** append `/api` and do **not** use port `5000`. Dio already calls `/api/...`. Find the LAN IP with `ipconfig` (IPv4). Current lab IP example: `http://192.168.31.178:3000`.

Allow **TCP 3000** inbound in Windows Firewall when testing a physical phone.

### Run Flutter

Chrome (admin QR on a large screen):

```powershell
cd C:\Users\deepika\StudioProjects\smart_qr_attendance
flutter run -d chrome
```

Phone (employee scanner):

```powershell
flutter run
```

Choose the USB device. Hot reload is not enough after changing `baseUrl` — use a full restart.

### Seed logins (local only)

| Role | Email | Password |
| --- | --- | --- |
| Admin | admin@company.com | Admin@12345 |
| Employee | employee@company.com | Employee@12345 |

### Tests

```powershell
cd backend
npm test
cd ..
flutter test
```

Postman: `docs/Smart_QR_Attendance.postman_collection.json`

## 3. Architecture overview

Full write-up: [docs/architecture.md](docs/architecture.md). API: [docs/api_documentation.md](docs/api_documentation.md).

```
Admin / Employee UI (Flutter)
        ↓ BLoC
   Use case → Repository → Dio
        ↓ HTTP JSON + JWT
   Express (backend/)
        ↓ parameterized SQL
   PostgreSQL (attendance, hashed QR tokens, users)
```

- **Admin** generates a short-lived QR. The API returns `{ sessionId, token }` once; the database stores only `sha256(token)`.
- The admin screen auto-refreshes the QR when the countdown hits zero (same lifetime, new token).
- **Employee** scans, the phone adds GPS, and `POST /api/attendance/mark` runs in a DB transaction (`SELECT … FOR UPDATE`) so one check-in and one check-out per UTC day.
- The client never decides validity. Expiry, hash match, role, and duplicate-day rules live on the server.

## 4. Demonstration video (record this)

Record 3–5 minutes. Windows: `Win + G` (Xbox Game Bar) or phone screen record for the employee half.

| Time | Shot | What to show |
| --- | --- | --- |
| 0:00 | Title | Project name + “admin on Chrome, employee on phone” |
| 0:15 | Backend | Terminal: `npm start` and `listening on 0.0.0.0:3000` |
| 0:30 | Admin login | Chrome → `admin@company.com` / `Admin@12345` |
| 0:50 | Dashboard | Stats / employees tab |
| 1:10 | QR | Generate 2 min QR, countdown, Auto-refresh switch on |
| 1:40 | Employee login | Phone → `employee@company.com` / `Employee@12345` |
| 2:00 | Scan in | Scan QR → GPS → check-in success |
| 2:30 | Scan out | Scan the same (or refreshed) QR → check-out |
| 3:00 | History | Phone attendance history |
| 3:20 | Admin table | Chrome attendance list with in/out and GPS |
| 3:40 | Security | Mention hashed token, JWT, expiry on server |
| 4:00 | End | Health URL + stack (Flutter, Express, PostgreSQL) |

Save as `demo.mp4` (or YouTube/Drive unlisted) and submit **with** the source zip and this folder’s README / `docs/`.

Suggested filename: `Smart_QR_Attendance_Demo.mp4`.
