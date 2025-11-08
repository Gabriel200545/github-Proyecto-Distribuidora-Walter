import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Cambia esta URL si usas ngrok
  static const String baseUrl =
      "https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api/Usuario";

  static Future<bool> login(String usuario, String password) async {
    final url = Uri.parse("$baseUrl/AuthenticateUsuario"); // POST sin id
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nombre": usuario, "contraseña": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ahora valida según el backend
        if (data['result'] == true) {
          // Opcional: guardar token si quieres
          // final token = data['token'];
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print("Error conectando a API: $e");
      return false;
    }
  }
}
