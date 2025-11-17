import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reportes_model.dart';

class ReportesService {
  static const baseUrl =
      'https://webapi20251108112945-d5c0b7fge9c6a8fh.westus-01.azurewebsites.net/api';

  static Future<TotalVentas> getTotalVentas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? anio,
    int? mes,
  }) async {
    final uri = Uri.parse('$baseUrl/VentasDw/Totales');
    final queryParams = <String, String>{};
    
    if (fechaInicio != null) {
      queryParams['fechaInicio'] = fechaInicio.toIso8601String().split('T')[0];
    }
    if (fechaFin != null) {
      queryParams['fechaFin'] = fechaFin.toIso8601String().split('T')[0];
    }
    if (anio != null) {
      queryParams['anio'] = anio.toString();
    }
    if (mes != null) {
      queryParams['mes'] = mes.toString();
    }

    final finalUri = queryParams.isEmpty 
        ? uri 
        : uri.replace(queryParameters: queryParams);

    final res = await http.get(finalUri);
    if (res.statusCode == 200) {
      final List jsonData = json.decode(res.body);
      return TotalVentas.fromJson(jsonData.first);
    } else {
      throw Exception('Error al obtener Total Ventas');
    }
  }

  static Future<GastoTotal> getGastoTotal({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? anio,
    int? mes,
    int? proveedorId,
  }) async {
    final uri = Uri.parse('$baseUrl/FactCompraDw/GastoTotal');
    final queryParams = <String, String>{};
    
    if (fechaInicio != null) {
      queryParams['fechaInicio'] = fechaInicio.toIso8601String().split('T')[0];
    }
    if (fechaFin != null) {
      queryParams['fechaFin'] = fechaFin.toIso8601String().split('T')[0];
    }
    if (anio != null) {
      queryParams['anio'] = anio.toString();
    }
    if (mes != null) {
      queryParams['mes'] = mes.toString();
    }
    if (proveedorId != null) {
      queryParams['proveedorId'] = proveedorId.toString();
    }

    final finalUri = queryParams.isEmpty 
        ? uri 
        : uri.replace(queryParameters: queryParams);

    final res = await http.get(finalUri);
    if (res.statusCode == 200) {
      final List jsonData = json.decode(res.body);
      return GastoTotal.fromJson(jsonData.first);
    } else {
      throw Exception('Error al obtener Gasto Total');
    }
  }

  static Future<List<CrecimientoMensual>> getCrecimientoMensual({
    int? anio,
    int? mesInicio,
    int? mesFin,
    String? periodo, // 'mensual' o 'trimestral'
  }) async {
    final uri = Uri.parse('$baseUrl/TimeDw/CrecimientoMensual');
    final queryParams = <String, String>{};
    
    if (anio != null) {
      queryParams['anio'] = anio.toString();
    }
    if (mesInicio != null) {
      queryParams['mesInicio'] = mesInicio.toString();
    }
    if (mesFin != null) {
      queryParams['mesFin'] = mesFin.toString();
    }
    if (periodo != null) {
      queryParams['periodo'] = periodo;
    }

    final finalUri = queryParams.isEmpty 
        ? uri 
        : uri.replace(queryParameters: queryParams);

    final res = await http.get(finalUri);
    if (res.statusCode == 200) {
      final List jsonData = json.decode(res.body);
      return CrecimientoMensual.listFromJson(jsonData);
    } else {
      throw Exception('Error al obtener Crecimiento Mensual');
    }
  }

  static Future<List<UnidadesVendidas>> getUnidadesVendidas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? categoriaId,
    int? marcaId,
    int? top,
  }) async {
    final uri = Uri.parse('$baseUrl/ProductDw/UnidadesVendidas');
    final queryParams = <String, String>{};
    
    if (fechaInicio != null) {
      queryParams['fechaInicio'] = fechaInicio.toIso8601String().split('T')[0];
    }
    if (fechaFin != null) {
      queryParams['fechaFin'] = fechaFin.toIso8601String().split('T')[0];
    }
    if (categoriaId != null) {
      queryParams['categoriaId'] = categoriaId.toString();
    }
    if (marcaId != null) {
      queryParams['marcaId'] = marcaId.toString();
    }
    if (top != null) {
      queryParams['top'] = top.toString();
    }

    final finalUri = queryParams.isEmpty 
        ? uri 
        : uri.replace(queryParameters: queryParams);

    final res = await http.get(finalUri);
    if (res.statusCode == 200) {
      final List jsonData = json.decode(res.body);
      return UnidadesVendidas.listFromJson(jsonData);
    } else {
      throw Exception('Error al obtener Unidades Vendidas');
    }
  }

  static Future<List<CostoPromedio>> getCostoPromedio({
    int? categoriaId,
    int? proveedorId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? top,
  }) async {
    final uri = Uri.parse('$baseUrl/ProductDw/CostoPromedio');
    final queryParams = <String, String>{};
    
    if (categoriaId != null) {
      queryParams['categoriaId'] = categoriaId.toString();
    }
    if (proveedorId != null) {
      queryParams['proveedorId'] = proveedorId.toString();
    }
    if (fechaInicio != null) {
      queryParams['fechaInicio'] = fechaInicio.toIso8601String().split('T')[0];
    }
    if (fechaFin != null) {
      queryParams['fechaFin'] = fechaFin.toIso8601String().split('T')[0];
    }
    if (top != null) {
      queryParams['top'] = top.toString();
    }

    final finalUri = queryParams.isEmpty 
        ? uri 
        : uri.replace(queryParameters: queryParams);

    final res = await http.get(finalUri);
    if (res.statusCode == 200) {
      final List jsonData = json.decode(res.body);
      return CostoPromedio.listFromJson(jsonData);
    } else {
      throw Exception('Error al obtener Costo Promedio');
    }
  }
}
