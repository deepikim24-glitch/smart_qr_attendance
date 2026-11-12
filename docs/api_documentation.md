# API documentation

Base URL (local): `http://localhost:3000`

All JSON responses use:

```json
{ "success": true, "data": {} }
```

or

```json
{ "success": false, "error": { "code": "UNAUTHORIZED", "message": "..." } }
```

Authenticated routes require `Authorization: Bearer <jwt>`.

## Auth

### POST `/api/auth/login`

Request:

```json
{ "email": "admin@company.com", "password": "Admin@12345" }
```

Response `200`:

```json
{
  "success": true,
  "data": {
    "token": "<jwt>",
    "user": { "id": "uuid", "name": "Admin User", "email": "admin@company.com", "role": "admin" }
  }
}
```

Errors: `400` validation, `401` invalid credentials.

### POST `/api/auth/register`

Creates an **employee** account only. Administrators cannot self-register.

### GET `/api/auth/profile`

Requires JWT. Returns the current user.

## QR (admin)

### POST `/api/qr/generate`

Request:

```json
{ "expirySeconds": 120 }
```

Response `201`:

```json
{
  "success": true,
  "data": {
    "session": { "id": "uuid", "expiresAt": "...", "isActive": true, "createdAt": "..." },
    "payload": { "sessionId": "uuid", "token": "base64url" }
  }
}
```

The raw token is returned once. The database stores only the hash.

### POST `/api/qr/:id/deactivate`

Deactivates a session immediately.

### GET `/api/qr/active`

Returns the latest non-expired active session metadata (no token).

## Attendance (employee)

### POST `/api/attendance/mark`

Request:

```json
{
  "sessionId": "uuid",
  "qrToken": "secure-token",
  "latitude": 11.6643,
  "longitude": 78.1460
}
```

Response `201`:

```json
{
  "success": true,
  "data": {
    "action": "check_in",
    "attendance": { "id": "uuid", "status": "checked_in", "checkIn": "..." }
  }
}
```

`action` is `check_in` or `check_out`.

Errors:

| Status | Meaning |
| --- | --- |
| 400 | Invalid body or invalid QR token |
| 401 | Missing/invalid/expired JWT |
| 403 | Not an employee, or outside geofence if enabled |
| 404 | Session not found |
| 409 | Already checked in and out today |
| 410 | Session expired or deactivated |

### GET `/api/attendance/history`

Query: `date=YYYY-MM-DD`, `page`, `pageSize`.

Returns only the authenticated employee's rows.

## Admin

All routes require role `admin`. Employees receive `403`.

### GET `/api/admin/dashboard`

Query: `date=YYYY-MM-DD` (UTC day). Returns totals, present, absent, currently checked-in.

### GET `/api/admin/employees`

### GET `/api/admin/attendance`

Query: `date`, `page`, `pageSize`. Includes employee name, email, times, status, and GPS.

## Health

`GET /health` → `{ "success": true, "data": { "status": "ok" } }`
