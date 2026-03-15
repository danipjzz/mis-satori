const express = require('express');
const router = express.Router();
const ventasController = require('../controllers/ventasController');

router.post('/', ventasController.crearVenta);
router.get('/',  ventasController.getVentas);

module.exports = router;