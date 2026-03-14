require('dotenv').config();

const express = require('express');
const app = express();

const pedidosRoutes = require('./src/routes/pedidos');
const clientesRoutes = require("./src/routes/clientes");

// IMPORTANTE: primero el middleware
app.use(express.json());

// luego las rutas
app.use("/clientes", clientesRoutes);
app.use('/pedidos', pedidosRoutes);

app.get('/', (req, res) => {
  res.send('API MIS Satori funcionando');
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log("Server running on port", PORT);
});