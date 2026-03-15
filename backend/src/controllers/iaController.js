const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });

exports.generarMensaje = async (req, res) => {
  const { nombre, historial, razon } = req.body;
  try {
    const prompt = `Eres el asistente de Satori, una pastelería artesanal venezolana. 
Genera un mensaje de WhatsApp corto, cálido y personalizado para ${nombre}.
Su historial de pedidos: ${historial}.
Razón para contactar: ${razon}.
El mensaje debe:
- Ser en español venezolano, informal y cariñoso
- Mencionar la razón de contacto de forma natural
- Invitarle a hacer un nuevo pedido
- Máximo 3 oraciones
- Sin emojis excesivos, máximo 2
- No mencionar precios
Solo devuelve el mensaje, sin explicaciones.`;

    const result = await model.generateContent(prompt);
    const texto = result.response.text();
    res.json({ mensaje: texto });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error generando mensaje", detalle: error.message });
  }
};

exports.generarAnalisis = async (req, res) => {
  const { resumen } = req.body;
  try {
    const prompt = `Eres analista de negocios para Satori, una pastelería venezolana.
Analiza estos pedidos recientes y da:
1. Predicción de ventas para las próximas 2 semanas
2. Productos que más se pedirán
3. 2-3 recomendaciones concretas

Pedidos recientes:
${resumen}

Responde en español, de forma concisa y práctica. Máximo 150 palabras.`;

    const result = await model.generateContent(prompt);
    const texto = result.response.text();
    res.json({ analisis: texto });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error generando análisis", detalle: error.message });
  }
};