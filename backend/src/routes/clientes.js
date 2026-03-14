const express = require("express");
const router = express.Router();

const clientesController = require("../controllers/clientesController");

router.patch("/correo", clientesController.actualizarCorreo);

module.exports = router;