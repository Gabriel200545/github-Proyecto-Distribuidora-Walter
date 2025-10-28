import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/compra_model.dart';

class CompraService {
  static const String baseUrl =
      "https://webapi20251008054007-f5g2fbaqbzfbang0.westus3-01.azurewebsites.net/api/Compra";

  static Future<bool> registrarCompra(Compra compra) async {
    try {
      final body = jsonEncode(compra.toJson());
      print("📤 Enviando compra: $body");

      final response = await http.post(
        Uri.parse("$baseUrl/registrar"),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("📥 Respuesta: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Compra registrada con éxito");
        return true;
      } else {
        print("⚠️ Error al registrar compra: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Excepción al registrar compra: $e");
      return false;
    }
  }

  // (Opcional) para ver compras registradas
  static Future<List<dynamic>> getCompras() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("⚠️ Error al obtener compras: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Excepción al obtener compras: $e");
      return [];
    }
  }
}
