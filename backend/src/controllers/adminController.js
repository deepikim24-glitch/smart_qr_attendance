const { query } = require('express-validator');
const attendanceService = require('../services/attendanceService');
const { asyncHandler } = require('../utils/asyncHandler');
const { validate } = require('../middleware/validate');

const dateValidators = [
  query('date').optional().isISO8601().withMessage('date must be YYYY-MM-DD'),
  query('page').optional().isInt({ min: 1 }),
  query('pageSize').optional().isInt({ min: 1, max: 100 }),
  validate,
];

const dashboard = asyncHandler(async (req, res) => {
  const stats = await attendanceService.getDashboard(req.query.date);
  res.json({ success: true, data: { stats } });
});

const employees = asyncHandler(async (req, res) => {
  const items = await attendanceService.listEmployees();
  res.json({ success: true, data: { items } });
});

const attendance = asyncHandler(async (req, res) => {
  const result = await attendanceService.listAttendance({
    date: req.query.date,
    page: Number(req.query.page || 1),
    pageSize: Number(req.query.pageSize || 50),
  });
  res.json({ success: true, data: result });
});

module.exports = { dashboard, employees, attendance, dateValidators };
