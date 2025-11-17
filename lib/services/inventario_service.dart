import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventario_model.dart';

class InventarioService {
  static const String baseUrl =
      "https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api/Inventario";

  // GET all
  static Future<List<Inventario>> getInventarios() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => Inventario.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error cargando inventarios: $e');
      return [];
    }
  }

  // POST
  static Future<bool> createInventario(Inventario inventario) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(inventario.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creando inventario: $e');
      return false;
    }
  }

  // PUT
  static Future<bool> updateInventario(Inventario inventario) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${inventario.idProducto}/${inventario.idBodega}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(inventario.toJson()),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error actualizando inventario: $e');
      return false;
    }
  }

  // DELETE
  static Future<bool> deleteInventario(int idProducto, int idBodega) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$idProducto/$idBodega'),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error eliminando inventario: $e');
      return false;
    }
  }
}
