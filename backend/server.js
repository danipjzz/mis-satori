require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();

//middlewares
app.use(cors());
app.use(express.json());

//ruta de prueba
app.get('/', (req, res) => {
    res.json({ mensaje: "Backend MIS Repostería funcionando 🚀" });
});

//puerto
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
})