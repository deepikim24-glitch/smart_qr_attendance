const { app } = require('./app');
const { env } = require('./config/env');
const { ping } = require('./config/db');

async function start() {
  await ping();
  app.listen(env.port, '0.0.0.0', () => {
    console.log(`Smart QR Attendance API listening on 0.0.0.0:${env.port}`);
  });
}

start().catch((error) => {
  console.error('Failed to start server', error);
  process.exit(1);
});
