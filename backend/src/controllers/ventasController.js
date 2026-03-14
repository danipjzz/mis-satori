const pool = require("../db");

exports.crearVenta = async (req, res) => {

  const { producto, cantidad, precio_unitario } = req.body;

  const total = cantidad * precio_unitario;

  const result = await pool.query(
    `INSERT INTO ventas (producto, cantidad, precio_unitario, total)
     VALUES ($1,$2,$3,$4)
     RETURNING *`,
    [producto, cantidad, precio_unitario, total]
  );

  res.json(result.rows[0]);
};