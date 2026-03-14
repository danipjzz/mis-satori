require('dotenv').config();
const express = require('express');

const pedidosRoutes = require('./src/routes/pedidos');

const app = express();

const clientesRoutes = require("./src/routes/clientes");

app.use("/clientes", clientesRoutes);

app.use(express.json());

app.use('/pedidos', pedidosRoutes);

app.get('/', (req, res) => {
  res.send('API MIS Satori funcionando');
});
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log("Server running on port", PORT);
});