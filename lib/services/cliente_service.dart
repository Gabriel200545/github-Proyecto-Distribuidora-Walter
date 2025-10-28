import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cliente_model.dart';

class ClienteService {
  static const String baseUrl = 'https://webapi20251008054007-f5g2fbaqbzfbang0.westus3-01.azurewebsites.net/api/Cliente';

  static Future<List<Cliente>> getClientes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Cliente.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener clientes');
    }
  }

  static Future<bool> createCliente(Cliente cliente) async {
    final Map<String, dynamic> body = {
      'Nombre': cliente.nombre,
      'Direccion': cliente.direccion,
      'Telefono': cliente.telefono,
      'Correo': cliente.correo,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    return response.statusCode == 200;
  }

  static Future<bool> updateCliente(Cliente cliente) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${cliente.idCliente}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cliente.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteCliente(int? id) async {
    if (id == null) return false;
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }
}
