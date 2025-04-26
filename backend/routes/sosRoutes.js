const express = require('express');
const router = express.Router();
const { triggerSOS } = require('../controllers/sosController');
const {getSOSHistory, addSOSHistory} = require('../controllers/sosController');

// router.post('/trigger-sos', triggerSOS);
router.post('/', addSOSHistory);
router.get('/:userId', getSOSHistory);

module.exports = router;
