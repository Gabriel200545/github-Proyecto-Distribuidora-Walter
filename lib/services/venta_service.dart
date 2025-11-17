// services/venta_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venta_model.dart';

class VentaService {
  static const String baseUrl =
      "https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api/Venta";

  // POST Registrar (envía el JSON que tu SP espera)
  static Future<bool> registrarVenta(VentaRequest venta) async {
    final url = Uri.parse("$baseUrl/Registrar");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(venta.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // GET all (opcional, si quieres listar ventas)
  static Future<List<dynamic>> getVentas() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception("Error al obtener ventas");
  }
}
