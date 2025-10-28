// proveedor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/proveedor_model.dart';

class ProveedorService {
  static const String baseUrl = 'https://webapi20251008054007-f5g2fbaqbzfbang0.westus3-01.azurewebsites.net/api/Proveedor'; // <-- reemplaza

  static Future<List<Proveedor>> getProveedores() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Proveedor.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener proveedores');
    }
  }

  static Future<bool> createProveedor(Proveedor proveedor) async {
    final Map<String, dynamic> body = {
      'Nombre': proveedor.nombre,
      'Contacto': proveedor.contacto,
      'Telefono': proveedor.telefono,
      'Correo': proveedor.correo,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    return response.statusCode == 200;
  }

  static Future<bool> updateProveedor(Proveedor proveedor) async {
    if (proveedor.idProveedor == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/${proveedor.idProveedor}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(proveedor.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteProveedor(int? id) async {
    if (id == null) return false;

    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }
}
