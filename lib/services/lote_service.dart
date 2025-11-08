import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lote_model.dart';

class LoteService {
  // Cambia la URL a tu API real
  static const String baseUrl =
      "https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api/Lote";

  // GET all
  static Future<List<LoteModel>> getLotes() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => LoteModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error cargando lotes: $e');
      return [];
    }
  }

  // POST
  static Future<bool> createLote(LoteModel lote) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(lote.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creando lote: $e');
      return false;
    }
  }

  // PUT
  static Future<bool> updateLote(LoteModel lote) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${lote.idLote}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(lote.toJson()),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error actualizando lote: $e');
      return false;
    }
  }

  // DELETE
  static Future<bool> deleteLote(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error eliminando lote: $e');
      return false;
    }
  }
}
