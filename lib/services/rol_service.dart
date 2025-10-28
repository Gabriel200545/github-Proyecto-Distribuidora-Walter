import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rol_model.dart';

class RolService {
  static const String baseUrl =
      "https://webapi20251008054007-f5g2fbaqbzfbang0.westus3-01.azurewebsites.net/api/Roles";

  static Future<List<Rol>> getRoles() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Rol.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener roles');
    }
  }

  static Future<bool> crearRol(String nombre) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nombre': nombre}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> editarRol(int idRol, String nombre) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$idRol'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idRol': idRol, 'nombre': nombre}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> eliminarRol(int idRol) async {
    final response = await http.delete(Uri.parse('$baseUrl/$idRol'));
    return response.statusCode == 200;
  }

    // NUEVOS MÉTODOS PARA ASIGNAR Y QUITAR ROL
  static Future<bool> asignarRolUsuario(int idUsuario, int idRol) async {
    final response = await http.post(
      Uri.parse('$baseUrl/asignar-rol'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idUsuario': idUsuario, 'idRol': idRol}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> quitarRolUsuario(int idUsuario, int idRol) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/usuario/$idUsuario/rol/$idRol'),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }
}