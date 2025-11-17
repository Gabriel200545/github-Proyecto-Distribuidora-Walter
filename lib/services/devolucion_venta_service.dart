// devolucion_venta_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl =
    'https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api';

class Venta {
  final int idVenta;
  final String fecha;

  Venta({required this.idVenta, required this.fecha});

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(idVenta: json['idVenta'], fecha: json['fecha'] ?? '');
  }
}

class DevolucionVentaService {
  // 🔹 Obtener todas las ventas
  static Future<List<Venta>> obtenerVentas() async {
    final url = Uri.parse('$baseUrl/Venta');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((v) => Venta.fromJson(v)).toList();
    } else {
      throw Exception('No se pudo obtener la lista de ventas.');
    }
  }

  // 🔹 Registrar devolución de venta
  static Future<void> registrarDevolucionVenta(
    Map<String, dynamic> devolucion,
  ) async {
    final url = Uri.parse('$baseUrl/DevolucionVenta/registrar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(devolucion),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['message'] ?? 'Error al registrar la devolución.',
      );
    }
  }
}
