const express = require('express');
const router = express.Router();
const contactController = require('../controllers/contactController');


router.get('/:userId', contactController.getContactsByUser);
router.post('/add', contactController.addContact);
router.delete('/delete/:id', contactController.deleteContact);



module.exports = router;