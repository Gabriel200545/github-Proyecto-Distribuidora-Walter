import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/consultar_venta_model.dart';

class ConsultarVentaService {
  static const String baseUrl =
      'https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api';

  static Future<List<Venta>> obtenerVentas() async {
    final res = await http.get(Uri.parse('$baseUrl/Venta'));
    if (res.statusCode != 200) throw Exception('Error al obtener ventas');
    final List data = jsonDecode(res.body);
    return data.map((e) => Venta.fromJson(e)).toList();
  }

  static Future<Map<int, String>> obtenerClientes() async {
    final res = await http.get(Uri.parse('$baseUrl/Cliente'));
    if (res.statusCode != 200) throw Exception('Error al obtener clientes');
    final List data = jsonDecode(res.body);
    return {for (var c in data) c['idCliente']: c['nombre']};
  }
}
