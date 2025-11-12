import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reportes_model.dart';

class ReportesService {
  static const baseUrl =
      'https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api';

  static Future<TotalVentas> getTotalVentas() async {
    final res = await http.get(Uri.parse('$baseUrl/VentasDw/Totales'));
    if (res.statusCode == 200) {
      final List jsonData = json.decode(res.body);
      return TotalVentas.fromJson(jsonData.first);
    } else {
      throw Exception('Error al obtener Total Ventas');
    }
  }

  static Future<GastoTotal> getGastoTotal() async {
    final res = await http.get(Uri.parse('$baseUrl/FactCompraDw/GastoTotal'));
    if (res.statusCode == 200) {
      final List jsonData = json.decode(res.body);
      return GastoTotal.fromJson(jsonData.first);
    } else {
      throw Exception('Error al obtener Gasto Total');
    }
  }

  static Future<List<CrecimientoMensual>> getCrecimientoMensual() async {
    final res = await http.get(Uri.parse('$baseUrl/TimeDw/CrecimientoMensual'));
    if (res.statusCode == 200) {
      final List jsonData = json.decode(res.body);
      return CrecimientoMensual.listFromJson(jsonData);
    } else {
      throw Exception('Error al obtener Crecimiento Mensual');
    }
  }

  static Future<List<UnidadesVendidas>> getUnidadesVendidas() async {
    final res = await http.get(
      Uri.parse('$baseUrl/ProductDw/UnidadesVendidas'),
    );
    if (res.statusCode == 200) {
      final List jsonData = json.decode(res.body);
      return UnidadesVendidas.listFromJson(jsonData);
    } else {
      throw Exception('Error al obtener Unidades Vendidas');
    }
  }

  static Future<List<CostoPromedio>> getCostoPromedio() async {
    final res = await http.get(Uri.parse('$baseUrl/ProductDw/CostoPromedio'));
    if (res.statusCode == 200) {
      final List jsonData = json.decode(res.body);
      return CostoPromedio.listFromJson(jsonData);
    } else {
      throw Exception('Error al obtener Costo Promedio');
    }
  }
}
