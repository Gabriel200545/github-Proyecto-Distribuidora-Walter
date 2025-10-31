import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto_model.dart';

class ProductoService {
  static const String baseUrl =
      "https://webapi20251008054007-f5g2fbaqbzfbang0.westus3-01.azurewebsites.net/api/Product";

  // GET all
  static Future<List<Producto>> getProductos() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => Producto.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error cargando productos: $e');
      return [];
    }
  }

  // POST
  static Future<bool> createProducto(Producto producto) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(producto.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creando producto: $e');
      return false;
    }
  }

  // PUT
  static Future<bool> updateProducto(Producto producto) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${producto.idProducto}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(producto.toJson()),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error actualizando producto: $e');
      return false;
    }
  }

  // DELETE
  static Future<bool> deleteProducto(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error eliminando producto: $e');
      return false;
    }
  }
}
