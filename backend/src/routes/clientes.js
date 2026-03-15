const express = require("express");
const router = express.Router();

const clientesController = require("../controllers/clientesController");

router.patch("/correo", clientesController.actualizarCorreo);
router.get('/historial', clientesController.getClientesConHistorial);
router.get('/analisis', clientesController.getAnalisis);

module.exports = router;