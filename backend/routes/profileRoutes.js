const express = require('express');
const router = express.Router();
const { getUserProfile, updateUserProfile, updateProfileImage } = require('../controllers/profileController');

router.post('/update', updateUserProfile);
router.get('/:id', getUserProfile);
router.post("/update-image",updateProfileImage);

module.exports = router;
