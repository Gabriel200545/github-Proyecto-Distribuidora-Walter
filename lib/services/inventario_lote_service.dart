import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventario_lote_model.dart';

class InventarioLoteService {
  static const String baseUrl =
      "https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api/InventarioLote";

  // GET all
  static Future<List<InventarioLote>> getInventarioLotes() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => InventarioLote.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error cargando inventario por lotes: $e');
      return [];
    }
  }

  // POST
  static Future<bool> createInventarioLote(InventarioLote item) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creando inventario por lote: $e');
      return false;
    }
  }

  // PUT
  static Future<bool> updateInventarioLote(InventarioLote item) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/${item.idProducto}/${item.idBodega}/${item.idLote}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error actualizando inventario por lote: $e');
      return false;
    }
  }

  // DELETE
  static Future<bool> deleteInventarioLote(
    int idProducto,
    int idBodega,
    int idLote,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$idProducto/$idBodega/$idLote'),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error eliminando inventario por lote: $e');
      return false;
    }
  }
}
