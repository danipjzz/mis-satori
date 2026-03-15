const Anthropic = require('@anthropic-ai/sdk');

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

exports.generarMensaje = async (req, res) => {
  const { nombre, historial, razon } = req.body;  // ← agregar razon
  try {
    const message = await client.messages.create({
      model: "claude-sonnet-4-20250514",
      max_tokens: 1000,
      messages: [{
        role: "user",
        content: `Eres el asistente de Satori, una pastelería artesanal venezolana.
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
Solo devuelve el mensaje, sin explicaciones.`
      }]
    });
    res.json({ mensaje: message.content[0].text });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error generando mensaje" });
  }
};

exports.generarAnalisis = async (req, res) => {
  const { resumen } = req.body;
  try {
    const message = await client.messages.create({
      model: "claude-sonnet-4-20250514",
      max_tokens: 1000,
      messages: [{
        role: "user",
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
    res.json({ analisis: message.content[0].text });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error generando análisis" });
  }
};