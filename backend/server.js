require('dotenv').config();
const express = require('express');
const pool = require("./src/config/db");
const cors = require("cors");

const app = express();
app.use(cors());

app.use(express.json());

const pedidosRoutes = require('./src/routes/pedidos');
const clientesRoutes = require('./src/routes/clientes');
const ventasRoutes = require('./src/routes/ventas');

app.use('/pedidos', pedidosRoutes);
app.use('/clientes', clientesRoutes);
app.use('/ventas', ventasRoutes);

app.get('/', (req, res) => {
  res.send('API MIS Satori funcionando');
});

app.get("/pedidos", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        pedidos.id,
        clientes.nombre,
        clientes.telefono,
        pedidos.fecha_entrega,
        pedidos.hora_entrega,
        pedidos.tipo_pedido,
        pedidos.tipo_torta,
        pedidos.peso_torta,
        pedidos.sabor_ponque,
        pedidos.relleno_base,
        pedidos.relleno_especial,
        pedidos.tipo_torta_especial,
        pedidos.postres,  
        pedidos.estado
      FROM pedidos
      LEFT JOIN clientes ON pedidos.cliente_id = clientes.id
      ORDER BY pedidos.fecha_entrega ASC
    `);
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error obteniendo pedidos" });
  }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log("Server running on port", PORT);
});