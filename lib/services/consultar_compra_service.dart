import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/consultar_compra_model.dart';

class ConsultarCompraService {
  static const String baseUrl =
      'https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api';

  // 🔹 Obtener todas las compras con sus detalles
  static Future<List<Compra>> obtenerCompras() async {
    final url = Uri.parse('$baseUrl/Compra/todas');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Compra.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener las compras');
    }
  }

  // 🔹 Obtener todos los proveedores (corregido el endpoint)
  static Future<Map<int, String>> obtenerProveedores() async {
    final url = Uri.parse('$baseUrl/Proveedor');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final Map<int, String> proveedores = {};
      for (var item in data) {
        proveedores[item['idProveedor']] = item['nombre'];
      }
      return proveedores;
    } else {
      throw Exception('Error al obtener los proveedores');
    }
  }
}
