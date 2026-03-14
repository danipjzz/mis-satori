import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const baseUrl = "https://mis-satori.onrender.com";

  static Future<List> getPedidos() async {

    final res = await http.get(
      Uri.parse("$baseUrl/pedidos"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error cargando pedidos");
    }
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
}