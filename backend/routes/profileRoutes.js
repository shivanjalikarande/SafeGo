const express = require('express');
const router = express.Router();
const { getUserProfile, updateUserProfile } = require('../controllers/profileController');

router.post('/update', updateUserProfile);
router.get('/:id', getUserProfile);

module.exports = router;
