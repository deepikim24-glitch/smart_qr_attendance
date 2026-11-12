const express = require('express');
const authController = require('../controllers/authController');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.post('/login', authController.loginValidators, authController.login);
router.post('/register', authController.registerValidators, authController.register);
router.get('/profile', authenticate, authController.profile);

module.exports = router;
