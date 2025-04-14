const express = require('express');
const router = express.Router();
const {
  registerUser,
  checkUserExists
} = require('../controllers/authController');

router.post('/register', registerUser);
router.post('/check-user', checkUserExists);

module.exports = router;
