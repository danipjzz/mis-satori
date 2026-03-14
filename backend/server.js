require('dotenv').config();
const express = require('express');

const app = express();

app.use(express.json());

const pedidosRoutes = require('./src/routes/pedidos');
const clientesRoutes = require('./src/routes/clientes');

app.use('/pedidos', pedidosRoutes);
app.use('/clientes', clientesRoutes);

app.get('/', (req, res) => {
  res.send('API MIS Satori funcionando');
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log("Server running on port", PORT);
});