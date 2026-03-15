const pool = require("../config/db");

function limpiarFecha(valor) {
  if (!valor) return null;
  // ya viene formateado correctamente
  if (typeof valor === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(valor)) return valor;
  // intentar parsear cualquier formato
  const fecha = new Date(valor);
  if (isNaN(fecha.getTime())) return null;
  // usar UTC para evitar desfase de zona horaria
  const anio = fecha.getUTCFullYear();
  const mes = (fecha.getUTCMonth() + 1).toString().padStart(2, '0');
  const dia = fecha.getUTCDate().toString().padStart(2, '0');
  return `${anio}-${mes}-${dia}`;
}

function limpiarHora(valor) {
  if (!valor) return null;
  // ya viene formateado correctamente
  if (typeof valor === 'string' && /^\d{2}:\d{2}(:\d{2})?$/.test(valor)) return valor;
  const fecha = new Date(valor);
  if (isNaN(fecha.getTime())) return null;
  // usar UTC porque la hora base 1899 de Sheets viene en UTC
  const h = fecha.getUTCHours().toString().padStart(2, '0');
  const m = fecha.getUTCMinutes().toString().padStart(2, '0');
  const s = fecha.getUTCSeconds().toString().padStart(2, '0');
  return `${h}:${m}:${s}`;
}


exports.crearPedido = async (req, res) => {
  const {
    nombre,
    telefono,
    correo,
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
    const fechaEntrega = limpiarFecha(fecha_entrega);
    const horaEntrega  = limpiarHora(hora_entrega);

    let cliente = await pool.query(
      "SELECT id FROM clientes WHERE telefono = $1", [telefono]
    );

    let cliente_id;

    if (cliente.rows.length === 0) {
      const nuevoCliente = await pool.query(
        `INSERT INTO clientes(nombre, telefono, correo)
         VALUES($1, $2, $3) RETURNING id`,
        [nombre, telefono, correo || null]
      );
      cliente_id = nuevoCliente.rows[0].id;
    } else {
      cliente_id = cliente.rows[0].id;
      if (correo) {
        await pool.query(
          `UPDATE clientes SET correo = $1 WHERE id = $2 AND (correo IS NULL OR correo = '')`,
          [correo, cliente_id]
        );
      }
    }

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
      VALUES($1, NOW(), $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *`,
      [
        cliente_id,
        fechaEntrega,
        horaEntrega,
        tipo_pedido          || null,
        tipo_torta           || null,
        peso_torta           || null,
        sabor_ponque         || null,
        relleno_base         || null,
        relleno_especial     || null,
        tipo_torta_especial  || null
      ]
    );

    res.json(pedido.rows[0]);

  } catch (error) {
    console.error("ERROR CREANDO PEDIDO:");
    console.error(error);
    console.log("DATOS RECIBIDOS:", req.body);
    res.status(500).json({ error: "Error creando pedido", detalle: error.message });
  }
};