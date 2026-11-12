# Database

Apply `schema.sql` with:

```bash
cd backend
npm run migrate
npm run seed
```

Or start PostgreSQL via `docker compose up -d` from the repository root (schema is also mounted for first-time container init).
