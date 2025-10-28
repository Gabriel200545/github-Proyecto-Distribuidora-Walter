import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario_model.dart';

class UsuarioService {
  static const String baseUrl = "https://webapi20251008054007-f5g2fbaqbzfbang0.westus3-01.azurewebsites.net/api/Usuario";

  // Obtener todos los usuarios con roles
  static Future<List<Usuario>> getUsuarios() async {
    final response = await http.get(Uri.parse("$baseUrl/con-roles"));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((u) => Usuario.fromJson(u)).toList();
    } else {
      throw Exception("Error al obtener usuarios: ${response.statusCode}");
    }
  }

  // Crear usuario
  static Future<bool> createUsuario(Usuario usuario) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(usuario.toJson()),
    );
    return response.statusCode == 200;
  }

  // Eliminar usuario
  static Future<bool> deleteUsuario(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    return response.statusCode == 200;
  }
}
