import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const baseUrl = "https://mis-satori.onrender.com";

  static Future<List> getPedidos() async {
    final res = await http.get(Uri.parse("$baseUrl/pedidos"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error cargando pedidos");
    }
  }

  static Future<void> marcarEntregado(String id) async {
    await http.patch(Uri.parse("$baseUrl/pedidos/$id/entregar"));
  }

  static Future<void> crearPedido(Map data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/pedidos"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (res.statusCode != 200) {
      throw Exception("Error creando pedido");
    }
  }

  static Future<List> getClientesConHistorial() async {
    final res = await http.get(Uri.parse("$baseUrl/clientes/historial"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error cargando historial");
    }
  }

  static Future<List> getVentas() async {
  final res = await http.get(Uri.parse("$baseUrl/ventas"));
  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    throw Exception("Error cargando ventas");
  }
}
  // ← nuevo: corregir fecha y hora de un pedido existente
  static Future<void> corregirFechaHora(String id, String fechaEntrega, String horaEntrega) async {
    final res = await http.patch(
      Uri.parse("$baseUrl/pedidos/$id/corregir"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fecha_entrega": fechaEntrega,
        "hora_entrega": horaEntrega,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception("Error corrigiendo pedido");
    }
  }
}