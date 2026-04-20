const db = require("../config/db");

exports.crearVenta = async (req, res) => {
  const { producto, cantidad, precio_unitario, nombre, telefono, correo, metodo_pago, fecha, orden_id } = req.body;


  const total = cantidad * precio_unitario;

  try {
    let cliente_id = null;

    if (telefono) {
      let cliente = await db.query(
        "SELECT id FROM clientes WHERE telefono = $1", [telefono]
      );

      if (cliente.rows.length === 0) {
        const nuevo = await db.query(
          `INSERT INTO clientes(nombre, telefono, correo)
           VALUES($1, $2, $3) RETURNING id`,
          [nombre || null, telefono, correo || null]
        );
        cliente_id = nuevo.rows[0].id;
      } else {
        cliente_id = cliente.rows[0].id;
      }
    }

    const result = await db.query(
      `INSERT INTO ventas(producto, cantidad, precio_unitario, total, cliente_id, metodo_pago, fecha, orden_id)
      VALUES($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING *`,
      [producto, cantidad, precio_unitario, total, cliente_id, metodo_pago || null, fecha || null,  orden_id || null]
    );

    res.json(result.rows[0]);

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error creando venta", detalle: error.message });
  }
};

exports.getVentas = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT
        ventas.id,
        ventas.producto,
        ventas.cantidad,
        ventas.precio_unitario,
        ventas.total,
        ventas.fecha,
        ventas.hora,
        ventas.metodo_pago,
        clientes.nombre,
        clientes.telefono
      FROM ventas
      LEFT JOIN clientes ON ventas.cliente_id = clientes.id
      ORDER BY ventas.fecha DESC, ventas.hora DESC
    `);
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error obteniendo ventas" });
  }
};