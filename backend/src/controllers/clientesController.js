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

exports.getClientesConHistorial = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT
        clientes.id,
        clientes.nombre,
        clientes.telefono,
        clientes.correo,
        json_agg(
          json_build_object(
            'fecha_entrega', actividad.fecha,
            'tipo_pedido', actividad.tipo,
            'tipo_torta', null,
            'peso_torta', null,
            'sabor_ponque', null,
            'relleno_base', null,
            'relleno_especial', null,
            'postres', null
          ) ORDER BY actividad.fecha DESC
        ) FILTER (WHERE actividad.fecha IS NOT NULL) AS pedidos
      FROM clientes
      LEFT JOIN (
        -- pedidos
        SELECT
          cliente_id,
          fecha_entrega AS fecha,
          COALESCE(tipo_pedido, tipo_torta, peso_torta, 'Pedido') AS tipo
        FROM pedidos
        WHERE fecha_entrega IS NOT NULL

        UNION ALL

        -- ventas del punto fisico
        SELECT
          cliente_id,
          fecha AS fecha,
          producto AS tipo
        FROM ventas
        WHERE cliente_id IS NOT NULL AND fecha IS NOT NULL

      ) actividad ON actividad.cliente_id = clientes.id
      GROUP BY clientes.id
      ORDER BY clientes.nombre ASC
    `);
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error obteniendo clientes" });
  }
};

exports.getAnalisis = async (req, res) => {
  try {
    // pedidos de los últimos 6 meses
    const pedidos = await db.query(`
      SELECT
        pedidos.fecha_entrega,
        pedidos.tipo_pedido,
        pedidos.tipo_torta,
        pedidos.peso_torta,
        pedidos.sabor_ponque,
        pedidos.postres,
        clientes.nombre,
        clientes.telefono
      FROM pedidos
      LEFT JOIN clientes ON pedidos.cliente_id = clientes.id
      WHERE pedidos.fecha_entrega >= NOW() - INTERVAL '6 months'
      ORDER BY pedidos.fecha_entrega DESC
    `);

    // clientes sin pedidos en más de 60 días
    const inactivos = await db.query(`
      SELECT
        clientes.nombre,
        clientes.telefono,
        MAX(pedidos.fecha_entrega) AS ultimo_pedido
      FROM clientes
      LEFT JOIN pedidos ON pedidos.cliente_id = clientes.id
      GROUP BY clientes.id, clientes.nombre, clientes.telefono
      HAVING MAX(pedidos.fecha_entrega) < NOW() - INTERVAL '60 days'
         OR MAX(pedidos.fecha_entrega) IS NULL
      ORDER BY ultimo_pedido ASC NULLS FIRST
    `);

    res.json({
      pedidos: pedidos.rows,
      inactivos: inactivos.rows
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error obteniendo análisis" });
  }
};