const jwt = require('jsonwebtoken');
const { env } = require('../config/env');
const { query } = require('../config/db');
const { unauthorized, forbidden } = require('../utils/appError');
const { asyncHandler } = require('../utils/asyncHandler');

const authenticate = asyncHandler(async (req, res, next) => {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');
  if (scheme !== 'Bearer' || !token) {
    throw unauthorized('Missing or invalid Authorization header');
  }

  let payload;
  try {
    payload = jwt.verify(token, env.jwtSecret);
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      throw unauthorized('Authentication token has expired');
    }
    throw unauthorized('Invalid authentication token');
  }

  const result = await query(
    'SELECT id, name, email, role, created_at FROM users WHERE id = $1',
    [payload.sub]
  );
  const user = result.rows[0];
  if (!user) {
    throw unauthorized('User no longer exists');
  }

  req.user = user;
  next();
});

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(forbidden('Employees cannot access administrator endpoints'));
    }
    next();
  };
}

module.exports = { authenticate, requireRole };
