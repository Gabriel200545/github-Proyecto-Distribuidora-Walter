import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/marca_model.dart';

class MarcaService {
  static const String baseUrl =
      'https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api/Marca';

  static Future<List<Marca>> getMarcas() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Marca.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener marcas');
    }
  }

  static Future<bool> createMarca(Marca marca) async {
    // No enviar IdMarca en el POST, ya que el backend lo genera automáticamente
    final Map<String, dynamic> body = {'Nombre': marca.nombre};

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    return response.statusCode == 200;
  }

  static Future<bool> updateMarca(Marca marca) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${marca.idMarca}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(marca.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteMarca(int? id) async {
    if (id == null) return false;
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }
}
