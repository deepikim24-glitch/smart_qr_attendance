const express = require('express');
const adminController = require('../controllers/adminController');
const { authenticate, requireRole } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate, requireRole('admin'));
router.get('/dashboard', adminController.dateValidators, adminController.dashboard);
router.get('/employees', adminController.employees);
router.get('/attendance', adminController.dateValidators, adminController.attendance);

module.exports = router;
