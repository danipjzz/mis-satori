const pool = require("../config/db");


// limpiar hora que viene de Google Sheets
function limpiarHora(valor) {

  if (!valor) return null;

  const fecha = new Date(valor);

  return fecha.toISOString().substring(11,19);
}


// limpiar fecha que viene de Google Sheets
function limpiarFecha(valor) {

  if (!valor) return null;

  const fecha = new Date(valor);

  return fecha.toISOString().substring(0,10);
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
    tipo_torta
  } = req.body;


  try {

    // limpiar datos de fecha y hora
    const fechaRegistro = limpiarFecha(fecha_registro);
    const fechaEntrega = limpiarFecha(fecha_entrega);
    const horaEntrega = limpiarHora(hora_entrega);


    // 1️⃣ buscar cliente
    let cliente = await pool.query(
      "SELECT id FROM clientes WHERE telefono = $1",
      [telefono]
    );

    let cliente_id;


    // 2️⃣ si no existe crear cliente
    if (cliente.rows.length === 0) {

      const nuevoCliente = await pool.query(
        `INSERT INTO clientes(nombre, telefono)
         VALUES($1,$2)
         RETURNING id`,
        [nombre, telefono]
      );

      cliente_id = nuevoCliente.rows[0].id;

    } else {

      cliente_id = cliente.rows[0].id;

    }


    // 3️⃣ crear pedido
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
        relleno_especial
      )
      VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
      RETURNING *`,

      [
        cliente_id,
        fechaRegistro,
        fechaEntrega,
        horaEntrega,
        tipo_pedido,
        tipo_torta,
        peso_torta,
        sabor_ponque,
        relleno_base,
        relleno_especial
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