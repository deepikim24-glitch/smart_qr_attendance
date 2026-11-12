const { body } = require('express-validator');
const authService = require('../services/authService');
const { asyncHandler } = require('../utils/asyncHandler');
const { validate } = require('../middleware/validate');

const loginValidators = [
  body('email').isEmail().withMessage('A valid email is required').normalizeEmail(),
  body('password').isString().isLength({ min: 8 }).withMessage('Password is required'),
  validate,
];

const registerValidators = [
  body('name').isString().trim().isLength({ min: 2, max: 120 }).withMessage('Name is required'),
  body('email').isEmail().withMessage('A valid email is required').normalizeEmail(),
  body('password')
    .isString()
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters'),
  validate,
];

const login = asyncHandler(async (req, res) => {
  const result = await authService.login(req.body);
  res.json({ success: true, data: result });
});

const register = asyncHandler(async (req, res) => {
  const result = await authService.register(req.body);
  res.status(201).json({ success: true, data: result });
});

const profile = asyncHandler(async (req, res) => {
  const user = await authService.getProfile(req.user.id);
  res.json({ success: true, data: { user } });
});

module.exports = { login, register, profile, loginValidators, registerValidators };
