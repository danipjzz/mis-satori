const db = require("../config/db");

exports.actualizarCorreo = async (req, res) => {
  try {

    await db.query(`
      UPDATE clientes
      SET correo = LOWER(REPLACE(nombre, ' ', '')) || '@gmail.com'
      WHERE correo IS NULL OR correo = '';
    `);

    res.json({ mensaje: "Correos actualizados correctamente" });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error actualizando correos" });
  }
};