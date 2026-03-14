const express = require('express');
const router = express.Router();
const pedidosController = require('../controllers/pedidosController');

router.post('/',                    pedidosController.crearPedido);
router.patch('/:id/entregar',       pedidosController.marcarEntregado);
router.patch('/:id/corregir',       pedidosController.corregirFechaHora);

module.exports = router;