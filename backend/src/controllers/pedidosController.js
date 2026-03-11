const pool = require('../config/db');

exports.crearPedido = async (req, res) => {
  try {

    const {
      cliente_id,
      fecha_registro,
      fecha_entrega,
      hora_entrega,
      tipo_pedido,
      tipo_torta,
      peso_torta,
      sabor_ponque,
      relleno_base,
      relleno_especial,
      tipo_torta_especial
    } = req.body;

    const result = await pool.query(
      `INSERT INTO pedidos
      (cliente_id, fecha_registro, fecha_entrega, hora_entrega,
       tipo_pedido, tipo_torta, peso_torta, sabor_ponque,
       relleno_base, relleno_especial, tipo_torta_especial)
      VALUES
      ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
      RETURNING *`,
      [
        cliente_id,
        fecha_registro,
        fecha_entrega,
        hora_entrega,
        tipo_pedido,
        tipo_torta,
        peso_torta,
        sabor_ponque,
        relleno_base,
        relleno_especial,
        tipo_torta_especial
      ]
    );

    res.status(201).json(result.rows[0]);

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error creando pedido" });
  }
};