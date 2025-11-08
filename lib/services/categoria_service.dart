import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria_model.dart';

class CategoriaService {
  // Cambia la URL a tu ngrok o tu API real
  static const String baseUrl =
      "https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api/Categoria";

  // GET all
  static Future<List<Categoria>> getCategorias() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => Categoria.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error cargando categorías: $e');
      return [];
    }
  }

  // POST
  static Future<bool> createCategoria(Categoria categoria) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(categoria.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creando categoría: $e');
      return false;
    }
  }

  // PUT
  static Future<bool> updateCategoria(Categoria categoria) async {
    if (categoria.id == null) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${categoria.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(categoria.toJson()),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error actualizando categoría: $e');
      return false;
    }
  }

  // DELETE
  static Future<bool> deleteCategoria(int? id) async {
    if (id == null) return false;
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error eliminando categoría: $e');
      return false;
    }
  }
}
