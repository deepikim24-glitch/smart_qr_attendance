const express = require('express');
const attendanceController = require('../controllers/attendanceController');
const { authenticate, requireRole } = require('../middleware/auth');

const router = express.Router();

router.post(
  '/mark',
  authenticate,
  requireRole('employee'),
  attendanceController.markValidators,
  attendanceController.mark
);
router.get(
  '/history',
  authenticate,
  requireRole('employee'),
  attendanceController.historyValidators,
  attendanceController.history
);

module.exports = router;
