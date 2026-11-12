const { body, query } = require('express-validator');
const attendanceService = require('../services/attendanceService');
const { asyncHandler } = require('../utils/asyncHandler');
const { validate } = require('../middleware/validate');

const markValidators = [
  body('sessionId').isUUID().withMessage('sessionId must be a valid UUID'),
  body('qrToken').isString().isLength({ min: 16 }).withMessage('qrToken is required'),
  body('latitude').isFloat({ min: -90, max: 90 }).withMessage('Valid latitude is required'),
  body('longitude').isFloat({ min: -180, max: 180 }).withMessage('Valid longitude is required'),
  validate,
];

const historyValidators = [
  query('date').optional().isISO8601().withMessage('date must be YYYY-MM-DD'),
  query('page').optional().isInt({ min: 1 }),
  query('pageSize').optional().isInt({ min: 1, max: 100 }),
  validate,
];

const mark = asyncHandler(async (req, res) => {
  const result = await attendanceService.markAttendance({
    employeeId: req.user.id,
    sessionId: req.body.sessionId,
    qrToken: req.body.qrToken,
    latitude: Number(req.body.latitude),
    longitude: Number(req.body.longitude),
  });
  res.status(201).json({ success: true, data: result });
});

const history = asyncHandler(async (req, res) => {
  const result = await attendanceService.getHistory({
    employeeId: req.user.id,
    date: req.query.date,
    page: Number(req.query.page || 1),
    pageSize: Number(req.query.pageSize || 20),
  });
  res.json({ success: true, data: result });
});

module.exports = { mark, history, markValidators, historyValidators };
