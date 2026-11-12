const { body, param } = require('express-validator');
const qrService = require('../services/qrService');
const { asyncHandler } = require('../utils/asyncHandler');
const { validate } = require('../middleware/validate');

const generateValidators = [
  body('expirySeconds')
    .optional()
    .isInt({ min: 30, max: 3600 })
    .withMessage('expirySeconds must be between 30 and 3600'),
  validate,
];

const deactivateValidators = [
  param('id').isUUID().withMessage('A valid session id is required'),
  validate,
];

const generate = asyncHandler(async (req, res) => {
  const result = await qrService.generateSession({
    createdBy: req.user.id,
    expirySeconds: req.body.expirySeconds,
  });
  res.status(201).json({ success: true, data: result });
});

const deactivate = asyncHandler(async (req, res) => {
  const session = await qrService.deactivateSession(req.params.id, req.user.id);
  res.json({ success: true, data: { session } });
});

const active = asyncHandler(async (req, res) => {
  const session = await qrService.getActiveSession();
  res.json({ success: true, data: { session } });
});

module.exports = {
  generate,
  deactivate,
  active,
  generateValidators,
  deactivateValidators,
};
