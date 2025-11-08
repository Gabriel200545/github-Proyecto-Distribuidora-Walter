import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/unidad_medida_model.dart';

class UnidadMedidaService {
  // Cambia la URL a tu API real
  static const String baseUrl =
      "https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api/UnidadMedida";

  // GET all
  static Future<List<UnidadMedida>> getUnidades() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => UnidadMedida.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error cargando unidades de medida: $e');
      return [];
    }
  }

  // POST
  static Future<bool> createUnidad(UnidadMedida unidad) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(unidad.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creando unidad de medida: $e');
      return false;
    }
  }

  // PUT
  static Future<bool> updateUnidad(UnidadMedida unidad) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${unidad.idUnidad}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(unidad.toJson()),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error actualizando unidad de medida: $e');
      return false;
    }
  }

  // DELETE
  static Future<bool> deleteUnidad(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error eliminando unidad de medida: $e');
      return false;
    }
  }
}
