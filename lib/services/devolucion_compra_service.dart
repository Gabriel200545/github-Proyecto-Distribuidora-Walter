// services/devolucion_compra_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class DevolucionCompraService {
  static const String baseUrl =
      'https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api';

  /// Registra una devolución de compra
  static Future<void> registrarDevolucion(
    Map<String, dynamic> devolucion,
  ) async {
    final url = Uri.parse('$baseUrl/DevolucionCompra/registrar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(devolucion),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Error al registrar la devolución.');
      } catch (_) {
        throw Exception('Error al registrar la devolución.');
      }
    }
  }
}
