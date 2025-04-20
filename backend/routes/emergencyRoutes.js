const express = require('express');
const router = express.Router();
const { getEmergencyNumbers } = require('../controllers/emergencyController');

router.get('/numbers', getEmergencyNumbers);

module.exports = router;
