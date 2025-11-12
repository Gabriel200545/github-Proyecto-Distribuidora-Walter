class TotalVentas {
  final double total;

  TotalVentas({required this.total});

  factory TotalVentas.fromJson(dynamic json) {
    // json puede ser Map o List
    if (json is Map<String, dynamic>) {
      return TotalVentas(total: (json['ventasTotales'] ?? 0).toDouble());
    } else if (json is List && json.isNotEmpty) {
      return TotalVentas.fromJson(json.first);
    } else {
      return TotalVentas(total: 0);
    }
  }
}

class GastoTotal {
  final double total;

  GastoTotal({required this.total});

  factory GastoTotal.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return GastoTotal(total: (json['gastoCompras'] ?? 0).toDouble());
    } else if (json is List && json.isNotEmpty) {
      return GastoTotal.fromJson(json.first);
    } else {
      return GastoTotal(total: 0);
    }
  }
}

class CrecimientoMensual {
  final String mes;
  final double porcentaje;

  CrecimientoMensual({required this.mes, required this.porcentaje});

  factory CrecimientoMensual.fromJson(Map<String, dynamic> json) {
    return CrecimientoMensual(
      mes: json['nombreMes'] ?? '${json['mes'] ?? ''}',
      porcentaje: (json['crecimientoPct'] ?? 0).toDouble(),
    );
  }

  static List<CrecimientoMensual> listFromJson(dynamic json) {
    if (json is List) {
      return json.map((e) => CrecimientoMensual.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}

class UnidadesVendidas {
  final String producto;
  final double unidades;

  UnidadesVendidas({required this.producto, required this.unidades});

  factory UnidadesVendidas.fromJson(Map<String, dynamic> json) {
    return UnidadesVendidas(
      producto: json['productName'] ?? '',
      unidades: (json['unidadesVendidas'] ?? 0).toDouble(),
    );
  }

  static List<UnidadesVendidas> listFromJson(dynamic json) {
    if (json is List) {
      return json.map((e) => UnidadesVendidas.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}

class CostoPromedio {
  final String producto;
  final double costo;

  CostoPromedio({required this.producto, required this.costo});

  factory CostoPromedio.fromJson(Map<String, dynamic> json) {
    return CostoPromedio(
      producto: json['productName'] ?? '',
      costo: (json['costoPromedioUnitario'] ?? 0).toDouble(),
    );
  }

  static List<CostoPromedio> listFromJson(dynamic json) {
    if (json is List) {
      return json.map((e) => CostoPromedio.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
