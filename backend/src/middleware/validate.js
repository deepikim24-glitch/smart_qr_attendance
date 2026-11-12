const { validationResult } = require('express-validator');
const { badRequest } = require('../utils/appError');

function validate(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return next(
      badRequest('Validation failed', errors.array().map((item) => ({
        field: item.path,
        message: item.msg,
      })))
    );
  }
  next();
}

module.exports = { validate };
