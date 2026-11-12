class AppError extends Error {
  constructor(statusCode, code, message, details) {
    super(message);
    this.name = 'AppError';
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
  }
}

function badRequest(message, details) {
  return new AppError(400, 'BAD_REQUEST', message, details);
}

function unauthorized(message = 'Authentication required') {
  return new AppError(401, 'UNAUTHORIZED', message);
}

function forbidden(message = 'You do not have permission to perform this action') {
  return new AppError(403, 'FORBIDDEN', message);
}

function notFound(message = 'Resource not found') {
  return new AppError(404, 'NOT_FOUND', message);
}

function conflict(message) {
  return new AppError(409, 'CONFLICT', message);
}

function gone(message) {
  return new AppError(410, 'EXPIRED', message);
}

module.exports = {
  AppError,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  gone,
};
