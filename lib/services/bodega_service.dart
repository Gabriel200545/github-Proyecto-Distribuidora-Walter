import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bodega_model.dart';

class BodegaService {
static const String baseUrl = "https://webapi20251008054007-f5g2fbaqbzfbang0.westus3-01.azurewebsites.net/api/Bodega";

  static Future<List<Bodega>> getBodegas() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Bodega.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener bodegas');
    }
  }

  static Future<bool> createBodega(Bodega bodega) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodega.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateBodega(Bodega bodega) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${bodega.idBodega}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodega.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteBodega(int idBodega) async {
    final response = await http.delete(Uri.parse('$baseUrl/$idBodega'));
    return response.statusCode == 200;
  }
}
