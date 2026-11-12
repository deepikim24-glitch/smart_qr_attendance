const express = require('express');
const qrController = require('../controllers/qrController');
const { authenticate, requireRole } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate, requireRole('admin'));
router.post('/generate', qrController.generateValidators, qrController.generate);
router.post('/:id/deactivate', qrController.deactivateValidators, qrController.deactivate);
router.get('/active', qrController.active);

module.exports = router;
