exports.actualizarCorreo = async (req, res) => {

  const { telefono, correo } = req.body;

  try {

    const result = await pool.query(
      `UPDATE clientes
       SET correo = $1
       WHERE telefono = $2
       RETURNING *`,
      [correo, telefono]
    );

    res.json(result.rows[0]);

  } catch (error) {

    console.error(error);
    res.status(500).json({ error: "Error actualizando correo" });

  }
};