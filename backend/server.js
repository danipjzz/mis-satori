require('dotenv').config();
const express = require('express');

const pedidosRoutes = require('./src/routes/pedidos');

const app = express();

app.use(express.json());

app.use('/pedidos', pedidosRoutes);

app.get('/', (req, res) => {
  res.send('API MIS Satori funcionando');
});

app.listen(process.env.PORT, () => {
  console.log(`Server running on port ${process.env.PORT}`);
});