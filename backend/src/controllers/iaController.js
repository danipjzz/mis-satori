const Groq = require('groq-sdk');

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

exports.generarMensaje = async (req, res) => {
  const { nombre, historial, razon } = req.body;
  try {
    const completion = await groq.chat.completions.create({
      model: 'llama-3.3-70b-versatile',
      max_tokens: 200,
      messages: [{
        role: 'user',
        content: `Eres el asistente de Satori, una pastelería artesanal venezolana. 
Genera un mensaje de WhatsApp corto, cálido y personalizado para ${nombre}.
Su historial de pedidos: ${historial}.
Razón para contactar: ${razon}.
El mensaje debe:
- Ser en español venezolano, informal y cariñoso
- Mencionar la razón de contacto de forma natural
- Invitarle a hacer un nuevo pedido de forma natural, no agresiva.
- Máximo 3 oraciones
- Sin emojis excesivos, máximo 2
- No mencionar precios
Solo devuelve el mensaje, sin explicaciones.`
      }]
    });
    res.json({ mensaje: completion.choices[0].message.content });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error generando mensaje", detalle: error.message });
  }
};

exports.generarAnalisis = async (req, res) => {
  const { resumen } = req.body;
  try {
    const completion = await groq.chat.completions.create({
      model: 'llama-3.3-70b-versatile',
      max_tokens: 300,
      messages: [{
        role: 'user',
        content: `Eres analista de negocios para Satori, una pastelería venezolana.
Analiza estos pedidos recientes y da:
1. Predicción de ventas para las próximas 2 semanas
2. Productos que más se pedirán
3. 2-3 recomendaciones concretas

Pedidos recientes:
${resumen}

Responde en español, de forma concisa y práctica. Máximo 150 palabras.`
      }]
    });
    res.json({ analisis: completion.choices[0].message.content });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error generando análisis", detalle: error.message });
  }
};