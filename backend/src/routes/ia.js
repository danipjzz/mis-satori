const express = require('express');
const router = express.Router();
const iaController = require('../controllers/iaController');

router.post('/mensaje', iaController.generarMensaje);
router.post('/analisis', iaController.generarAnalisis);

module.exports = router;