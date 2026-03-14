const pool = require("../config/db");

function limpiarHora(valor) {
  if (!valor) return null;
  if (typeof valor === 'string' && /^\d{2}:\d{2}(:\d{2})?$/.test(valor)) {
    return valor;
  }
  const fecha = new Date(valor);
  if (isNaN(fecha.getTime())) return null;
  const h = fecha.getUTCHours().toString().padStart(2, '0');
  const m = fecha.getUTCMinutes().toString().padStart(2, '0');
  const s = fecha.getUTCSeconds().toString().padStart(2, '0');
  return `${h}:${m}:${s}`;
}

function limpiarFecha(valor) {
  if (!valor) return null;
  if (typeof valor === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(valor)) {
    return valor;
  }
  const fecha = new Date(valor);
  if (isNaN(fecha.getTime())) return null;
  return fecha.toISOString().substring(0, 10);
}


exports.crearPedido = async (req, res) => {
  const {
    nombre,
    telefono,
    correo,
    fecha_registro,
    fecha_entrega,
    hora_entrega,
    tipo_pedido,
    peso_torta,
    sabor_ponque,
    relleno_base,
    relleno_especial,
    tipo_torta_especial,
    tipo_torta
  } = req.body;

  try {
    const fechaRegistro = limpiarFecha(fecha_registro);
    const fechaEntrega  = limpiarFecha(fecha_entrega);
    const horaEntrega   = limpiarHora(hora_entrega);

    // 1. buscar cliente por teléfono
    let cliente = await pool.query(
      "SELECT id FROM clientes WHERE telefono = $1",
      [telefono]
    );

    let cliente_id;

    // 2. si no existe, crearlo
    if (cliente.rows.length === 0) {
      const nuevoCliente = await pool.query(
        `INSERT INTO clientes(nombre, telefono, correo)
         VALUES($1, $2, $3)
         RETURNING id`,
        [nombre, telefono, correo || null]
      );
      cliente_id = nuevoCliente.rows[0].id;
    } else {
      cliente_id = cliente.rows[0].id;

      // actualizar correo si llegó y no estaba guardado
      if (correo) {
        await pool.query(
          `UPDATE clientes SET correo = $1 WHERE id = $2 AND (correo IS NULL OR correo = '')`,
          [correo, cliente_id]
        );
      }
    }

    // 3. crear pedido
    const pedido = await pool.query(
      `INSERT INTO pedidos(
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
      )
      VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
      RETURNING *`,
      [
        cliente_id,
        fechaRegistro,
        fechaEntrega,
        horaEntrega,
        tipo_pedido     || null,
        tipo_torta      || null,
        peso_torta      || null,
        sabor_ponque    || null,
        relleno_base    || null,
        relleno_especial || null,
        tipo_torta_especial || null
      ]
    );

    res.json(pedido.rows[0]);

  } catch (error) {
    console.error("ERROR CREANDO PEDIDO:");
    console.error(error);
    console.log("DATOS RECIBIDOS:", req.body);
    res.status(500).json({
      error: "Error creando pedido",
      detalle: error.message
    });
  }
};


exports.corregirFechaHora = async (req, res) => {
  const { id } = req.params;
  const { fecha_entrega, hora_entrega } = req.body;

  try {
    const fechaEntrega = limpiarFecha(fecha_entrega);
    const horaEntrega  = limpiarHora(hora_entrega);

    const result = await pool.query(
      `UPDATE pedidos 
       SET fecha_entrega = $1, hora_entrega = $2
       WHERE id = $3
       RETURNING *`,
      [fechaEntrega, horaEntrega, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Pedido no encontrado" });
    }

    res.json(result.rows[0]);

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error corrigiendo pedido", detalle: error.message });
  }
};


exports.marcarEntregado = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `UPDATE pedidos SET estado = 'entregado' WHERE id = $1 RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Pedido no encontrado" });
    }

    res.json(result.rows[0]);

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error actualizando estado", detalle: error.message });
  }
};